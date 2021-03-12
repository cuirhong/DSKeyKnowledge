# Runloop
## 什么是Runloop
- 运行循环
- 在程序运行过程中循环做一些事情
## 应用范畴
- 定时器（Timer）、PerformSelector
- GCD Async Main Queue
- 事件响应、手势识别、界面刷新
- 网络请求
- AutoreleasePool
## 伪代码
```objc
int main(int argc, char * argv[]){
    @autoreleasepool{
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```
有了runloop之后，以上的代码UIApplicationMain中的实现(伪代码)
```objc
int main(int argc, char * argv[]){
    @autoreleasepool{
        int retVal = 0;
        do{
            //睡眠等待消息
            int message = sleep_and_wait();
            retVal = process_message(message);
        } while(0 == retVal);
        return 0;
    }
}
```
## 如果有了RunLoop
- 程序并不会马上退出，而是保持运行状态
- RunLoop的基本作用
  - 保持程序的持续运行
  - 处理App中的各种事情（比如触摸事件、定时器事件等）
  - 节省CPU资源，提高程序的性能
## RunLoop对象
### iOS中有2套API来访问和使用RunLoop
- Foundation：NSRunLoop

- Core Foundation：CFRunLoopRef

### NSRunLoop和CFRunLoopRef都代表着RunLoop对象
- NSRunLoop是基于CFRunLoopRef的一层OC包装
- CFRunLoopRef是开源的
https://opensource.apple.com/tarballs/CF/

## RunLoop与线程
- 每条线程都有唯一的一个与之对应的RunLoop对象

- RunLoop保存在一个全局的Dictionary里，线程作为key，RunLoop作为value

- 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建

- RunLoop会在线程结束时销毁

- 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop
## 获取RunLoop对象
- Foundation
```objc
  [NSRunLoop currentRunLoop]; // 获得当前线程的RunLoop对象
  [NSRunLoop mainRunLoop]; // 获得主线程的RunLoop对象
```

- Core Foundation
```objc
   CFRunLoopGetCurrent(); // 获得当前线程的RunLoop对象
   CFRunLoopGetMain(); // 获得主线程的RunLoop对象
```
### 获取RunLoop的源码
```objc
// should only be called by Foundation
// t==0 is a synonym for "main thread" that always works
CF_EXPORT CFRunLoopRef _CFRunLoopGet0(pthread_t t) {
    if (pthread_equal(t, kNilPthreadT)) {
	t = pthread_main_thread_np();
    }
    __CFLock(&loopsLock);
    if (!__CFRunLoops) {
        __CFUnlock(&loopsLock);
	CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks);
	CFRunLoopRef mainLoop = __CFRunLoopCreate(pthread_main_thread_np());
	CFDictionarySetValue(dict, pthreadPointer(pthread_main_thread_np()), mainLoop);
	if (!OSAtomicCompareAndSwapPtrBarrier(NULL, dict, (void * volatile *)&__CFRunLoops)) {
	    CFRelease(dict);
	}
	CFRelease(mainLoop);
        __CFLock(&loopsLock);
    }
    CFRunLoopRef loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
    __CFUnlock(&loopsLock);
    if (!loop) {
	CFRunLoopRef newLoop = __CFRunLoopCreate(t);
        __CFLock(&loopsLock);
	loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
	if (!loop) {
	    CFDictionarySetValue(__CFRunLoops, pthreadPointer(t), newLoop);
	    loop = newLoop;
	}
        // don't release run loops inside the loopsLock, because CFRunLoopDeallocate may end up taking it
        __CFUnlock(&loopsLock);
	CFRelease(newLoop);
    }
    if (pthread_equal(t, pthread_self())) {
        _CFSetTSD(__CFTSDKeyRunLoop, (void *)loop, NULL);
        if (0 == _CFGetTSD(__CFTSDKeyRunLoopCntr)) {
            _CFSetTSD(__CFTSDKeyRunLoopCntr, (void *)(PTHREAD_DESTRUCTOR_ITERATIONS-1), (void (*)(void *))__CFFinalizeRunLoop);
        }
    }
    return loop;
}
```
## Core Foundation中关于RunLoop的5个类
- CFRunLoopRef
- CFRunLoopModeRef
- CFRunLoopSourceRef
- CFRunLoopTimerRef
- CFRunLoopObserverRef
### 源码结构体
```objc
struct __CFRunLoop {
    CFRuntimeBase _base;
    pthread_mutex_t _lock;			/* locked for accessing mode list */
    __CFPort _wakeUpPort;			// used for CFRunLoopWakeUp 
    Boolean _unused;
    volatile _per_run_data *_perRunData;              // reset for runs of the run loop
    pthread_t _pthread;
    uint32_t _winthread;
    CFMutableSetRef _commonModes;
    CFMutableSetRef _commonModeItems;
    //当前是什么模式
    CFRunLoopModeRef _currentMode;
    //集合
    CFMutableSetRef _modes;
    struct _block_item *_blocks_head;
    struct _block_item *_blocks_tail;
    CFAbsoluteTime _runTime;
    CFAbsoluteTime _sleepTime;
    CFTypeRef _counterpart;
};
```
```objc
typedef struct __CFRunLoopMode *CFRunLoopModeRef;
//简写的结构体
struct __CFRunLoopMode {
    CFStringRef _name;
    CFMutableSetRef _sources0;
    CFMutableSetRef _sources1;
    CFMutableArrayRef _observers;
    CFMutableArrayRef _timers;
}
```
### CFRunLoopModeRef
- CFRunLoopModeRef代表RunLoop的运行模式

- 一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer

- RunLoop启动时只能选择其中一个Mode，作为currentMode

- 如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
  - 不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响

- 如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出

- 常见的2中Mode
  - kCFRunLoopDefaultMode（NSDefaultRunLoopMode）：App的默认Mode，通常主线程是在这个Mode下运行
  - UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响

### CFRunLoopObserverRef
```objc
/* Run Loop Observer Activities */
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
    // 即将进入Loop
    kCFRunLoopEntry = (1UL << 0),
    // 即将处理Timer
    kCFRunLoopBeforeTimers = (1UL << 1),
    // 即将处理Source
    kCFRunLoopBeforeSources = (1UL << 2),
    // 即将进入休眠
    kCFRunLoopBeforeWaiting = (1UL << 5),
    // 刚从休眠中唤醒
    kCFRunLoopAfterWaiting = (1UL << 6),
    // 即将退出Loop
    kCFRunLoopExit = (1UL << 7),
    // 所有的
    kCFRunLoopAllActivities = 0x0FFFFFFFU
};
```
#### 添加Observer监听RunLoop的所有状态
```objc
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry:
                break;
            case kCFRunLoopBeforeTimers:
                break;
            case kCFRunLoopBeforeSources:
                break;
            case kCFRunLoopBeforeWaiting:
                break;
            case kCFRunLoopAfterWaiting:
                break;
            case kCFRunLoopExit:
                break;
            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopCommonModes);
    CFRelease(observer);
```

## RunLoop的运行逻辑
Source0
- 触摸事件处理
- performSelector:onThread:

Source1
- 基于Port的线程间通信
- 系统事件捕捉

Timers
- NSTimer
- performSelector:withObject:afterDelay:

Observers
- 用于监听RunLoop的状态
- UI刷新（BeforeWaiting）
- Autorelease pool（BeforeWaiting）

### RunLoop的运行流程  
01、通知Observers：进入Loop  
02、通知Observers：即将处理Timers  
03、通知Observers：即将处理Sources  
04、处理Blocks 
```objc
//可以添加block到RunLoop中
 CFRunLoopPerformBlock(<#CFRunLoopRef rl#>, <#CFTypeRef mode#>, <#^(void)block#>)
```
05、处理Source0（可能会再次处理Blocks）  
06、如果存在Source1，就跳转到第8步  
07、通知Observers：开始休眠（等待消息唤醒）  
08、通知Observers：结束休眠（被某个消息唤醒）  
- 处理Timer  
- 处理GCD Async To Main Queue  
- 处理Source1 

09、处理Blocks  
10、根据前面的执行结果，决定如何操作  
-  回到第02步  
-  退出Loop 

11、通知Observers：退出Loop  

## Main函数启动的线程信息
```objc
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
  * frame #0: 0x000000010d829b73 DSKeyKonwledge`-[ViewController viewDidLoad](self=0x00007fc2ac4078c0, _cmd="viewDidLoad") at ViewController.m:20:6
    frame #1: 0x00007fff23f3c8ed UIKitCore`-[UIViewController _sendViewDidLoadWithAppearanceProxyObjectTaggingEnabled] + 88
    frame #2: 0x00007fff23f41273 UIKitCore`-[UIViewController loadViewIfRequired] + 1084
    frame #3: 0x00007fff23f4165d UIKitCore`-[UIViewController view] + 27
    frame #4: 0x00007fff246b3d0f UIKitCore`-[UIWindow addRootViewControllerViewIfPossible] + 313
    frame #5: 0x00007fff246b33fd UIKitCore`-[UIWindow _updateLayerOrderingAndSetLayerHidden:actionBlock:] + 219
    frame #6: 0x00007fff246b43c1 UIKitCore`-[UIWindow _setHidden:forced:] + 362
    frame #7: 0x00007fff246c73d4 UIKitCore`-[UIWindow _mainQueue_makeKeyAndVisible] + 42
    frame #8: 0x00007fff24903814 UIKitCore`-[UIWindowScene _makeKeyAndVisibleIfNeeded] + 202
    frame #9: 0x00007fff23acc097 UIKitCore`+[UIScene _sceneForFBSScene:create:withSession:connectionOptions:] + 1671
    frame #10: 0x00007fff24676a92 UIKitCore`-[UIApplication _connectUISceneFromFBSScene:transitionContext:] + 1114
    frame #11: 0x00007fff24676dc1 UIKitCore`-[UIApplication workspace:didCreateScene:withTransitionContext:completion:] + 289
    frame #12: 0x00007fff241633f3 UIKitCore`-[UIApplicationSceneClientAgent scene:didInitializeWithEvent:completion:] + 358
    frame #13: 0x00007fff25a7e0ae FrontBoardServices`-[FBSScene _callOutQueue_agent_didCreateWithTransitionContext:completion:] + 391
    frame #14: 0x00007fff25aa6b41 FrontBoardServices`__94-[FBSWorkspaceScenesClient createWithSceneID:groupID:parameters:transitionContext:completion:]_block_invoke.176 + 102
    frame #15: 0x00007fff25a8bad5 FrontBoardServices`-[FBSWorkspace _calloutQueue_executeCalloutFromSource:withBlock:] + 209
    frame #16: 0x00007fff25aa680f FrontBoardServices`__94-[FBSWorkspaceScenesClient createWithSceneID:groupID:parameters:transitionContext:completion:]_block_invoke + 352
    frame #17: 0x000000010da9f9c8 libdispatch.dylib`_dispatch_client_callout + 8
    frame #18: 0x000000010daa2910 libdispatch.dylib`_dispatch_block_invoke_direct + 295
    frame #19: 0x00007fff25acc7a5 FrontBoardServices`__FBSSERIALQUEUE_IS_CALLING_OUT_TO_A_BLOCK__ + 30
    frame #20: 0x00007fff25acc48b FrontBoardServices`-[FBSSerialQueue _targetQueue_performNextIfPossible] + 433
    frame #21: 0x00007fff25acc950 FrontBoardServices`-[FBSSerialQueue _performNextFromRunLoopSource] + 22
    frame #22: 0x00007fff2038c37a CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17
    frame #23: 0x00007fff2038c272 CoreFoundation`__CFRunLoopDoSource0 + 180
    frame #24: 0x00007fff2038b7b6 CoreFoundation`__CFRunLoopDoSources0 + 346
    frame #25: 0x00007fff20385f1f CoreFoundation`__CFRunLoopRun + 878
     // RunLoop 开始 CFRunLoopRunSpecific
    frame #26: 0x00007fff203856c6 CoreFoundation`CFRunLoopRunSpecific + 567
    frame #27: 0x00007fff2b76adb3 GraphicsServices`GSEventRunModal + 139

    frame #28: 0x00007fff24675187 UIKitCore`-[UIApplication _run] + 912
    // Main函数
    frame #29: 0x00007fff2467a038 UIKitCore`UIApplicationMain + 101
    frame #30: 0x000000010d829f32 DSKeyKonwledge`main(argc=1, argv=0x00007ffee23d5c90) at main.m:17:12
    frame #31: 0x00007fff20256409 libdyld.dylib`start + 1
```
### RunLoop的入口函数
```objc
SInt32 CFRunLoopRunSpecific(CFRunLoopRef rl, CFStringRef modeName, CFTimeInterval seconds, Boolean returnAfterSourceHandled) {     /* DOES CALLOUT */
    CHECK_FOR_FORK();
    if (__CFRunLoopIsDeallocating(rl)) return kCFRunLoopRunFinished;
    __CFRunLoopLock(rl);
    CFRunLoopModeRef currentMode = __CFRunLoopFindMode(rl, modeName, false);
    if (NULL == currentMode || __CFRunLoopModeIsEmpty(rl, currentMode, rl->_currentMode)) {
	Boolean did = false;
	if (currentMode) __CFRunLoopModeUnlock(currentMode);
	__CFRunLoopUnlock(rl);
	return did ? kCFRunLoopRunHandledSource : kCFRunLoopRunFinished;
    }
    volatile _per_run_data *previousPerRun = __CFRunLoopPushPerRunData(rl);
    CFRunLoopModeRef previousMode = rl->_currentMode;
    rl->_currentMode = currentMode;
    int32_t result = kCFRunLoopRunFinished;

    // 通知Observer: 进入Loop
	if (currentMode->_observerMask & kCFRunLoopEntry ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopEntry);
    // 具体要做的事情
	result = __CFRunLoopRun(rl, currentMode, seconds, returnAfterSourceHandled, previousMode);
    //  通知Observer: 退出Loop
	if (currentMode->_observerMask & kCFRunLoopExit ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);

        __CFRunLoopModeUnlock(currentMode);
        __CFRunLoopPopPerRunData(rl, previousPerRun);
	rl->_currentMode = previousMode;
    __CFRunLoopUnlock(rl);
    return result;
}
```
### __CFRunLoopRun源码(精简之后的)
```objc
/* rl, rlm are locked on entrance and exit */
static int32_t __CFRunLoopRun(CFRunLoopRef rl, CFRunLoopModeRef rlm, CFTimeInterval seconds, Boolean stopAfterHandle, CFRunLoopModeRef previousMode) {
 
    int32_t retVal = 0;
    do {
    // 通知 Observer:即将处理Timers
     __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers);
     // 通知observer: 即将处理Sources
      __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);
    // 处理Blocks
	__CFRunLoopDoBlocks(rl, rlm);
 
     // 处理Source0，如果返回YES，会在处理Blocks
        if (_CFRunLoopDoSources0(rl, rlm, stopAfterHandle)) {
            // 处理Blocks
            __CFRunLoopDoBlocks(rl, rlm);
	}

        Boolean poll = sourceHandledThisLoop || (0ULL == timeout_context->termTSR);

    // 判断有无Source1 
         if (__CFRunLoopServiceMachPort(dispatchPort, &msg, sizeof(msg_buffer), &livePort, 0, &voucherState, NULL)) {
             // 如果有Sources1 ，就跳转到handle_msg
                goto handle_msg;
            }

    // 通知Observers: 即将休眠 
    __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);
    // 开始休眠
	__CFRunLoopSetSleeping(rl);
	 

        CFAbsoluteTime sleepStart = poll ? 0.0 : CFAbsoluteTimeGetCurrent();
 
    
    // 等待别的消息来唤醒当前线程
        __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY, &voucherState, &voucherCopy);
            
           
         
	__CFRunLoopUnsetSleeping(rl);
	 // 通知Observer:结束休眠
     __CFRunLoopDoObservers(rl, rlm, kCFRunLoopAfterWaiting);

        handle_msg:;
         if (被timer唤醒) {
             // 处理Timers
          __CFRunLoopDoTimers(rl, rlm, mach_absolute_time())
        }
        else if (被GCD唤醒) {
            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
        } else {
            // 被Source1唤醒
		sourceHandledThisLoop = __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply) || sourceHandledThisLoop;
        } 
  
    // 处理Blocks
	__CFRunLoopDoBlocks(rl, rlm);
        
    //设置返回值
	if (sourceHandledThisLoop && stopAfterHandle) {
	    retVal = kCFRunLoopRunHandledSource;
        } else if (timeout_context->termTSR < mach_absolute_time()) {
            retVal = kCFRunLoopRunTimedOut;
	} else if (__CFRunLoopIsStopped(rl)) {
            __CFRunLoopUnsetStopped(rl);
	    retVal = kCFRunLoopRunStopped;
	} else if (rlm->_stopped) {
	    rlm->_stopped = false;
	    retVal = kCFRunLoopRunStopped;
	} else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {
	    retVal = kCFRunLoopRunFinished;
	}
        voucher_mach_msg_revert(voucherState);
        os_release(voucherCopy);
    } while (0 == retVal);

    if (timeout_timer) {
        dispatch_source_cancel(timeout_timer);
        dispatch_release(timeout_timer);
    } else {
        free(timeout_context);
    }

    return retVal;
}
```
## RunLoop休眠的实现原理
用户态->内核态
```objc
mach_msg()
```
内核态：等待消息，没有消息就让其线程休眠，有消息就唤醒回到用户态
## RunLoop在实际开发中的应用
### 控制线程生命周期（线程保活）
### 解决NSTimer在滑动时停止工作的问题
### 监控应用卡顿
### 性能优化
## NSRunLoop的run方法是无法停止的，它专门用于开启一个永不销毁的线程
```objc
[[NSRunLoop currentRunLoop] run];
```
## 线程保活
### 方式一（OC）：
```objc
self.stopped = NO;

__weak typeof(self) weakSelf = self;

self.innerThread = [[MJThread alloc] initWithBlock:^{
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    // 一定要判断self存在，这里会存在self为空的情况
    while (weakSelf && !weakSelf.isStopped) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}];

[self.innerThread start];
```
### 方式二（C语言）:
```objc
  self.innerThread = [[MJThread alloc] initWithBlock:^{
            NSLog(@"begin----");
            
            // 创建上下文（要初始化一下结构体）
            CFRunLoopSourceContext context = {0};
            
            // 创建source
            CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
            
            // 往Runloop中添加source
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
            
            // 销毁source
            CFRelease(source);
            
            // 启动
            //第3个参数：returnAfterSourceHandled，设置为true，代表执行完source后就会退出当前loop
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false); 
            NSLog(@"end----");
        }];
        [self.innerThread start];
```
### 停止RunLoop
```objc
if (!self.innerThread) return;
//这里的waitUntilDone最好用YES，直到停止之后再执行
[self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];


- (void)__stop
{
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}
```


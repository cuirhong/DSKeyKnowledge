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
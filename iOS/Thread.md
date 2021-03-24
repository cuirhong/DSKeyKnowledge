# 多线程
## iOS中常见的多线程方案
### pthread
- 简介：
  - 一套通用的多线程API
  - 适用于Unix/Linux/Windows等系统
  - 跨平台/可移植
  - 使用难度大
- 语言：C 
- 自己管理线程生命周期
### NSThread
- 简介：
  - 使用更加面向对象
  - 简单易用，可直接操作线程对象
- 语言：OC
- 自己管理线程生命周期
### GCD
- 简介：
  - 旨在替代NSThread等线程技术
  - 充分利用设备的多核
- 语言： C
- 自动管理线程生命周期
### NSOperation
- 简介:
  - 基于GCD（底层是GCD）
  - 比GCD多了一些更简单是用的功能
  - 使用更加面向对象
- 语言： OC
- 自动管理线程生命周期

⚠️ NSThread、GCD和NSOperation底层都是pthread

## GCD的常用函数
### GCD中有2个用来执行任务的函数
- 用同步的方式执行任务
```objc
/**
queue：队列
block：任务
*/
dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
```
- 用异步的方式执行任务
```objc
dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
```
### GCD源码：https://github.com/apple/swift-corelibs-libdispatch

## GCD并发队列
### GCD的队列可以分为2大类型
- 并发队列（Concurrent Dispatch Queue）
  - 可以让多个任务并发（同时）执行（自动开启多个线程同时执行任务）
  - 并发功能只有在异步（dispatch_async）函数下才有效
- 串行队列（Serial Dispatch Queue）
  - 让任务一个接着一个地执行（一个任务执行完毕后，再执行下一个任务）

## 同步、异步；并发、串行
### 同步和异步主要影响：能不能开启新的线程
- 同步：在当前线程中执行任务，不具备开启新线程的能力
- 异步：在新的线程中执行任务，具备开启新线程的能力
### 并发和串行主要影响：任务的执行方式
- 并发：多个任务并发（同时）执行
- 串行：一个任务执行完毕后，再执行下一个任务
### 总结：
- dispathc_aync和dispatch_async用来控制是否要开启新的线程
- 队列的类型，决定了任务的执行方式（并发、串行）
## 各种队列的执行效果
![图片不见了](./static/images/thread-queue.png)
## 死锁
```objc
//以下代码是在主线程执行的，会不会产生死锁？--->会产生死锁
// 队列的特点：排队，FIFO，First In first Out(先进先出)
dispatch_queue_t queue = dispatch_get_main_queue();
dispatch_sync(queue,^{
});


//以下代码是在主线程执行的，会不会产生死锁？--->不会产生死锁
dispatch_queue_t queue = dispatch_get_main_queue();
dispatch_async(queue,^{
});
```
```objc
// 以下代码是在主线程执行的，会不会产生死锁？--->会产生死锁
NSLog(@"执行任务1");
dispatch_queue_t queue = dispatch_queue_create("myqueue",DISPATCH_QUEUE_SERIAL);
dispatch_async(queue,^{
    NSLog(@"执行任务2");
    //这里也会产生死锁
    dispatch_sync(queue,^{
        NSLog(@"执行任务3");
    });
    NSLog(@"执行任务4");
});
NSLog(@"执行任务5");

//最终打印结果是 1->5->2；到sync的时候就产生死锁了
```
⚠️ 使用sync函数往**当前串行队列**中添加任务，会卡住当前的串行队列（产生死锁）  
⚠️ DISPATCH_QUEUE_SERIAL：同步  
⚠️ DISPATCH_QUEUE_CONCURRENT （异步）

## 面试题
### 面试题一：
```objc
   dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"1");
        // 这句代码的本质是往Runloop中添加定时器
        [self performSelector:@selector(test) withObject:nil afterDelay:.0];
        NSLog(@"3");
    });

- (void)test{
    NSLog(@"2");
}

// 以上最终打印结果为1,3
```
```objc
//如果换成，打印结果则为1、2、3
[self performSelector:@selector(test) withObject:nil];
// 以上代码底层实现就是obj_sendMsg
```
- [self performSelector:@selector(test) withObject:nil afterDelay:.0]的本质是往Runloop中添加定时器
```objc
- (void) performSelector: (SEL)aSelector
	      withObject: (id)argument
	      afterDelay: (NSTimeInterval)seconds
{
  NSRunLoop		*loop = [NSRunLoop currentRunLoop];
  GSTimedPerformer	*item;

  item = [[GSTimedPerformer alloc] initWithSelector: aSelector
					     target: self
					   argument: argument
					      delay: seconds];
  [[loop _timedPerformers] addObject: item];
  RELEASE(item);
  [loop addTimer: item->timer forMode: NSDefaultRunLoopMode];
}
```
- 子线程默认没有启动RunLoop
## 面试题二
```objc
- (void)test
{
    NSLog(@"2");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1");
    }];
    [thread start];
    
    [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
}

//以上打印结果是 ： 1 ，然后奔溃，thread已经没有启动RunLoop，打印1之后已经退出
```
## GNUstep
### GNUstep是GNU计划的项目之一，它将Cocoa的OC库重新开源实现了一遍
 
### 源码地址（static文件下已有部分源码）：http://www.gnustep.org/resources/downloads.php

### 虽然GNUstep不是苹果官方源码，但还是具有一定的参考价值

## 队列组的使用
```objc
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("my_queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 添加异步任务
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务1-%@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务2-%@", [NSThread currentThread]);
        }
    });
    
    // 等前面的任务执行完毕后，会自动执行这个任务
//    dispatch_group_notify(group, queue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            for (int i = 0; i < 5; i++) {
//                NSLog(@"任务3-%@", [NSThread currentThread]);
//            }
//        });
//    });
    
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        for (int i = 0; i < 5; i++) {
//            NSLog(@"任务3-%@", [NSThread currentThread]);
//        }
//    });
    
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务3-%@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务4-%@", [NSThread currentThread]);
        }
    });
```
## 多线程安全问题
### 线程同步方案
```objc
OSSpinLock
os_unfair_lock
pthread_mutex
dispatch_semaphore
dispatch_queue(DISPATCH_QUEUE_SERIAL)
NSLock
NSRecursiveLock
NSCondition
NSConditionLock
@synchronized
```
### OSSpinLock
#### OSSpinLock叫做”自旋锁”，等待锁的线程会处于忙等（busy-wait）状态，一直占用着CPU资源
```objc
#import <libkern/OSAtomic.h>

 //初始化锁(只能初始化一次)
    self.lock = OS_SPINLOCK_INIT;
    
    //加锁
    OSSpinLockLock(&_lock);
    
    /**执行代码*/

    //解锁
    OSSpinLockUnlock(&_lock);
```
尝试加锁，如果被别人加锁了，就不管了，直接往下执行
```objc
if (OSSpinLockTry(&_lock)){
    /**执行代码*/

    //解锁
    OSSpinLockUnlock(&_lock);
}
```
#### 目前已经不再安全，可能会出现优先级反转问题
- 如果等待锁的线程优先级较高，它会一直占用着CPU资源，优先级低的线程就无法释放锁
- 需要导入头文件#import <libkern/OSAtomic.h>

### os_unfair_lock
#### os_unfair_lock用于取代不安全的OSSpinLock ，从iOS10开始才支持
#### 从底层调用看，等待os_unfair_lock锁的线程会处于休眠状态，并非忙等
#### 需要导入头文件#import <os/lock.h>
```objc
  self.lock = OS_UNFAIR_LOCK_INIT;

    os_unfair_lock_lock(&_lock);
    
    /**执行代码*/

    os_unfair_lock_unlock(&_lock);
```
### pthread_mutex
#### mutex叫做”互斥锁”，等待锁的线程会处于休眠状态
#### 需要导入头文件#import <pthread.h>
```objc
//初始化属性
pthread_mutexattr_t attr;
pthread_mutexattr_init(&attr);
pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_DEFAULT);
//初始化锁
pthread_mutex_init(&_mutex, &attr);
//销毁属性
pthread_mutexattr_destroy(&attr);

//加锁
pthread_mutex_lock(&_mutex);

/**执行代码*/

//解锁
pthread_mutex_unlock(&_mutex);

 //销毁锁
pthread_mutex_destroy(&_mutex)
```
```objc
//线程等待信号
pthread_cond_wait(&_cond,&_mutex)

//发送信号(激活一个等待该条件的线程)
pthread_cond_signal(&_cond)

//激活所有等待该条件的线程
pthread_cond_broadcast(&_cond)


//销毁资源
pthread_cond_destroy(&_cond)
```

```objc
#define PTHREAD_MUTEX_NORMAL		0
#define PTHREAD_MUTEX_ERRORCHECK	1
// 可递归锁
#define PTHREAD_MUTEX_RECURSIVE		2
#define PTHREAD_MUTEX_DEFAULT		PTHREAD_MUTEX_NORMAL
```
#### 递归锁：允许同一个线程对一把锁进行重复加锁

### NSLock、NSRecursiveLock
#### NSLock是对mutex普通锁的封装
```objc
- (BOOL)tryLock;
- (BOOL)lockBeforeDate:(NSDate)limit;
```
#### NSLock是对mutex递归锁的封装

### NSCondition
#### NSCondition是对mutex和cond的封装
```objc
- (void)wait;
- (BOOL)waitUntilDate:(NSDate*)limit;
- (void)signal;
- (void)broadcast;
```
### NSConditionLock
#### NSConditionLock是对NSCondition的进一步封装，可以设置具体的条件值
```objc
- (instancetype)initWithCondition:(NSInteger)condition;
@property (readonly) NSInteger condition;
- (void)lockWhenCondition:(NSInteger)conditioin;
- (BOOL)tryLock;
- (BOOL)tryLockWhenCondition:(NSInteger)condition;
- (void)unlockWithCondition:(NSInteger)condition;
- (BOOL)lockBeforeDate:(NSDate*)limit;
- (BOOL)lockWhenCondition:(NSInteger)condition beforeDate:(NSDate *)limit;
```
### dispatch_queue
#### 直接使用GCD的串行队列，也是可以实现线程同步的
```objc
dispatch_queue_t queue = dispatch_queue_create("lock_queue",DISPATCH_QUEUE_SERIAL);
dispatch_sync(queue,^{
    //任务
});
```
### dispatch_semaphore
#### semaphore叫做“信号量”
#### 信号量的初始值，可以用来控制线程并发访问的最大数量
#### 信号量的初始值为1，代表同时只允许1条线程访问资源，保证线程同步
```objc
int value = 1;
//初始化信号量
dispatch_semaphore_t semaphore = dispatch_semaphore_create(value);
//如果信号量的值<=0，当线程就会进入休眠等待（直到信号量的值>0）
//如果信号量的值>0，就减1，然后往下执行后面的代码
dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
//让信号量的值加1
dispatch_semaphore_signal(semaphore);
```
### @synchronized
#### @synchronized是对mutex的递归锁的封装
#### 源码查看：objc4中的objc-sync.mm文件
```objc
int objc_sync_enter(id obj)
{
    int result = OBJC_SYNC_SUCCESS;

    if (obj) {
        SyncData* data = id2data(obj, ACQUIRE);
        ASSERT(data);
        data->mutex.lock();
    } else {
        // @synchronized(nil) does nothing
        if (DebugNilSync) {
            _objc_inform("NIL SYNC DEBUG: @synchronized(nil); set a breakpoint on objc_sync_nil to debug");
        }
        objc_sync_nil();
    }

    return result;
}

// SyncData就是对mutex的封装（递归锁）
typedef struct alignas(CacheLineSize) SyncData {
    struct SyncData* nextData;
    DisguisedPtr<objc_object> object;
    int32_t threadCount;  // number of THREADS using this block
    recursive_mutex_t mutex;
} SyncData;

```
#### @synchronized(obj)内部会生成obj对应的递归锁，然后进行加锁、解锁操作
```objc
@synchronized([self class]){
    //任务
}
```
## iOS线程同步方案性能比较
### 性能从高到底排序
```objc
os_unfaire_lock
OSSpinLock
dispatch_semaphore(推荐)
pthread_mutex（推荐）
dispatch_queue(DISPATCH_QUEUE_SERIAL)
NSLock
NSCondition
pthread_mutex(recursive)
NSRecursiveLock
NSConditionLock
@synchronized
```
## 自旋锁、互斥锁比较
### 什么情况使用自旋锁比较划算？
- 预计线程等待锁的时间比较短
- 加锁的代码（临界区）经常被调用，但竞争情况很少发生
- CPU资源不紧张
- 多核处理器
### 什么情况下使用互斥锁比较划算
- 预计线程等待锁的时间较长
- 单核处理器
- 临界区有IO操作
- 临界区代码复杂或者循环量大
- 临界区竞争非常激烈

## atomic
### tomic用于保证属性setter、getter的原子性操作，相当于在getter和setter内部加了线程同步的锁
### 可以参考源码objc4的objc-accessors.mm
### 它并不能保证使用属性的过程是线程安全的
set方法的源码
```objc
static inline void reallySetProperty(id self, SEL _cmd, id newValue, ptrdiff_t offset, bool atomic, bool copy, bool mutableCopy)
{
    if (offset == 0) {
        object_setClass(self, newValue);
        return;
    }

    id oldValue;
    id *slot = (id*) ((char*)self + offset);

    if (copy) {
        newValue = [newValue copyWithZone:nil];
    } else if (mutableCopy) {
        newValue = [newValue mutableCopyWithZone:nil];
    } else {
        if (*slot == newValue) return;
        newValue = objc_retain(newValue);
    }

    if (!atomic) {
        oldValue = *slot;
        *slot = newValue;
    } else {
        spinlock_t& slotlock = PropertyLocks[slot];
        slotlock.lock();
        oldValue = *slot;
        *slot = newValue;        
        slotlock.unlock();
    }

    objc_release(oldValue);
}
```
## iOS中的读写安全方案
### IO操作，文件操作
- 从文件中读取内容
- 往文件中写入内容
### 思考如何实现如下场景
- 同一时间，只能有1条线程进行写的操作
- 同一时间，允许有多个线程进行读的操作
- 同一时间，不允许既有写又有读的操作
### 上面的场景就是典型的“多读单写”，经常用于文件等数据的读取操作，iOS中的实现方案有
- pthread_rwlock（读写锁）
- dispatch_barrier_async(异步栅栏调用)
### pthread_rwlock
```objc
//初始化锁
pthread_rwlock_t lock;
pthread_rwlock_init(&lock,NULL);
//读-加锁
pthread_rwlock_rdlock(&lock);
//读-尝试加锁
pthread_rwlock_tryrdlock(&lock);
//写-加锁
pthread_rwlock_wrlock(&lock);
//写-尝试加锁
pthread_rwlock_trywrlock(&lock);
//解锁
pthread_rwlock_unlock(&lock);
//销毁
pthread_rwlock_destroy(&lock);
```
### dispatch_barrier_async
#### 这个函数传入的并发队列必须是自己通过dispatch_queue_cretate创建的
#### 如果传入的是一个串行或是一个全局的并发队列，那dispatch_barrier_async便等同于dispatch_async函数的效果
```objc
dispatch_queue_t queue = dispatch_queue_create("rw_queue",DISPATCH_QUEUE_CONCURRENT)
//读
dispatch_async(queue,^{

})
//写
dispatch_barrier_async(queue,^{
    
})
```

## 面试题
- 你理解的多线程？

- iOS的多线程方案有哪几种？你更倾向于哪一种？

- 你在项目中用过 GCD 吗？

- GCD 的队列类型

- 说一下 OperationQueue 和 GCD 的区别，以及各自的优势

- 线程安全的处理手段有哪些？

- OC你了解的锁有哪些？在你回答基础上进行二次提问；
  - 追问一：自旋和互斥对比？
  - 追问二：使用以上锁需要注意哪些？
  - 追问三：用C/OC/C++，任选其一，实现自旋或互斥？口述即可！

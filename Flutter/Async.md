# 异步和网络请求
## Future
```dart
future.then((value){
  
}).catchError((error){
  
}).whenComplete((){
  
});
```
### 链式调用

## await - async
```dart
/**
   * async * 是一个生成器，python中常见
   */
  Future test() async{
    await sleep(Duration(seconds: 3));
    //直接返回结果，内部会自动包裹一个Future
    return "结果";
  }
```
## 多核CPU的利用
在Dart中，有一个Isolate的概念，它是什么呢？
- 我们已经知道Dart是单线程的，这个线程有自己可以访问的内存空间以及需要运行的事件循环；
- 我们可以将这个空间系统称之为是一个Isolate；
- 比如Flutter中就有一个Root Isolate，负责运行Flutter的代码，比如UI渲染、用户交互等等；

在 Isolate 中，资源隔离做得非常好，每个 Isolate 都有自己的 Event Loop 与 Queue，
- Isolate 之间不共享任何资源，只能依靠消息机制通信，因此也就没有资源抢占问题。
- 但是，如果只有一个Isolate，那么意味着我们只能永远利用一个线程，这对于多核CPU来说，是一种资源的浪费。
 
如果在开发中，我们有非常多耗时的计算，完全可以自己创建Isolate，在独立的Isolate中完成想要的计算操作。

```dart
Isolate.spawn(calc, 100);
void calc(int count){
     //耗时操作
}
```
收到返回的结果 :
```dart
//1.创建管道
ReceivePort receivePort = ReceivePort();
//2.创建isolate
Isolate isolate = await Isolate.spawn<SendPort>(calc, receivePort.sendPort);
//3.监听管道
receivePort.listen((message){

});
void calc(SendPort sendPort){
     //耗时操作
    return sendPort.send("结果");
}
```
双向通信：
```dart
void runCalc() async{
  var result = await compute(calc,100);
  print(result)
}

//这个方法必须是全局的，如果放在对象里面只有对象才能执行
int calc(int count){
  //耗时操作
  return count + 1;
}
```


## Flutter 线程
四大Runner
- UI Runner
- GPU Runner
- IO Runner
- Platform Runnner

## 网络请求
1. HttpClient
1. http  
1. dio (dart io，axios: ajax io system)


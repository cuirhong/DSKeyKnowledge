# 部件
## Widget
### 万物皆是widget
 
### build方法的解析
- Flutter在拿到我们自己创建的StatelessWidget时，就会被执行它的build方法
- 我们需要在build方法中告诉Flutter，我们的Widget希望渲染什么元素，比如Text
- StatelessWidget没办法主动去执行build方法，当我们使用的数据发生改变时，build方法会被重新执行 
### build方法在什么情况下被执行呢？
- StatelessWidget第一次被插入到Widget树中时（也就是第一次被创建时）
- 当我们的父Widget（parent widget）发生改变时，子Widget会被重新构建
- 如果我们的Widget依赖InheritedWidget的一些数据，InheritedWidget数据发生改变时


## 生命周期
### StatelessWidget的生命周期
1. 构造函数
1. build函数
### StatefulWidget的生命周期
- 在下图中，灰色部分的内容是Flutter内部操作的，我们并不需要手动去设置它们；
- 白色部分表示我们可以去监听到或者可以手动调用的方法；
![](./Static/images/stateful-widget-live.png)

- mounted是State内部设置的一个属性
- dirty state的含义是脏的State,它实际是通过一个Element的东西（我们还没有讲到Flutter绘制原理）的属性来标记的；将它标记为dirty会等待下一次的重绘检查，强制调用build方法来构建我们的Widget；
- clean state的含义是干净的State,它表示当前build出来的Widget，下一次重绘检查时不需要重新build；

#### 执行StatefulWidget中相关的方法：

  - 执行StatefulWidget的构造函数（Constructor）来创建出StatefulWidget；

  - 执行StatefulWidget的createState方法，来创建一个维护StatefulWidget的State对象；

#### 调用createState创建State对象时，执行State类的相关方法：

  - 执行State类的构造方法（Constructor）来创建State对象；

  - 执行initState，我们通常会在这个方法中执行一些数据初始化的操作，或者也可能会发送网络请求；注意：这个方法是重写父类的方法，必须调用super，因为父类中会进行一些其他操作；并且如果你阅读源码，你会发现这里有一个注解（annotation）：@mustCallSuper

  - 执行didChangeDependencies方法，这个方法在两种情况下会调用
    - 调用initState会调用；

    - 从其他对象中依赖一些数据发生改变时，比如前面我们提到的InheritedWidget（这个后面会讲到）；

  - Flutter执行build方法，来看一下我们当前的Widget需要渲染哪些Widget；

  - 当前的Widget不再使用时，会调用dispose进行销毁；

  - 手动调用setState方法，会根据最新的状态（数据）来重新调用build方法，构建对应的Widgets；

  - 执行didUpdateWidget方法是在当父Widget触发重建（rebuild）时，系统会调用didUpdateWidget方法；

 
## 细微知识点
- 形成的是一个Widget树，类似于组件化开发
- material：是一套设计风格
- @requeired : 必须的，注解告诉我某些命名可选参数是必传的
- @immutable : 不可变的注解，里面所有的东西都必须是final的
- StatefulWidget：可变的Widget 
- StatelessWidget：不可变的Widget
- android/iOS命名式编程器，没有状态的概念，只说属性和数据；vue\react\angular声明式编程（管理好状态）；Flutter开发中，所有的Widget都不能定义状态
- Scaffold : 相当于UIViewController或者Activity
- 快速创建一个statelessWidget
  > 快捷方式: stl(根据代码提示)
- 快速创建新的Widget包裹一个Widget：光标确定到那个位置，option+回车即可
- 快速查看一个类的子类，光标移动到这个类，然后commond + option + B
- State加_:状态这个类只是给Widget使用
  ```dart
  class _DSContentState extends State<DSContentBody>{
    @override
    Widget build(BuildContext context) {
       // TODO: implement build
       return null;
      }
  }
  ```
- StateFulWidget的build方法放在State中
  - build出来的Widget是需要依赖State中的变量(状态/数据)
  - 在Flutter的运行过程中:
    - Widget是不断的销毁和创建的
    - 当我们自己的状态发生改变时，并不希望重新状态一个新的State

- 将已经存在的StatelessWidget转换成一个StatefulWidget : 直接使用快捷键：将光标放在StatelessWidget名字，然后直接[option + 回车]即可看到转换的入口
- 将已经build的一个Widget抽取成一个class，快捷键：将光标放在Widget上面，然后直接【option+回车+w】即可

## 刷新界面setState方法的源代码
```dart
  @protected
  void setState(VoidCallback fn) {
    assert(fn != null);
    assert(() {
      if (_debugLifecycleState == _StateLifecycle.defunct) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('setState() called after dispose(): $this'),
          ErrorDescription(
            'This error happens if you call setState() on a State object for a widget that '
            'no longer appears in the widget tree (e.g., whose parent widget no longer '
            'includes the widget in its build). This error can occur when code calls '
            'setState() from a timer or an animation callback.'
          ),
          ErrorHint(
            'The preferred solution is '
            'to cancel the timer or stop listening to the animation in the dispose() '
            'callback. Another solution is to check the "mounted" property of this '
            'object before calling setState() to ensure the object is still in the '
            'tree.'
          ),
          ErrorHint(
            'This error might indicate a memory leak if setState() is being called '
            'because another object is retaining a reference to this State object '
            'after it has been removed from the tree. To avoid memory leaks, '
            'consider breaking the reference to this object during dispose().'
          ),
        ]);
      }
      if (_debugLifecycleState == _StateLifecycle.created && !mounted) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('setState() called in constructor: $this'),
          ErrorHint(
            'This happens when you call setState() on a State object for a widget that '
            'hasn\'t been inserted into the widget tree yet. It is not necessary to call '
            'setState() in the constructor, since the state is already assumed to be dirty '
            'when it is initially created.'
          ),
        ]);
      }
      return true;
    }());
    final dynamic result = fn() as dynamic;
    assert(() {
      if (result is Future) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('setState() callback argument returned a Future.'),
          ErrorDescription(
            'The setState() method on $this was called with a closure or method that '
            'returned a Future. Maybe it is marked as "async".'
          ),
          ErrorHint(
            'Instead of performing asynchronous work inside a call to setState(), first '
            'execute the work (without updating the widget state), and then synchronously '
           'update the state inside a call to setState().'
          ),
        ]);
      }
      // We ignore other types of return values so that you can do things like:
      //   setState(() => x = 3);
      return true;
    }());
    //刷新界面的原理
    _element.markNeedsBuild();
  }
```
## Button
### FlatButton
- 默认有一个最小的宽高，因为继承MaterialButton 
```dart
//取消最小的宽高设置:包裹一个ButtonTheme
ButtonTheme(
  minWidth:30,
  height:30,
  child:FlatButton()
)
```
## Image
### 占位图
```dart
FadeImage(
  placeholder:AssetImage("assets/images/juren.jpeg"),
  image:NetworkImage(imageUrl)
)
```
- 图片缓存：1000张和100M

## 单子布局
- Align->Center
- Padding
- Container
## 多子布局
### Row
- MainAxisAlignment 
- 水平方向也是希望包裹内容,那么设置mainAxisSize = min
- CrossAxisAlignment
  - baseline(必须有文本才有效果):必须和textBaseline一起使用
  - stretch : 先让Row占据交叉轴尽可能大的空间，将所有的子Widget交叉轴的高度，拉伸到最大

## Flexible
### Expanded : 一般都是用这个，拉伸操作，是Flexible的子类
## Stack
- 默认大小是包裹内容，默认是从左上角开始排列
- fit:expand 将子元素拉伸到尽可能大
## Positioned
- 绝对布局
```dart
Positioned(
  right:20,
  bottom:10,
  child:
)
```
## ListView
### ListView是都会创建item
### ListBuilder
```dart
 ListView.builder({
   itemCount:10,
   itemBuilder:(BuildContext ctx, int index){
   }
 })
```
### ListView.separated
```dart
ListView.separated({
  itemCount:10,
  itemBuilder:
  separatorBuilder:(BuildContext ctx,int index){
    return Divider(
      //分割线的高度
      thickness:10,
      //整个的高度
      height:30,
    )
  }
})
```
## GridView
### GridView()
```dart
GridView(
  gridDelegate:
  chidren:List.generate()
)
```
### GridView.count
### GridView.extent
### GridView.builder
## sliver
### CustomScrollView
### SliverSafeArea滚动区域的安全区域（适配刘海）
### SliverPadding 滚动区域的间隙
### SliverAppBar 顶部appBar和Banner一同使用

## 监听滚动 
### 方式一：controller
```dart
ScrollController 
```
- 可以设置默认offset
- 监听滚动，也可以监听滚动的位置
- 但是不能监听开始和结束滚动
### 方式二：NotificationListener
```objc
NotificationListener(
  onNotification: (ScrollNotification notification){
    if (notification is ScrollStartNotification){
      //开始滚动
    }else if (notification is ScrollEndNotification) {
      //结束滚动
    }else if (notification is ScrollUpdateNotification){
      print("当前滚动的位置${notification.metrics.pixels}");
      print("总滚动的距离:${notification.metrics.maxScrollExtent}");
    }
    //多个NotificationListener，如果返回true就会取消冒泡，false就会继续冒泡
    return true;
  },
);
```

## 快速生成toString方法  
快捷键：Commond + N (还有其他很多，比如构造器等)

## 快速根据json生成一个转换模型的代码  
- 工具链接：https://javiercbk.github.io/json_to_dart/
> FeHelper可以帮助API请求数据查看工具
- Android studio 自带一个插件：FlutterJsonBeanFactory，安装之后，可以自动根据json生成Dart类，但是也有弊端(属性不对等)

## 打印所在文件/行/列
```dart

```
# 事件和路由

## Listener
```dart
  Listener(
      onPointerDown: ,
      onPointerMove: ,
      onPointerUp: ,
    );
```

## GestureDetector
```dart
        GestureDetector(
            onTapDown: (details) {
              //手指按下
            },
            onTapUp: (details) {
              //手指抬起
            },
            onTapCancel: () {
              //手势取消
            },
            onTap: () {
              //手势点击
            },
            onDoubleTap: () {
              //手指双击
            },
        )
```
### 点击穿透
两个GuestureDetector存在嵌套关系，导致点击会偶尔出现穿透（bug出现），解决方案:
使用Stack布局，避免嵌套关系 ,阻止点击 : IgnorePointer
```dart
IgnorePointer(
    /// 这样里面的点击就无效了
    child:GestureDetector(
        onTapDown:(details){

        }
    )
)
```
 

## 两个Container（包裹关系）
里面的Container会产生布局的问题(自动和外层Container大小一致）
```dart
Container(
    width:300,
    height:300,
    child:Container(
        //里面这个Container也会是300的高度，解决这个问题，设置上面的Container alignment
        width:100,
        height100
    )
)
```

## 跨组件事件的传递
### EventBus
- 创建全局的EventBus
```dart
import 'package:event_bus/event_bus.dart';
EventBus eventBus = EventBus();
```
- 监听事件的类型
```dart
eventBus.on<UserLoggedInEvent>().listen((event) {
  // All events are of type UserLoggedInEvent (or subtypes of it).
  print(event.user);
});
```
- 发出事件
```dart
User myUser = User('Mickey');
eventBus.fire(UserLoggedInEvent(myUser));
```

## Flutter路由
- Route
- Navigator
### Route 
建议使用 MaterialPageRoute

事实上MaterialPageRoute并不是Route的直接子类：

- MaterialPageRoute在不同的平台有不同的表现
- 对Android平台，打开一个页面会从屏幕底部滑动到屏幕的顶部，关闭页面时从顶部滑动到底部消失
- 对iOS平台，打开一个页面会从屏幕右侧滑动到屏幕的左侧，关闭页面时从左侧滑动到右侧消失
- 当然，iOS平台我们也可以使用CupertinoPageRoute
```dart
MaterialPageRoute -> PageRoute -> ModalRoute -> TransitionRoute -> OverlayRoute -> Route
```

### Navigator 
> 并不需要，我们开发中使用的MaterialApp、CupertinoApp、WidgetsApp它们默认是有插入Navigator的  

```dart
Navigator.of(context).push(route)

Navigator.push(context, MaterialPageRoute(
  builder: (ctx){
    return DSDetailPage();
  }
));
```

### 自定义导航栏返回按钮
```dart
AppBar(
  leading:
)
```

### 监听返回按钮
方式一、自定义导航栏定义监听  
方式二、
```dart
WillPopScope(
  child:
  onWillPop:(){
    //当返回为true时，可以自动返回（flutter帮助我们执行返回操作），当返回为false时，自行写返回代码
    return Future.value(true);
  }
)
```

### 配置路由
```dart
MaterialApp(
  routes:{
    //首页也可以在这里默认配置
    "/":(ctx)->HomePage(),
  }
  initialRoute:"/"
);
```

###  路由传递参数
```dart
Navigator.of(context).pushNamed("",arguments: "");
final result = ModalRoute.of(context).settings.arguments
```
返回页面拿到参数
```dart
Future result = Navigator.of(context).pop("返回的参数");
result.then((res){
   //res就是 “返回的参数”
})
```

### 路由需要传递参数
- 参数传递
```dart
Navigator.of(context).pushNamed(HYDetailPage.routeName, arguments: "a home message of naned route");
```
```dart
 Widget build(BuildContext context) {
    // 1.获取数据
    final message = ModalRoute.of(context).settings.arguments;
  }
```
- 路由钩子

  - 当我们通过pushNamed进行跳转，但是对应的name没有在routes中有映射关系，那么就会执行onGenerateRoute钩子函数；
  - 我们可以在该函数中，手动创建对应的Route进行返回；
  - 该函数有一个参数RouteSettings，该类有两个常用的属性：
    > name: 跳转的路径名称  
    > arguments：跳转时携带的参数

```dart
onGenerateRoute: (settings) {
  if (settings.name == "/about") {
    return MaterialPageRoute(
      builder: (ctx) {
        return HYAboutPage(settings.arguments);
      }
    );
  }
  returnnull;
}
```
- onUnknownRoute
```dart
onUnknownRoute: (settings) {
  return MaterialPageRoute(
    builder: (ctx) {
      return UnknownPage();
    }
  );
}
```
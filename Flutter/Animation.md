# 动画
## Animation
```dart
abstractclass Animation<T> extends Listenable implements ValueListenable<T> {
  const Animation();
  
  // 添加动画监听器
  @override
  void addListener(VoidCallback listener);
  
  // 移除动画监听器
  @override
  void removeListener(VoidCallback listener);
	
  // 添加动画状态监听器
  void addStatusListener(AnimationStatusListener listener);
	
  // 移除动画状态监听器
  void removeStatusListener(AnimationStatusListener listener);
	
  // 获取动画当前状态
  AnimationStatus get status;
	
  // 获取动画当前的值
  @override
  T get value;
```
## AnimationController
```dart
class AnimationController extends Animation<double>
  with AnimationEagerListenerMixin, AnimationLocalListenersMixin, AnimationLocalStatusListenersMixin {
  AnimationController({
    // 初始化值
    double value,
    // 动画执行的时间
    this.duration,
    // 反向动画执行的时间
    this.reverseDuration,
    // 最小值
    this.lowerBound = 0.0,
    // 最大值
    this.upperBound = 1.0,
    // 刷新率ticker的回调（看下面详细解析）
    @required TickerProvider vsync,
  })
}
```

## CurvedAnimation
```dart
class CurvedAnimation extends Animation<double> with AnimationWithParentMixin<double> {
  CurvedAnimation({
    // 通常传入一个AnimationController
    @requiredthis.parent,
    // Curve类型的对象
    @requiredthis.curve,
    this.reverseCurve,
  });
}
```

## Tween
```dart
class Tween<T extends dynamic> extends Animatable<T> {
  Tween({ this.begin, this.end });
}
```

## 总结
- 每次写动画，都要写代码
- setState -> build

优化方案  
- AnimateWidget  
  - 将需要执行动画的Widget放到一个AnimatedWidget中的build方法里进行返回
  - 缺点:
    - 每次都需要创建类
    - 如果构建的Widget有子类，那么子类依然会build
- AnimatedBuilder(推荐，最优)
## 交织动画
```dart
  AnimationController controller;
  Animation<double> animation;

  Animation<Color> colorAnim;
  Animation<double> sizeAnim;
  Animation<double> rotationAnim;

  @override
  void initState() {
    super.initState();

    // 1.创建AnimationController
    controller = AnimationController(duration: Duration(seconds: 2), vsync: this);
    // 2.动画添加Curve效果
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    // 3.监听动画
    animation.addListener(() {
      setState(() {});
    });

    // 4.设置值的变化
    colorAnim = ColorTween(begin: Colors.blue, end: Colors.red).animate(controller);
    sizeAnim = Tween(begin: 0.0, end: 200.0).animate(controller);
    rotationAnim = Tween(begin: 0.0, end: 2*pi).animate(controller);
  }


@override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: controller,
        builder: (ctx, child) {
          return Opacity(
            opacity: animation.value,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(rotationAnim.value),
              child: Container(
                width: sizeAnim.value,
                height: sizeAnim.value,
                color: colorAnim.value,
                alignment: Alignment.center,
              ),
            ),
          );
        },
      ),
    );
  }
```

## iOS的Modal弹出页面方式
```dart
Navigator.of(context).push(MaterialPageRoute(
  builder:(ctx){
     return HYModalPage();
  },
  fullscreenDialog:true
));
```

## 页面渐变显示/渐变消失
```dart
Navigator.of(context).push(PageRouteBuilder(
  pageBuilder:(ctx,animation1,animation2){
    transitionDuration:Duration(seconds:3),
     return FadeTransition(
       opacity:animation1,
       child:HYModalPage(),
     );
  },
  fullscreenDialog:true
));
```

## Hero动画
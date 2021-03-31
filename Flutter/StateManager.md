#  状态管理
- 短时状态Ephemeral state
- 应用状态App state

## Ephemeral state
这种状态我们只需要使用StatefulWidget对应的State类自己管理即可，Widget树中的其它部分并不需要访问这个状态。
## 共享状态管理
- InheritedWidget
- Provider

## InheritedWidget
InheritedWidget和React中的context功能类似，可以实现跨组件数据的传递。
```dart
// 沿着Element树，去找到最近的目的Element，从Element中取出Widget
context.dependOnInheritedWidgetOfExactType()
```
子Weidget共享数据
```dart
class DSCounterWidget extends InheritedWidget{
  // 1. 共享的数据
  final int counter;

  /// 2.自定义构造方法
  DSCounterWidget({this.counter,Widget child}) : super(child:child);

  /// 3.获取祖先最近的当前InheritedWidget
  static DSCounterWidget of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType();
  }

  /// 4.决定要不要回调didChangeDependencies
  /// 如果返回true:执行依赖当前的InheritedWidget的State中的didChangeDependencies
  @override
  bool updateShouldNotify(DSCounterWidget oldWidget) {
    return oldWidget.counter != counter;
  }
}

class DSShowData extends StatefulWidget{
  @override
  _DSShowDataState createState() => _DSShowDataState();
}

class _DSShowDataState extends State<DSShowData> {
  @override
  Widget build(BuildContext context) {
      /// 通过of方法拿到共享的值
    int counter = DSCounterWidget.of(context).counter;
    return Container(
      color: Colors.red,
      child: Text("当前计数:${counter}"),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print("执行了didChangeDependencies");
  }
}
```
dependOnInheritedWidgetOfExactType的源码
```dart
  @override
  T dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object aspect}) {
    assert(_debugCheckStateIsActiveForAncestorLookup());
    /// Map<Type, InheritedElement> _inheritedWidgets;
    final InheritedElement ancestor = _inheritedWidgets == null ? null : _inheritedWidgets[T];
    if (ancestor != null) {
      assert(ancestor is InheritedElement);
      return dependOnInheritedElement(ancestor, aspect: aspect);
    }
    _hadUnsatisfiedDependencies = true;
    return null;
  }
```

## Provider
### 使用步骤
1. 创建自己需要共享的数据
1. 在应用程序的顶层ChangeNotifierProvider
1. 在其他位置使用共享的数据

Provider.of和Consumer都可以获取到共享的值
- Provider.of当前Weidget整个build都会从新build
- Consumer只会从新构建Consumer包裹的：当Provider的数据发生改变时，只会改变Consumer的build方法
 
 Selector
- 对原有的数据进行转换 
- sholdRebuild：当Provider的数据发生改变时，是否需要重新构建builder方法
> Selector2、Selector3、Selector4、Selector5、Selector6

### MultiProvider
```dart
MultiProvider(
    providers:[],
    child:MyApp(),
);
```
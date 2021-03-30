# Widget中的Key

## 定义
Key本身是一个抽象，不过它也有一个工厂构造器，创建出来一个ValueKey

直接子类主要有：LocalKey和GlobalKey

LocalKey，它应用于具有相同父Element的Widget进行比较，也是diff算法的核心所在；
GlobalKey，通常我们会使用GlobalKey某个Widget对应的Widget或State或Element

### LocalKey
- ValueKey：
ValueKey是当我们以特定的值作为key时使用，比如一个字符串、数字等等
- ObjectKey：
  如果两个学生，他们的名字一样，使用name作为他们的key就不合适了
我们可以创建出一个学生对象，使用对象来作为key
- UniqueKey：如果我们要确保key的唯一性，可以使用UniqueKey；
比如我们之前使用随机数来保证key的不同，这里我们就可以换成UniqueKey；

### GlobalKey  
可以帮助我们访问某个Widget的信息，包括Widget或State或Element等对象
```dart
class HYHomePage extends StatelessWidget {
  final GlobalKey<_HYHomeContentState> homeKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HYHomeContent(key: homeKey),
    );
  }

  void printInfo(){
       print("${homeKey.currentState.value}");
       print("${homeKey.currentState.widget.name}");
       print("${homeKey.currentContext}");
  }
}

class HYHomeContent extends StatefulWidget {
  finalString name = "123";
  HYHomeContent({Key key}): super(key: key);
  @override
  _HYHomeContentState createState() => _HYHomeContentState();
}

class _HYHomeContentState extends State<HYHomeContent> {
  finalString value = "abc";

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## 如果没有key
删除操作：删除第一个，Element会往上移复用，永远删除的是最后一个Element

## Widget传递key，但是实际是Element中在使用key

## 如果有Key
- 会有2个Element true，进行删除操作的时候，会进行diff判断操作，根据runtimetype和key判断，会把不一样的进行删除
```dart
 static bool canUpdate(Widget oldWidget, Widget newWidget) {
    return oldWidget.runtimeType == newWidget.runtimeType
        && oldWidget.key == newWidget.key;
  }
```

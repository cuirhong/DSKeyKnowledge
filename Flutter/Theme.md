# 主题
- 一旦设置了主题，某些Widget就直接会使用主题的样式
## 设置主题
```dart
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // 1.亮度: light-dark
        brightness: Brightness.light,
        // 2.primarySwatch: primaryColor/accentColor的结合体
        primarySwatch: Colors.red,
        // 3.主要颜色: 导航/底部TabBar
        primaryColor: Colors.pink,
        // 4.次要颜色: FloatingActionButton/按钮颜色
        accentColor: Colors.orange,
        // 5.卡片主题
        cardTheme: CardTheme(
          color: Colors.greenAccent,
          elevation: 10,
          shape: Border.all(width: 3, color: Colors.red),
          margin: EdgeInsets.all(10)
        ),
        // 6.按钮主题
        buttonTheme: ButtonThemeData(
          minWidth: 0,
          height: 25
        ),
        // 7.文本主题
        textTheme: TextTheme(
          title: TextStyle(fontSize: 30, color: Colors.blue),
          display1: TextStyle(fontSize: 10),
        )
      ),
      home: HYHomePage(),
    );
  }
}
```
## 设置主主题之后，修改子Widget的主题
### 嵌套一个Theme
```dart
Theme(
    data:Theme.of(context).copyWith(
        //修改accentColor的主题颜色，并不是直接accentColor，官方文档针对这点是错误的
      colorScheme:Theme.of(context).colorScheme.copyWith(
          secondary:Colors.pink
      )
    ),
    child:
)
```
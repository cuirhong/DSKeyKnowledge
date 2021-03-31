import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(Center(child: MyApp()));
///
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: DSAppPage());
  }
}


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
class DSShowDateSecond extends StatefulWidget {
  @override
  _DSShowDateSecondState createState() => _DSShowDateSecondState();
}

class _DSShowDateSecondState extends State<DSShowDateSecond> {
  @override
  Widget build(BuildContext context) {
    int counter = DSCounterWidget.of(context).counter;
    return Container(
      color: Colors.blue,
      child: Text("当前计数:${counter}"),
    );
  }
}

class DSAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DSHomePage(),
    );
  }
}


class DSHomePage extends StatefulWidget {
  @override
  _DSHomePageState createState() => _DSHomePageState();
}

class _DSHomePageState extends State<DSHomePage> {
  int _counter = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: DSCounterWidget(
        counter:_counter,
        child: Column(
          children: <Widget>[
            Container(
              child: DSShowData(),
            ),
            Container(
              child: DSShowDateSecond(),
            ),
          ],
        ),
      ),
      floatingActionButton:  FloatingActionButton(
          onPressed: (){
            setState(() {
              _counter++;
            });
          },
      ),
    );
  }
}





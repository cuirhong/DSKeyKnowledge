import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(Center(child: MyApp()));
///
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: DSHomePage());
  }
}

class DSHomePage extends StatelessWidget {
  // ignore: public_member_api_docs
  DSHomePage(){
    print("构造函数");

    var future = Future(
        (){
          return "";
        }
    );
    future.then((value){

    }).catchError((error){

    }).whenComplete((){

    });
  }

  /// async * 是一个生成器，python中常见
  Future test() async{

    var total = 0;
    for(var i = 0;i < 100; i++){

    }



//    //1.创建管道
//    ReceivePort receivePort = ReceivePort();
//    //2.创建isolate
//    Isolate isolate = await Isolate.spawn<SendPort>(calc, receivePort.sendPort);
//    //3.监听管道
//    receivePort.listen((message){
//
//    });
//    Isolate.spawn(calc, 100);
    await sleep(Duration(seconds: 3));
    //直接返回结果，内部会自动包裹一个Future
    return "结果";
  }

  void runCalc() async{
    var result = await compute(calc,100);
//    return
  }


  @override
  Widget build(BuildContext context) {
    print("build函数");
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("商品列表")),
      body: DSContentBody('这是一个传递的信息'),
    );
  }
}

int calc(int count){
  //耗时操作
  return count + 1;
}

class DSContentBody extends StatefulWidget {
  final String message;
  DSContentBody(this.message);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DSContentState();
  }
}

class _DSContentState extends State<DSContentBody> {
  var _counter = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  child: Text("+"),
                  color: Colors.cyan,
                  onPressed: () {
                    setState(() {
                      _counter++;
                    });
                  }),
              RaisedButton(
                child: Text('-'),
                color: Colors.purple,
                onPressed: () {
                  setState(() {
                    _counter--;
                  });
                },
              ),
              FlatButton(

              ),
              FadeInImage(
//                placeholder: ImageProvider,
                image: NetworkImage(''),
              ),
              Flexible()
            ],
          ),
          Text(
            '当前计数:$_counter',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            '传递的信息:${widget.message}'
          ),
          CustomScrollView(
            slivers: <Widget>[
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

                ),
                delegate: SliverChildBuilderDelegate(
                    (BuildContext ctx,int int){
                      return NotificationListener(
                        child: Container(),
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
                    }
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}




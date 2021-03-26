import 'package:flutter/material.dart';

void main() => runApp(Center(child: MyApp()));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: DSHomePage());
  }
}

class DSHomePage extends StatelessWidget {
  DSHomePage(){
    print("构造函数");
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
          )
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 我的内容
class DSMineContent extends StatefulWidget {
  @override
  _DSMineContentState createState() => _DSMineContentState();
}

class _DSMineContentState extends State<DSMineContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('我的内容',style: TextStyle(fontSize: 30,color: Colors.red),),
    );
  }
}

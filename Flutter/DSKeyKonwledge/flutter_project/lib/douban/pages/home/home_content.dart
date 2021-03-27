import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DSHomeContent extends StatefulWidget {
  @override
  _DSHomeContentState createState() => _DSHomeContentState();
}

class _DSHomeContentState extends State<DSHomeContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('首页内容',style: TextStyle(fontSize: 30,color: Colors.red),),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/douban/service/home_request.dart';

/// 首页内容
class DSHomeContent extends StatefulWidget {
  @override
  _DSHomeContentState createState() => _DSHomeContentState();
}

class _DSHomeContentState extends State<DSHomeContent> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HomeRequest.requestMovieList(0);
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('首页内容',style: TextStyle(fontSize: 30,color: Colors.red),),
    );
  }
}

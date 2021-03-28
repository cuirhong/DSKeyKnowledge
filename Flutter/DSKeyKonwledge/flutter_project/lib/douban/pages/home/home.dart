import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/Douban/pages/home/home_content.dart';
/// 首页
class DSHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页')
      ),
      body: DSHomeContent(),
    );
  }
}

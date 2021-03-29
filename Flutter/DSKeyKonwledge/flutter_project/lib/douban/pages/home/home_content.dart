import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/douban/model/home_model.dart';
import 'package:flutter_project/douban/pages/home/home_movie_item.dart';
import 'package:flutter_project/douban/service/home_request.dart';
import 'package:flutter_project/douban/utils/log.dart';

/// 首页内容
class DSHomeContent extends StatefulWidget {
  @override
  _DSHomeContentState createState() => _DSHomeContentState();
}

class _DSHomeContentState extends State<DSHomeContent> {
  final List<MovieItem> movies = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HomeRequest.requestMovieList(0, 30).then((res) {
      print("then之后的结果:$res");
      dsLog("测试一条信息", StackTrace.current);
      setState(() {
        movies.addAll(res);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: movies.length,
        itemBuilder: (ctx, index) {
          return DSHomeMovieItem(movies[index]);
        });
  }
}

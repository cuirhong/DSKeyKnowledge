import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/douban/config/config.dart';
import 'package:flutter_project/douban/model/home_model.dart';
import 'package:flutter_project/douban/widgets/dashed_line.dart';
import 'package:flutter_project/douban/widgets/star_rating.dart';

/// 首页电影item
class DSHomeMovieItem extends StatelessWidget {
  /// 电影item模型
  final MovieItem movieItem;

  /// 构造器
  DSHomeMovieItem(this.movieItem);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ProjectConfig.edgeInsetLength),
      decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 8, color: Color(0xffeeeeee)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildHeader(),
          SizedBox(height: 8),
          buildContent(),
          SizedBox(height: 8),
          buildFooter(),
        ],
      ),
    );
  }

  /// 1.头部的排名
  Widget buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 238, 205, 144),
          borderRadius: BorderRadius.circular(3)),
      child: Text("No.${movieItem.rank}",
          style:
              TextStyle(fontSize: 18, color: Color.fromARGB(255, 131, 96, 36))),
    );
  }

  /// 2.内容
  Widget buildContent() {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildContentImage(),
        SizedBox(width: 8),
        Expanded(
          child: IntrinsicHeight(
            child: Row(
              children: <Widget>[
                buildContentInfo(),
                SizedBox(width: 8),
                buildContentLine(),
                SizedBox(width: 8),
                buildContentWish(),
              ],
            ),
          ),
        )
      ],
    );
  }

  /// 2.1 内容的图片
  Widget buildContentImage() {
//    Padding
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(movieItem.imageURL, height: 150));
  }

  /// 2.2 内容信息
  Widget buildContentInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildContentInfoTitle(),
          SizedBox(height: 8),
          buildContentInfoRate(),
          SizedBox(height: 8),
          buildContentInfoDesc(),
        ],
      ),
    );
  }

  /// 2.2.1 内容信息的标题
  Widget buildContentInfoTitle() {
    return Text.rich(
      TextSpan(children: [
        WidgetSpan(
            child: Icon(Icons.play_circle_outline,
                color: Colors.redAccent, size: 24)),
        TextSpan(
            text: movieItem.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextSpan(
            text: "(${movieItem.playDate})",
            style: TextStyle(fontSize: 18, color: Colors.grey))
      ]),
    );
  }

  /// 2.2.2内容信息的评分
  Widget buildContentInfoRate() {
    return Row(
      children: <Widget>[
        DSStarRating(
          rating: movieItem.rating,
          size: 20,
        ),
        SizedBox(width: 6),
        Text("${movieItem.rating}", style: TextStyle(fontSize: 16))
      ],
    );
  }

  /// 2.2.3内容信息的描述
  Widget buildContentInfoDesc() {
    // 字符串拼接
    final genresString = movieItem.genres.join(" ");
    final directorString = movieItem.director.name;
    final actorString = movieItem.casts.map((item) => item.name).join(" ");

    return Text(
      "$genresString / $directorString / $actorString",
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 16),
    );
  }

  /// 2.3 内容的虚线
  Widget buildContentLine() {
    return Container(
      height: 120,
      child: DSDashedLine(
        dashedWidth: .4,
        dashedHeight: 6,
        count: 10,
        color: Colors.pink,
        axis: Axis.vertical,
      ),
    );
  }

  /// 2.4 内容的想看
  Widget buildContentWish() {
    return Container(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.turned_in_not, color: Color.fromARGB(255, 235, 170, 60)),
          Text("想看",
              style: TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 235, 170, 60)))
        ],
      ),
    );
  }

  /// 3 尾部的布局
  Widget buildFooter() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 7),
      decoration: BoxDecoration(
        color: Color(0xfff2f2f2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(movieItem.originalTitle,
          style: TextStyle(fontSize: 18, color: Color(0xff666666))),
    );
  }
}

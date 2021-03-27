import 'package:flutter/material.dart';
import 'package:flutter_project/Douban/pages/main/main.dart';
import 'package:flutter_project/Douban/widgets/dashed_line.dart';
import 'package:flutter_project/Douban/widgets/star_rating.dart';

void main() => runApp(Center(child: MyApp()));

///
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DSMainPage(),
        theme: ThemeData(
            primarySwatch: Colors.green,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent));
  }
}

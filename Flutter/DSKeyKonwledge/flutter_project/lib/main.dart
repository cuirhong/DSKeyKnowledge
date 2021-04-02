import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/router/detail.dart';

void main() => runApp(Center(child: MyApp()));

///
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
        title: "",
        theme: ThemeData(
          primarySwatch:Colors.red,
        ),
        home: DSAppPage());
  }
}

///
class DSAppPage extends StatefulWidget {
  @override
  _DSAppPageState createState() => _DSAppPageState();
}

class _DSAppPageState extends State<DSAppPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

 
 
 
 
 

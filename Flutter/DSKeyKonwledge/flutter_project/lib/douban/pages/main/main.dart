import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/Douban/pages/main/initialize_items.dart';
/// 主页
class DSMainPage extends StatefulWidget {
  @override
  _DSMainPageState createState() => _DSMainPageState();
}

class _DSMainPageState extends State<DSMainPage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items:tabbarItems,
        unselectedFontSize: 14,
        selectedFontSize: 14,
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}



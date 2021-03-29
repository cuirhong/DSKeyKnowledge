import 'package:flutter/cupertino.dart';

/// 底部tabbar的item
class DSBottomBarItem extends BottomNavigationBarItem {
  /// 构造函数
  DSBottomBarItem(String iconName, String title) :super(
      title: Text(title),
      icon: Image.asset(
          "assets/images/tabbar/${iconName}_black.png", width: 30,gaplessPlayback: true),
      activeIcon: Image.asset(
          "assets/images/tabbar/${iconName}_red.png", width: 30,gaplessPlayback: true));
}
import 'package:flutter/cupertino.dart';
import 'package:flutter_project/Douban/pages/home/home.dart';
import 'package:flutter_project/douban/pages/mine/mine.dart';

import 'bottom_bar_item.dart';

/// tabbar的items数组
List<DSBottomBarItem> tabbarItems = [
  DSBottomBarItem('icon_home', '首页'),
  DSBottomBarItem('icon_IR', 'IR门户'),
  DSBottomBarItem('icon_meeting', '一键参会'),
  DSBottomBarItem('icon_mine', '我的'),
];

List<Widget> pages = [
  DSHomePage(),
  DSHomePage(),
  DSHomePage(),
  DSMinePage(),
];
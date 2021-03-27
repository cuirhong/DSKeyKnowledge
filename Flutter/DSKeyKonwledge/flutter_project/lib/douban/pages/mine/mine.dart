import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'mine_content.dart';

/// 我的页面
class DSMinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('我的')
      ),
      body: DSMineContent(),
    );
  }
}

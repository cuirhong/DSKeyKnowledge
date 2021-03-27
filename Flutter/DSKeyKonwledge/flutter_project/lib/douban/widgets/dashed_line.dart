import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 虚线
class DSDashedLine extends StatelessWidget {
  /// 虚线的方向
  final Axis axis;

  ///虚线的宽度
  final double dashedWidth;

  /// 虚线的高度
  final double dashedHeight;

  /// 虚线的个数
  final int count;

  /// 虚线的颜色
  final Color color;

  /// 构造函数
  DSDashedLine({this.axis = Axis.horizontal,
    this.dashedWidth = 1,
    this.dashedHeight = 1,
    this.count = 10,
    this.color = Colors.red});

  @override
  Widget build(BuildContext context) {
    return Flex(
        direction: axis,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(count, (index) {
          return SizedBox(
            width: dashedWidth,
            height: dashedHeight,
            child: DecoratedBox(
                decoration: BoxDecoration(color: color)
            ),
          );
        })
    );
  }
}

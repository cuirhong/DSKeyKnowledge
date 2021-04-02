import 'dart:ui';

/// 屏幕适配
class ScreenSizeFit {
  /// 屏幕的宽度
  static double screenWidth;

  /// 物理高度
  static double screenHeight;

  /// dpr
  static double dpr;

  /// 状态栏的高度
  static double statusHeight;

  ///
  static double rpx;

  ///
  static double px;

  /// 初始化
  static void initialize() {
    // 1. 获取手机的物理分辨率
    double physicalWidth = window.physicalSize.width;
    double physicalHeight = window.physicalSize.height;

    // 2. 获取dpr
    dpr = window.devicePixelRatio;

    // 3. 宽度和高度
    screenWidth = physicalWidth / dpr;
    screenHeight = physicalHeight / dpr;

    // 4.状态栏的高度
    statusHeight = window.padding.top / dpr;

    // 5.计算rpx的大小
    rpx = screenWidth / 750;
    px = rpx * 2;
  }
}

///
extension StringSplit on String {
  String ds_split(String split) {
    return "davis";
  }
}

import 'package:flutter_project/test/math_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("test match utils file", () {

    /// 初始化一些操作，所有的测试开始前会执行
    setUpAll((){

    });

    test("match utils file test", () {
      final result = sum(20, 30);
      expect(result, 50);
    });

    test("match utils file test", () {
      final result = mul(20, 30);
      expect(result, 600);
    });
  });
}

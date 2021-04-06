import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

/// 集成测试
void main() {
  group("application test", () {
    FlutterDriver flutterDriver;
    setUpAll(() async {
      flutterDriver = await FlutterDriver.connect();
    });

    /// 所有测试结束后会执行
    tearDownAll(() {
      flutterDriver.close();
    });
    final textFinder = find.byValueKey("textKey");
    final buttonFinder = find.byValueKey("buttonKey");
    test("test default value", () async {
      expect(await flutterDriver.getText(textFinder), "0");
    });

    test("floatingactionbutton click", () async {
      await flutterDriver.tap(buttonFinder);
      expect(buttonFinder, "1");
    });
  });
}

# 混合开发
```dart
//默认创建出来的项目,iOS是Swift，Android是ktlin
flutter create demo_project
//创建Flutter项目的时候，跟上语言 -i就是iOS -a就是Android
flutter create -i objc -a java demo_project
```

## 获取电池信息
### Flutter核心代码
```dart
 // 核心代码一：
  static const platform = const MethodChannel("coderwhy.com/battery");
   // 核心代码二
    final int result = await platform.invokeMethod("getBatteryInfo");
```
### iOS核心代码
```swift
func test(){
     // 1.获取FlutterViewController(是应用程序的默认Controller)
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // 2.获取MethodChannel(方法通道)
    let batteryChannel = FlutterMethodChannel(name: "coderwhy.com/battery",
                                              binaryMessenger: controller.binaryMessenger)
    
    // 3.监听方法调用(会调用传入的回调函数)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // 3.1.判断是否是getBatteryInfo的调用,告知Flutter端没有实现对应的方法
      guard call.method == "getBatteryInfo" else {
        result(FlutterMethodNotImplemented)
        return
      }
      // 3.2.如果调用的是getBatteryInfo的方法, 那么通过封装的另外一个方法实现回调
      self?.receiveBatteryLevel(result: result)
    })
}

private func receiveBatteryLevel(result: FlutterResult) {
    // 1.iOS中获取信息的方式
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    
    // 2.如果没有获取到,那么返回给Flutter端一个异常
    if device.batteryState == UIDevice.BatteryState.unknown {
      result(FlutterError(code: "UNAVAILABLE",
                          message: "Battery info unavailable",
                          details: nil))
    } else {
      // 3.通过result将结果回调给Flutter端
      result(Int(device.batteryLevel * 100))
    }
  }
```
### Android核心代码
```java
  // 1.创建MethodChannel对象
    MethodChannel methodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);

    // 2.添加调用方法的回调
    methodChannel.setMethodCallHandler(
        (call, result) -> {
          // 2.1.如果调用的方法是getBatteryInfo,那么正常执行
          if (call.method.equals("getBatteryInfo")) {

            // 2.1.1.调用另外一个自定义方法回去电量信息
            int batteryLevel = getBatteryLevel();

            // 2.1.2. 判断是否正常获取到
            if (batteryLevel != -1) {
              // 获取到返回结果
              result.success(batteryLevel);
            } else {
              // 获取不到抛出异常
              result.error("UNAVAILABLE", "Battery level not available.", null);
            }
          } else {
            // 2.2.如果调用的方法是getBatteryInfo,那么正常执行
            result.notImplemented();
          }
        }
      );
```

## Native嵌入Flutter
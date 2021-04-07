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
创建Flutter Module
```dart
flutter create --template module my_flutter
```
### 嵌入iOS项目
- 可以使用 CocoaPods 依赖管理和已安装的 Flutter SDK ；
- 也可以通过手动编译 Flutter engine 、你的 dart 代码和所有 Flutter plugin 成 framework ，用 Xcode 手动集成到你的应用中，并更新编译设置；
#### Cocopods安装  
- 编译Podfile文件:
```swift
# 添加模块所在路径
flutter_application_path = '../my_flutter'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'ios_my_test' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # 安装Flutter模块
  install_all_flutter_pods(flutter_application_path)
  
  # Pods for ios_my_test

end
```
- 重新执行安装依赖
```
pod install
```
#### Swift代码
为了在既有的iOS应用中展示Flutter页面，需要启动 Flutter Engine和 FlutterViewController。

通常建议为我们的应用预热一个 长时间存活 的FlutterEngine：

- 我们将在应用启动的 app delegate 中创建一个 FlutterEngine，并作为属性暴露给外界。
```swift
import UIKit
import FlutterPluginRegistrant

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
   // 1.创建一个FlutterEngine对象
    lazy var flutterEngine = FlutterEngine(name: "my flutter engine")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       // 2.启动flutterEngine
        flutterEngine.run()
        return true
    }
}
```
```swift
// 2.创建FlutterViewController对象（需要先获取flutterEngine）
let flutterEngine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine;
let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil);
navigationController?.pushViewController(flutterViewController, animated: true);
```
- 我们也可以省略预先创建的 FlutterEngine ：  
不推荐这样来做，因为在第一针图像渲染完成之前，可能会出现明显的延迟。
### 嵌入Android项目
嵌入到现有Android项目有多种方式：

- 编译为AAR文件（Android Archive）
- 通过Flutter编译为aar，添加相关的依赖,依赖模块的源码方式，在gradle进行配置 

<br/>

添加相关的依赖  
修改Android项目中的settings.gradle文件:
```java
// Include the host app project.
include ':app'                                     // assumed existing content
setBinding(new Binding([gradle: this]))                                 // new
evaluate(new File(                                                      // new
  settingsDir.parentFile,                                               // new
  'my_flutter/.android/include_flutter.groovy'                          // new
))  
```  
另外，我们需要在Android项目工程的build.gradle中添加依赖：
```java
dependencies {
  implementation project(':flutter')
}
```
编译代码，可能会出现如下错误：
```java
Default interface methods are only supported starting with Android N (–min-api 24): android.view.MenuItem androidx.core.internal.view.SupportMenuItem.setContentDescription(java.lang.CharSequence)
```
  - 这是因为从Java8开始才支持接口方法
  - Flutter Android引擎使用了该Java8的新特性  

解决办法：通过设置Android项目工程的build.gradle配置使用Java8编译：
```java
compileOptions {
    sourceCompatibility 1.8
    targetCompatibility 1.8
  }
```  
接下来，我们这里尝试添加一个Flutter的screen到Android应用程序中

Flutter提供了一个FlutterActivity来展示Flutter界面在Android应用程序中，我们需要先对FlutterActivity进行注册：

在AndroidManifest.xml中进行注册
```java
<activity
  android:name="io.flutter.embedding.android.FlutterActivity"
  android:theme="@style/AppTheme"
  android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
  android:hardwareAccelerated="true"
  android:windowSoftInputMode="adjustResize"
  />
```

#### java代码
```java
package com.coderwhy.testandroid;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        setContentView(R.layout.activity_main);
        startActivity(
            FlutterActivity.createDefaultIntent(this)
        );
    }
}
```
也可以在创建时，传入默认的路由
```java
  startActivity(
          FlutterActivity
          .withNewEngine()
          .initialRoute("/my_route")
          .build(currentActivity)
  );
```

## Flutter模块调试
使用flutter attach
```ruby
# --app-id是指定哪一个应用程序
# -d是指定连接哪一个设备
flutter attach --app-id com.coderwhy.ios-my-test -d 3D7A877C-B0DD-4871-8D6E-0C5263B986CD
```
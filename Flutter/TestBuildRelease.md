# 测试-编译-发布
## 测试
### 添加依赖
```dart
dev_dependencies:
  flutter_test:
    sdk: flutter
```
### 编写测试
在工程目录下有一个test的文件夹，写测试都放在这个目录下，如下测试代码，写完之后保存即可看到test左侧有一个运行的按钮，点击运行即可看到测试结果
- 简单测试
```dart
void main() {
  test("match utils file test", () {
    final result = sum(20, 30);
    expect(result, 50);
  });
}
```

- 组测试
```dart
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
```
> 有的时候会出现左侧没有运行的按钮，可直接在Android Studio顶部目录main.dart文件那里配置测试队医你个的文件，再直接点击运行  
> 运行快捷键：Control + Shift + R(MAC)
- Widget测试
```dart
  testWidgets("Test Contacts Widget", (WidgetTester tester) async {
    //注入Widget
    await tester.pumpWidget(MaterialApp(home: HYContacts(["abc", "cdb", "dis"])));
    // 在HYContacts中查找Widget/Text
    final abcText = find.text("abc");
    final cdbText = find.text("cdb");
    final icons = find.byIcon(Icons.people);

    expect(abcText, findsOneWidget);
    expect(cdbText, findsOneWidget);
    expect(icons, findsNWidgets(3));
  });
```

## 集成测试
### 添加flutter_driver依赖
```dart
dev_dependencies:
  flutter_driver:
    sdk: flutter
  test: any
```
### 先正常运行安装APP
### 在工程根目录新建test_driver文件夹(一定是根目录)
- test_driver目录下新建文件app.dart，代码如下:
```dart
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_project/main.dart' as app;
void main(){
  // 1. 初始化Driver
  enableFlutterDriverExtension();

  /// 2. 启动应用程序
  app.main();
}
```
- test_driver目录下新建文件app_test.dart，代码如下:
```dart
import 'package:flutter_driver/flutter_driver.dart';
/// 导入文件要使用下面这个，不然会报错
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
```

<br/>
<br/>

## Flutter编译模式
- debug
- profile
- release
### Debug模式
在Debug模式下，app可以被安装在真机、模拟器、仿真器上进行调试  
Debug模式有如下特点：  
  - 断言是开启的
  - 服务扩展是开启的
    - 可以从runApp的源码查看
    - runApp -> WidgetsFlutterBinding -> initServiceExtensions
  - 开启调试，类似于DevTools的工具可以连接到应用程序的进程中
  - 针对快速开发和运行周期进行了编译优化（但不是针对执行速度、二进制文件大小或者部署）
    - 比如Dart是JIT模式(Just In Time，即时编译，也可以理解成边运行边编译)  

默认情况下，运行 **flutter run** 会使用Debug模式，点击Android studio **Run按钮** 也是debug模式  
下面的情况也会出现在Debug模式下：
- 热重载(Hot Reload)功能仅能在调试模式下运行
- 仿真器和模拟器仅能在调试模式下运行
- 在Debug模式下，应用可能会出现掉帧或者卡顿现象
### Release模式
release模式下有如下特点：
- 断言是无效的
- 服务扩展是无效的
- debugging是无效的
- 编译针对快速启动、快速执行和小的package的大小进行了优化
  比如Dart是AOT模式（Ahead of Time,预先编译）
**flutter run --release** 命令会使用Release模式来进行编译，也可以给Android Studio进行配置:main.dart处->点击Edit Configutations->在Additional arguments处添加--release即可
### Profile模式  
profile和release类似，但是会保留一些信息方便我们对性能进行检测
- 保留了一些扩展是开启的
- DevTools的工具可以连接到应用程序的进程中
Profile模式最重要的作用就是可以利用Devtools来检测应用的性能

> kReleaseMode，当在release中的值为true

<br/>
<br/>

## 发布
### 版本
解释Flutter项目中的版本
```dart
version: 1.0.0+1
```
- 1.0.0是用户显示的版本
- 后面的1是内部管理的版本
### 用户权限配置
Android中某些用户权限需要在AndroidManifest.xml进行配置(Debug模式下有，但是Release下没有)：
```java
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.catefavor">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
</manifest>
```
### Android 打包
- 第一步：创建一个密钥库  
```dart
// 在macOS上
keytool -genkey -v -keystore ./key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```
>./key.jks是文件的路径，需要填写一个路径   

- 第二步：在app中引用秘钥库  

在android的根目录下创建key.properties的文件(/android/key.properties)，包含了密钥库位置的定义：
```java
storePassword=<上一步骤中的密码>
keyPassword=<上一步骤中的密码>
keyAlias=key
storeFile=<密钥库的位置，e.g. /Users/<用户名>/key.jks>
```
注意：这个文件一般不要提交到代码仓库，修改.gitignore文件
```
# Android ignore
/android/key.properties
```
- 第三步：配置gradle文件(android/app/build.gradle)
```dart
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
	keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

/// 下面的android是原本就有的，不需要修改
android {
...
}

  signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
   }
   buildTypes {
       release {
           signingConfig signingConfigs.release
       }
   }
```
- 第四步：打包应用程序
  - 打包APK(Android application package)文件
  ```ruby
  # 运行 flutter build apk （flutter build 默认带有 --release 参数）
  flutter build apk
  ```
  - 打包AAB(Android App Bundle)文件
    - Google推出的一种新的上传格式，某些应用市场不支持的
    - 会根据用户打包的aab文件，动态生成用户设备需要的APK文件
  ```ruby
  # 运行 flutter build appbundle。 (运行 flutter build 默认构建一个发布版本。)
  flutter build appbundle
  ```
### iOS 打包
- 第一步：基本信息和版本信息确认
- 第二步：用户权限配置  
在info.plist文件中配置
- 第三步：配置证书  
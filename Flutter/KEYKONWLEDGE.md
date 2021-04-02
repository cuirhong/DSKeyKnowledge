# 杂乱笔记
## 热重载和热重启
- 热重载(hot reload)：最主要执行build方法
- 热重启(hot restart)：重新运行整个APP

## 报错
```dart
No Directionality widget found .
```
- 因为Flutter是面向全世界的，布局不会默认从左上开始布局，必须设置方向 
- material有一个默认的方向，放在material里面就不需要单独设置方向

## 编程范式
- 面向对象编程
- 面向过程编程
- 函数式编程
- 面向协议编程
- 命令式编程 : 一步一步给计算机指令
- 声明式编程 : 依赖哪些状态，状态发生改变时，通知目标作出响应

## 编程规范
### 命名规范
- 类：首字母大写驼峰命名，如HomeBanner
- 变量名：首字母小写驼峰命名，如：imageUrl
- 文件及文件夹：小写字母下划线连接，如：banner_widget  

### 注释
- 单行注释
  - //与其他语言注释规范一致
  - 主要用于注释对于单行代码逻辑进行注释，为了避免过多注释
  - 主要是在一些理解较为复杂的代码逻辑上进行注释
- 多行注释
  - 一种是 /// ，另一个是 /****/，这两都可以使用，但是在dart推荐使用///，一般用于注释类和方法

### 文档工具
- 将注释形成文档，使用dart SDK里的命令dartdoc，这个命令需要在环境变量里面配置dart SDK路径
```dart
dartdoc
```
 > 执行完以后，会在项目当前目录生成一个doc文件夹， 里边有一个api目录下的index.html,

库引入规范  
- dart为了保持代码整洁， 规范了import库的顺序。将import库分了几个部分每个部分用空行分割
- 按照先后顺序:
  - dart库
  - package库
  - 其他未带协议头的库
```dart
import 'dart:developer';
 
import 'package:flutter/material.dart';
import 'package:two_you_friend/pages/home_page.dart';

import 'util.dart';
```
### 工具化  
   为了保证代码的质量， dart中也有和eslint一样的工具dartanalyzer来保证代码质量，该工具也在dart sdk中

#### 使用方法使用Dart SDK
  - 在项目根目录新建一个analysis_options.yaml文件
  - ​ 然后在文件中按照规范填写你需要执行的规则检查代码
  - 现有规则可以参考 [Dart linter rules](https://dart-lang.github.io/linter/lints/)规范

#### 第三方库模版  
为了方便使用，可以使用第三方已经配置好的规范模版，俩个库
- pedantic
- effective_dart  

添加使用:
> 可以参考这俩个库使用， 在我们项目中，使用它们俩者之一， 在项目pubspec.yaml中添加俩行配置
> ```dart
> dev_dependencies:
>   flutter_test:
>     sdk: flutter
>   pedantic: ^1.8.0  
> ```
> 可以在yaml点 pub get去下载，也可以在终端 进入当前项目执行 flutter pub upgrade去执行  

配置完成后， 在新增的analysis_option.yaml文件中新增加如下配置
```dart
include: package:pedantic/analysis_options.1.8.0.yaml
```
 不满足第三方的模版，还可以增加自己需要的
 ```dart
 include: package:pedantic/analysis_options.1.8.0.yaml
analyzer:
  strong-mode:
    implicit-casts: false
linter:
  rules:
    # STYLE
    - camel_case_types
    - camel_case_extensions
    - file_names
    - non_constant_identifier_names
    - constant_identifier_names # prefer
    - directives_ordering
    - lines_longer_than_80_chars # avoid
    # DOCUMENTATION
    - package_api_docs # prefer
    - public_member_api_docs # prefer
 ```
增加完上边的配置后， 执行命令，即可看到不规范的地方
```dart
dartanalyzer lib
```

## 报错
```dart
Waiting for another flutter command to release the startup lock
```
解决方案：  
cd 到flutter SDK目录下，执行
```dart
rm ./flutter/bin/cache/lockfile
```

## 升级Xcode导致项目运行出错
删除：Flutter项目/ios/Flutter/App.framework，重新运行
# Environment
Flutter搭建环境
## 第一步：下载flutter SDK，解压flutter文件夹
下载地址：[Flutter SDK](https://flutter.dev/docs/development/tools/sdk/releases)  
⚠️：选择最新稳定的版本（Stable版本）
## 第二步：配置环境变量 
### MacOS环境
- 前往~/.bash_profile(由于是隐藏文件，可用 shift+command+. 显示隐藏文件)
- 添加Flutter的环境变量
```ruby
export PATH=$PATH:/flutter目录/bin
```
- 添加Dart环境变量
```ruby
# 由于Flutter SDK本身就自带dart，所以直接用Flutter-SDK 的
export PATH = $PATH:/flutter目录/bin/cache/dart-sdk/bin
```
⚠️ 如果bash_profile不生效，执行 source ~/.bash_profile
### Windows
- 电脑图标->右键->高级变量->环境变量
- 添加Flutter环境变量
## 验证是否安装成功
```ruby
flutter --version
```
```ruby
dart --version
```
## 镜像配置
### flutter项目会依赖一些东西，在国内下载会很慢，可用将它们换成国内镜像
### MacOS 或者 Linux系统依赖 ~/.bash_profile文件
```ruby
exprot PUB_HOSTED_URL=https://pub.flutter-io.cn
exprot FLUTTER_STORAGE_BASE_URL=https://storage.flutter
```
### Windows用户还是需要修改环境变量
- 新建变量 PUB_HOSTED_URL ,其值为https://pub.flutter-io.cn
- 新建变量 FLUTTER_STORAGE_BASE_URL，其值为https://storage.flutter-io.cn

## 开发工具选择
### 官方推荐Flutter开发工具：Android Studio和VSCode
### VSCode
#### 优点
- VSCode其实并不能称之为是一个IDE，它只是一个编辑器而已
- 轻量级，不会占用非常大的内存消耗，而且穷速递等都非常快
- 可以在VSCode上安装各种各样的插件来满足自己的开发需求
#### 缺点 
- 很多AS包括的方便操作没有，比如点击启动、热更新点击等;
- 在某些情况下会出现一些问题
- 有时候热更新不及时常常看不到效果，必须重启
- 某些情况下，没有代码提示不够灵敏  

⚠️：VSCode: 安装code runner插件运行代码

### Android Studio
#### 优点
- 集成开发环境(IDE)，需要的功能基本都有
- 上面说的VSCode存在的问题，在AS中基本不会出现
#### 缺点
- 一个字：重
- 无论是IDE本身还是使用AS启动项目，都会相对慢一些
- 占据的计算机资源也很多，所以电脑配置较低是会出现卡顿的
- 使用须知：使用AS开发Flutter我们需要安装两个插件 ：Flutter和Dart

## 打开模拟器
- Android studio  
右下角configs->AVD manager
- xcode  
 左上角xcode->Open Developer Tool->Simulator


## Flutter和Native混合开发，如何进行Debug断点调试
- 杀掉相关进程（Flutter单运行的、Native运行的）
- 点击Android studio顶部工具栏的[Flutter Attach]按钮(就在运行按钮右边👉),等待控制台进入Debug状态:
```android
Checking for advertised Dart observatories...
Waiting for a connection from Flutter on iPhone xxxx
```
- 再运行Native，Flutter打上断点即可进行调试

# Ionic
## 运行一个ionic项目
5D647E25-84C6-4F8C-8618-4EDB3F7E38DA是运行机器的id，
可以通过 ionic cordova run ios --target --list 查看
```ruby
npm install
ionic build
# 指定ios版本安装，版本有问题的话会报错（根据项目中的版本来）
ionic cordova platform add ios@5.1.1
ionic cordova run ios --target 5D647E25-84C6-4F8C-8618-4EDB3F7E38DA
```
### ionic cordova platform rm ios有坑
如果config.xml有指定ios版本的话，使用ionic cordova platform rm ios会将config.xml中的版本删除掉，导致ionic cordova platform add ios的时候没有按照config.xml中的版本，最终可能会因为版本问题出错
```xml
<!-- config.xml中的配置 -->
 <engine name="ios" spec="5.1.1" />
```
## Debug
### 使用Cordova Tools进行debug调试
- vscode搜索安装Cordova Tools
- 在launch.json中添加Cordova配置
```ruby
 {
            "name": "Run iOS on device",
            "type": "cordova",
            "request": "launch",
            "platform": "ios",
            //这个是模拟器的id
            "target": "5D647E25-84C6-4F8C-8618-4EDB3F7E38DA",
            "port": 9220,
            "sourceMaps": true,
            "cwd": "${workspaceFolder}"
        }
```
### iOS中调试需要安装IWDP
```ruby
brew install ideviceinstaller ios-webkit-debug-proxy
```
[参考链接](https://geeklearning.io/live-debug-your-cordova-ionic-application-with-visual-studio-code/)
#### 出现找不到web视图
- 一直没成功，模拟器找不到设置
- 真机可以尝试设置: 设置->Safari->高级->网页检查器(打开)，重试看看


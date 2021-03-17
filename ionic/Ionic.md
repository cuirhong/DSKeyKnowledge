# Ionic
## 运行一个ionic项目
5D647E25-84C6-4F8C-8618-4EDB3F7E38DA是运行机器的id，
可以通过 ionic cordova run ios --target --list 查看
```ruby
npm install
ionic build
ionic cordova run ios --target 5D647E25-84C6-4F8C-8618-4EDB3F7E38DA
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
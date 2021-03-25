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
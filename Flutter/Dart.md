# Dart
Dart语法
## final和const的区别
- final可以通过计算/函数获取一个值，运行期间来确定一个值
- const必须赋值，常量值（编译期间需要有一个确定的值）

## 判断是否是同一个对象
```dart
identical(p1,p2)
``` 
## Dart没有重载
## 可选参数
- 位置可选参数--根据位置匹配
```dart
[int age , double height]
```
- 命名可选参数
### 只有可选参数才有默认值
## 函数可以作为另一个参数
- 匿名函数
- 箭头函数：条件函数体只有一行代码
## 运算符
```dart
// 当有值就不赋值，没有值才执行赋值
a ??= 10
```
## 级联运算符
```dart
// 但是dart提供了更加简便的打开方式，级联(..)
// 下面的代码等效于上面的传统调用方式。
var model = Model()
  ..hello('world')
  ..sayHi('bill')
  ..sayGoodbye('bill');

// 针对列表的级联
  List<int> listInt = List()
    ..add(0)
    ..add(1)
    ..add(2)
    ..removeAt(1);
  print(listInt); // output: [0, 2]
```
## 面向对象
- 命名构造函数
```dart
Person.withAgeHeight(this.age,this.height)
```
## 类的初始化列表
```dart
Point.withAssert(this.x, this.y) : this.x = x > 10 ? 10 : x {
  print('In Point.withAssert(): ($x, $y)');
}

Point.withAssert(this.x, this.y) : assert(x >= 0) {
  print('In Point.withAssert(): ($x, $y)');
}
```
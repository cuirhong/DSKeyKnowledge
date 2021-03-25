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
## 构造函数的重定向
```dart
class Person{
    String name;
    int age;

    Person._internal(this.name,this.age);

    //构造函数的重定向
    Person(String name): this._internal(name,0);
}
```
## 常量构造函数（和单列功能相似）
```dart
class Person{
    //一般常量构造函数里面都只有一个
    final String name;
    //一定用const
    const Person(this.name);
}

//这里也一定用const
const p1 = Person("liming")
const p2 = Person("liming")
 
// p1 == p2 (是同一个)
```

## 工厂构造函数
```dart
class Person{
  String name;
  String color;

  static final Map<String,Person> _nameCache = {}
  
  factory Person.withName(String name){
    if (_nameCache.containsKey(name)){
      return _nameCache[name];
    }else{
      final p = Person(name,'Default');
      _nameCache[name] = p 
      return p
    }
  }

  Person(this.name,this.color);
}
```
- 可以手动的返回一个对象
- 普通的构造函数会自动返回创建出来的对象，不能手动

## 类的setter和gettter
```dart
class Person{
  String name;

  set setName(String name){
    this.name = name
  }

  String get getName{
    return this.name
  }
}
```

## 抽象类(abstract)
- 继承自抽象类后，必须实现抽象类的抽象方法
- 抽象类不能实例化，可通过工厂构造函数
- external 修饰，方法声明和实现分离

## Flutter engine是C++

## 隐式接口
- 默认类都是隐式接口
- Dart支持单继承

## 混入（mixin）
- 定义可混入的类时不用class，用mixin用with进行混入
```dart
mixin Runner {
  void running(){
    print("running")
  }
}
mixin Flyer{
  void flying(){
    print("flying")
  }
}

class SuperMan extends Animal with Runner,Flyer{

}
```
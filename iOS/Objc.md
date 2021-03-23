# Objective-C的本质
### Objective-C -> C/C++ -> 汇编语言 -> 机器语言  
### Objective-C的面向对象都是基于C/C++的结构体（struct）数据结构实现的  
### 将Objective-C代码转换为C\C++代码

- 命令行:xcrun  -sdk  iphoneos  clang  -arch  arm64  -rewrite-objc  OC源文件  -o  输出的CPP文件
```ruby
# cpp->c plus plus
# ⚠️: 模拟器（i386）、32bit（armv7）、64bit（arm64）
xcrun  -sdk  iphoneos  clang  -arch  arm64  -rewrite-objc  main.m  -o  main-arm64.cpp

# xcrun:xcode run
# -sdk : 指定SDK为iphoneos
# clang : 编译器
# -arch : 架构指定为arm64
# -rewrite-objc : 重写objc文件
# main.m : 源文件
# -o : 输出的文件
# main-arm64.cpp : 当前文件夹下生成一个main-arm64.cpp文件
```
- 如果需要链接其他框架，使用-framework参数。比如-framework UIKit
### NSObject的底层实现
```objc
@interface NSObject{
    Class isa;
}
//Calss 指向结构体的指针
//指针在64位下占8个字节，32位占4个字节
typedef struct objc_class *Class;
@end
```
### NSObject类 通过转换成C++代码为:
```objc
<!-- NSObject_IMPL == NSObject Implementation(NSobject的实现) -->
struct NSObject_IMPL {
    Class isa;
};
```
## 内存大小
### 问题一：如下Student会占用多大的内存
```objc
@interface Student : NSObject{
    @public int _no;
    int _age;
}
@end
```
以上代码通过转成C++如下:
```objc
struct NSObject_IMPL{
    Class isa;//8个字节
};
struct Student_IMPL{
    struct NSObject_IMPL NSObject_IVARS; 
    int _no;//4个字节
    int _age;//4个字节
}
```
通过如上，解答：Student占用16个字节
```objc
Student *stu = [[Student alloc]init];
// 输出结果：16
NSLog(@"%zd", class_getInstanceSize([Student class]));
// 输出结果：16
NSLog(@"%zd", malloc_size((__bridge const void *)stu));
```
### 问题二：如下Person和Student会占用多大的内存
```objc
@interface Person : NSObject{
    int _age;
}
@end
@interface Student : Person{
    int _no;
}
@end
```
解答：Person和Sutdent都占用16个字节
### 问题三：如下MJPerson会占用多大内存
```objc
@interface MJPerson : NSObject{
  int _age;
  int _height;
  int _no;
}
@end
```
解答：MJPerson会占用 24 个字节，但是系统分配的时候会分配32个字节给它  
<strong>原因：iOS中存在内存对齐，分配的内存都是16的倍数</strong>

#### 直接将对象转换成结构体
```objc
// 申明一个结构体
struct Student_IMPL{
    Class isa; 
    int _no; 
    int _age; 
}
Student *stu = [[Student alloc]init];
stu->_no = 4;
stu->_age = 5;
// 直接转换
struct Student_IMPL *stuImpl = (__bridge struct Student_IMPL *)stu;

NSLog(@"no is %d,age is %d",stuImpl->_no,stuImpl->_age);
```
⚠️：内存对齐：结构体的最终大小必须是最大成员的倍数

### 两个获取内存大小的函数
- 创建一个实例对象，至少需要多少内存？
```objc
#import <objc/runtime.h>
class_getInstanceSize([NSObject class]);
```
- 创建一个实例对象，实际上分配了多少内存？
```objc
#import <malloc/malloc.h>
malloc_size((__bridge const void *)obj);
```

### 内存分配对齐
gnu的全称：gnu not unix，开源组织



## 面试题
### 一个NSObject对象占用多少内存
```objc
NSObject *obj = [[NSObject alloc] init];
// 16个字节

// 获得NSObject实例对象的成员变量所占用的大小 >> 8
NSLog(@"%zd", class_getInstanceSize([NSObject class]));

// 获得obj指针所指向内存的大小 >> 16
NSLog(@"%zd", malloc_size((__bridge const void *)obj));
```
解答：系统分配了16个字节给NSObject(可通过malloc_size函数获得)，但实际只使用了8个字节（isa指针，64bit环境下，可以通过class_getInstanceSize获得）

原理是：当小于8的时候，为了内存补齐，会使用16，源码如下：
```objc
 size_t instanceSize(size_t extraBytes) {
        size_t size = alignedInstanceSize() + extraBytes;
        //所有的object对象至少是16个字节
        // CF requires all objects be at least 16 bytes.
        if (size < 16) size = 16;
        return size;
}
```

## OC对象的分类
### OC对象，主要可以分为3种
- instance对象(实例对象)
- class对象(类对象)
- meta-class对象(元类对象)
### instance
- instance对象就是通过类alloc出来的对象，每次调用alloc都会产生新的instance对象  
- object1、object2是NSObject的instance对象（实例对象）  
- 它们是不同的两个对象，分别占据着两块不同的内存  
- instance对象在内存中存储的信息包括
  - isa指针
  - 其他成员变量
### 类对象
```objc
Class cls1 = [NSObject class];

NSObject *objc = [[NSObject alloc]init];
Class cls2 = [objc class];

Class cls3 = object_getClass(objc) //Runtime API
```
- cls1、cls2、cls3都是类对象
- 它们是同一个对象。每个类在内存中有且只有一个class对象
- class对象在内存中存储的信息主要包括
  - isa指针
  - superclass指针
  - 类的属性信息（@property）、类的对象方法信息（instance method）
  - 类的协议信息（protocol）、类的成员变量信息（ivar）
### 元类对象
```objc
// 传入类对象，即可获得元类对象
Class objcMetaClass = object_getClass([NSObject class])
```
- objcMetaClass是NSObject的meta-class对象（元类对象）
- meta-data：元数据，描述数据的数据，因此meta-class是元对象，描述对象的
- 每个类在内存中有且只有一个meta-class对象
- meta-class对象和class对象的内存结构是一样的，但是用途不一样，在内存中存储的信息主要包括
  - isa指针
  - superclass指针
  - 类的类方法信息（class method）
- 判断是否是元类对象
  ```objc
  #import <objc/runtime.h>
  class_isMetaClass(objc)
  ```
- 以下代码获取的objectClass是class对象，并不是meta-class对象
  ```objc
  Class objectClass = [[NSObject class] class];
  ```
### object_getClass的源码
```objc
Class object_getClass(id obj)
{
    //如果是instance对象，返回class对象
    //如果是class对象，返回meta-class对象
    //如果是meta-class对象，返回NSObject(基类)的meta-class对象
    if (obj) return obj->getIsa();
    else return Nil;
}

```
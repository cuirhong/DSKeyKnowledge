# Block
## Block的本质
- block本质上也是一个OC对象，它内部也有一个isa指针
- block是封装了函数调用以及函数调用环境的OC对象
- block的底层结构
```objc
struct __main_block_impl_0{
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    //block中使用的变量
};
struct __block_impl{
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;//block函数的指针
};
struct __main_block_desc_0{
    size_t reserved;
    size_t Block_size;
};
```
## block的变量捕获(capture)
### auto自动变量，离开作用域就销毁
```objc
//两个是相等的，只是平时自动省略auto
int a = 20
auto int a = 20
```
### 为了保证block内部能够正常访问外部的变量，block有个变量捕获机制
- 变量类型(局部变量)为auto，可以捕获到block内部，访问方式：值传递  
- 变量类型(局部变量)为static，可以捕获到block内部，访问方式：指针传递
- 全局变量：不能捕获到block内部，访问方式：直接访问

## block的类型
### block有3种类型，可以通过调用class方法或者isa指针查看具体类型，最终都是继承自NSBlock类型
```objc
__NSGlobalBlock__->__NSGlobalBlock->NSBlock->NSObject
```
```objc
//没有访问auto类型的变量
__NSGlobalBlock__ (_NSConcreteGlobalBlock)
//访问了auto类型的变量（栈）
__NSStackBlock__ (_NSConcreteStackBlock)
//stack的block调用了copy（堆）
__NSMallocBlock__ (_NSConcreteMallocBlock)
```
### 应用内存的内存分配
- 程序区域->平时写的代码
- 数据区域(.data区)->_NSConcreteGlobalBlock
- 堆->_NSConcreteMallocBlock（动态分配内存，需要申请/释放）
- 栈->_NSConcreteStackBlock

### 每一种类型的block调用copy后的结果
- _NSConcreteStackBlock，存储区域：栈，复制效果：从栈复制到堆
- _NSConcreteGlobalBlock，存储区域：程序的数据区域，复制效果：什么也不做
- _NSConcreteMallocBlock，存储区域：堆，复制效果：引用计数增加

## block的copy
### 在ARC情况下，编译器会自动将block从栈上面copy到堆上，如下情况:
- block作为函数返回值时
- 将block赋值给__strong指针时
- block作为Cocoa API中方法名含有usingBlock的方法参数时
- block作为GCD API的方法参数时
### 在MRC情况下block属性的建议写法
```objc
@property (copy,nonatomic) void(^block)(void);
```
### 在ARC下block属性的建议写法
```objc
@property (strong,nonatomic) void(^block)(void);
@property (copy,nonatomic) void(^block)(void);
```

## block引用对象类型的auto变量
### 当block内部访问了对象类型的auto变量时
- 如果block是在栈上，将不会对auto变量产生强引用
- 如果block被拷贝到堆上
  > 会调用block内部的copy函数  
  > copy函数内部会调用_Block_object_assign函数
  > _Block_object_assign函数会根据auto变量的修饰符(__strong、__weak、_unsafe_unretained)做出操作，类似于retain（形成强引用、弱引用）(仅限于ARC，如果是MRC不会)
- 如果block从堆上移除
  > 会调用block内部的dispose函数
  > dispose函数内部会调用_Block_object_dispose函数
  > _Block_object_dispose函数会自动释放引用的auto函数，类似与release

> copy函数，栈上的Block复制到堆时  
> dispose函数，堆上的Block被废弃时

## __block修饰符
### __block可以用于解决block内部无法修改auto变量值的问题
### __block不能修饰全局变量、静态变量(static)
### 编译器会将__block变量包装成一个对象
```objc
__block int age = 10;
//最终会转换成
struct __Block_byref_age_0 {
  void *__isa;
  //指针，指向自己
  __block_byref_age_0 *__forwarding;
  int __flags;
  int __size;
  int age;
}
//后面的0是第一个block就用0，第二个用1，第三个用2，以此类推
struct __main_block_impl_0{
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;

  //这个指针指向__Block_byref_age_0的结构体，通过这个指针找到__forwarding，然后再通过__forwarding找到age
  __Block_byref_age_0 *age;
  //省略部分代码，同上面block的本质一样
  ...
}
```

## __block的内存管理
### 当block函数在栈上时，不会对__block的变量产生强引用
### 当block被copy到堆上时
- 会调用block内部的copy函数
- copy函数内部会调用_Block_object_assign函数
- _Block_object_assign函数会对__block的变量产生强引用(也会将__block的变量拷贝到堆上)
### 当block栋堆中移除时
- 会调用block内部的dispose函数
- dispose函数内部会调用_Block_object_dispose函数
- _Block_object_dispose函数会自动释放引用的__block变量(release)
### 对象类型的auto变量、__block变量
#### 当block在栈上时，对它们都不会产生强引用
#### 当block拷贝到堆上时，都会通过copy函数来处理他们
- __block变量(假设变量名叫做a)
```objc
_Block_object_assgin((void*)&dst->a,(void*)src->a,8/*BLOCK_FIELD_IS_BYREF*/);
```
- 当对象类型的auto变量(假设变量名叫做p)
```objc
_Block_object_assgin((void*)&dst->p,(void*)src->p,3/*BLOCK_FIELD_IS_OBJECT*/);
```
#### 当block从堆上移除时，都会通过dispose函数来释放他们
- __block变量(假设变量名叫做a)
```objc
_Block_object_dispose((void*)&src->a,8/*BLOCK_FIELD_IS_BYREF*/);
```
- 对象类型的auto变量(假设变量名叫做p)
```objc
_Block_object_assgin((void*)src->p,3/*BLOCK_FIELD_IS_OBJECT*/);
```
#### __block的__forwarding指针
##### 执行copy操作之后，__forwarding指针是指向堆上的block，栈上有一个block内存，堆上有一个block内存，从而保证，不管访问栈上或者堆上的block都能保证访问堆上的block

## 被__block修饰的对象类型
(假设对象名为person)
block->struct __Block_byref_person_0->MJPerson
## 解决循环引用的问题(ARC)
### __weak和__unsafe_unretained解决循环引用的问题
```objc
//__weak:指向的对象销毁时，会自动让指针置为nil
__weak typeof(self) weakSelf = self;
self.block = ^{
  printf("%p",weakSelf);
};
//__unsafe_unretained：向的对象销毁时，不会自动置为nil，当再次访问时会发生野指针的问题(不安全)
__unsafe_unretained typeof(self) weakSelf = self;
self.block = ^{
  printf("%p",weakSelf);
}
```
### __block解决(必须要调用block)
```objc
__block typeof(self) weakSelf = self;
self.block = ^{
  printf("%p",weakSelf);
  weakSelf = nil;
}
self.block();
```
## 解决循环引用的问题(MRC)
### MRC不支持__weak的
- 通过__unsafe_unreatained解决
- 用__block解决(__block的时候，在MRC情况下，copy函数内部会调用_Block_object_assign函数 _Block_object_assign函数不会进行强引用)

## 注意⚠️
### 在使用clang转换OC为C++代码时，可能会遇到以下问题
```objc
cannot create __weak reference in file using manual reference
```
#### 解决方案：支持ARC、制定运行时系统版本
```objc
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-9.0.0 你的文件路径
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
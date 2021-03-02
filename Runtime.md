# Runtime
## isa详解
### 在arm64架构之前，isa就是一个普通的指针，存储着Class、Meta-Class对象的内存地址
### 从arm64架构开始，对isa进行了优化，变成了一个共用体（union）结构，还使用位域来存储更多的信息
```objc
union isa_t{
    Class cls;
    uintptr_t bits;
    struct{
        //总的是64位（8个字节）
        uintptr_t nonpointer    : 1;
        uintptr_t has_assoc     : 1;
        uintptr_t has_cxx_dtor  : 1;
        uintptr_t shiftcls      : 33;
        uintptr_t magic         : 6;
        uintptr_t weakly_referenced : 1;
        uintptr_t deallocating  : 1;
        uintptr_t has_sidetable_rc  : 1;
        uintptr_t extra_rc      : 19;
    };
};
```
- nonpointer
> 0，代表普通的指针，存储着Class、Meta-Class对象的内存地址  
> 1，代表优化过，使用位域存储更多的信息

- has_assoc
> 是否有设置过关联对象，如果没有，释放时会更快

- has_cxx_dtor
> 是否有C++的析构函数（.cxx_destruct），如果没有，释放时会更快

- shiftcls
> 存储着Class、Meta-Class对象的内存地址信息

- magic
> 用于在调试时分辨对象是否未完成初始化

- weakly_referenced
> 是否有被弱引用指向过，如果没有，释放时会更快

- deallocating
> 对象是否正在释放

- extra_rc
> 里面存储的值是引用计数器减1

- has_sidetable_rc
> 引用计数器是否过大无法存储在isa中  
> 如果为1，那么引用计数会存储在一个叫SideTable的类的属性中

### Class、Meta-class的地址值，二进制的最后三位永远都是0（一个16进制==4个二进制）

## Calss的结构
```objc
stuct objc_class{
    Class isa;
    Class superclass;
    cache_t cache;//方法缓存
    class_data_bits_t bits;//用于获取具体的类信息
}
```
### 上面结构体的 bits & FAST_DATA_MASK得出如下结构
```objc
struct class_rw_t{
    uint32_t flags;
    uint32_t version;
    const class_ro_t *ro;
    method_list_t *methods;
    property_list_t *properties;//方法列表
    const protocol_list_t *protocols;//协议列表
    Class firstSubclass;
    Class nextSiblingClass;
    char *demangledName;
}
```
class_rw_t里面的methods、properties、protocols是二维数组，是可读可写的，包含了类的初始内容、分类的内容

### 上面的const class_ro_t *ro结构如下:

```objc
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    #ifdef __LP64__
    uint32_t reserved;
    #endif
    const uint8_t *ivarLayout;
    const char *name;//类名
    method_list_t *baseMethodList;
    protocol_list_t *baseProtocols;
    const ivar_list_t *ivars;//成员变量列表
    const uint8_t *weakIvarLayout;
    property_list_t baseProperties;
}
```
class_ro_t里面的baseMethodList、baseProtocols、ivars、baseProperties是一维数组，是只读的，包含类的初始内容
### method_t
method_t是对方法/函数的封装
```objc 
struct method_t{
    SEL name;//函数名
    const char *types;//编码（返回值类型、参数类型）
    IMP imp;//指向函数的指针（函数地址）
    ...
}
```
- IMP代表函数的具体实现
```objc
typedef id _Nullable (*IMP)(id _Nonnull,SEL _Nonnull,...);
```
- SEL代表方法/函数名，一般叫做选择器，底层结构跟char *类似
> 可以通过@selector()和sel_registerName()获得  
> 可以通过sel_getName()和NSStringFromSelector()转成字符串  
> 不同类中相同名字的方法，所对应的方法选择器是相同的
```objc
typedef struct objc_selector *SEL;
```
- types包含了函数返回值、参数编码的字符串  
types：返回值+参数1+参数2+...  

> 
> ```objc
> - (int)test:(int)age height:(float)height;
> ```
> 如上的方法types为：i24@0:8i16f20  （参考下面的编码）
> 1. @代表id (id的self，每一个方法都会默认传递self)
> 1. :代表SEL(SEL的_cmd，每一个方法都会默认传递_cmd)
> 1. i代表int类型
> 1. f代表float类型
> 1. 24代表所有参数所占的字节，@后面的0代表id类型的self从0字节开始，:后面的8代表_cmd从第8个字节开始，i后面的16代表int从16开始，f后面的20代表float从20字节开始

iOS中提供了一个叫做@encode的指令，可以将具体的类型表示成字符串编码  
1. c->  char类型
1. i->  int类型
1. s->  short类型
1. l->  long类型
1. q->  long long 类型
1. C->  unsigned char
1. I->  unsigned int 
1. S->  unsigned short 
1. L->  unsigned long
1. Q->  unsigned long long
1. f->  float
1. d->  double
1. B->  C++的boll或者C99 的_Bool
1. v->  void
1. *->  char *
1. @->  一个对象（id 类型）
1. #->  类对象
1. :->  SEL
1. [array type]-> Array
1. {name=type...}-> structure
1. (name=type...)-> union
1. bnum-> A bit field of num bits
1. ^type-> A pointer to type
1. ?-> unkonwn type    

## 方法缓存
### Class内部结构中有个方法缓存（cache_t），用散列表(哈希表)来缓存曾经调用过的方法，可以提高方法的查找速度
```objc
struct cache_t{
    struct bucket_t *_buckets;//散列表
    mask_t _mask;//散列表的长度减1，如_buckets的长度为10，则_mask为9
    mask_t _occopied;//已经缓存的方法数量
}
struct bucket_t{
    cache_key_t _key;//SEL作为key
    IMP _imp;//函数的内存地址
}
```
### 缓存查找
- objc-cache.mm
```objc
bucket_t * cache_t::find(cache_key_t k, id receiver)
```

## objc_msgSend执行流程
### OC中的方法调用，其实都是转换为objc_msgSend函数的调用
### objc_msgSend的执行流程可以分为3大阶段
- 消息发送
- 动态方法解析
- 消息转发
如果找不到合适的方法进行调用，会报错unrecognized selector sent to instance
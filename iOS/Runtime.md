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
### 源码跟读
### objc_msgSend的源码实现（objc-msg-arm64.s文件中）
- objc_msgSend的源码（汇编）
```objc
	ENTRY _objc_msgSend
	UNWIND _objc_msgSend, NoFrame
    //p0,#0寄存器：消息接收者，receiver
	cmp	p0, #0			// nil check and tagged pointer check
#if SUPPORT_TAGGED_POINTERS
    //b 跳转 le:小于等于 如果消息接收者为空就跳转到LNilOrTagged,如果消息接收者不为空，继续执行
	b.le	LNilOrTagged		//  (MSB tagged pointer looks negative)
#else
	b.eq	LReturnZero
#endif
	ldr	p13, [x0]		// p13 = isa
	GetClassFromIsa_p16 p13, 1, x0	// p16 = class
LGetIsaDone:
	// calls imp or objc_msgSend_uncached
	CacheLookup NORMAL, _objc_msgSend, __objc_msgSend_uncached

#if SUPPORT_TAGGED_POINTERS
LNilOrTagged:
	b.eq	LReturnZero		// nil check
	GetTaggedClass
	b	LGetIsaDone
// SUPPORT_TAGGED_POINTERS
#endif

LReturnZero:
	// x0 is already zero
	mov	x1, #0
	movi	d0, #0
	movi	d1, #0
	movi	d2, #0
	movi	d3, #0
	ret

	END_ENTRY _objc_msgSend
```
- 查找缓存的源码(汇编)
```objc
.macro CacheLookup Mode, Function, MissLabelDynamic, MissLabelConstant
	//
	// Restart protocol:
	//
	//   As soon as we're past the LLookupStart\Function label we may have
	//   loaded an invalid cache pointer or mask.
	//
	//   When task_restartable_ranges_synchronize() is called,
	//   (or when a signal hits us) before we're past LLookupEnd\Function,
	//   then our PC will be reset to LLookupRecover\Function which forcefully
	//   jumps to the cache-miss codepath which have the following
	//   requirements:
	//
	//   GETIMP:
	//     The cache-miss is just returning NULL (setting x0 to 0)
	//
	//   NORMAL and LOOKUP:
	//   - x0 contains the receiver
	//   - x1 contains the selector
	//   - x16 contains the isa
	//   - other registers are set as per calling conventions
	//

	mov	x15, x16			// stash the original isa
LLookupStart\Function:
	// p1 = SEL, p16 = isa
#if CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_HIGH_16_BIG_ADDRS
	ldr	p10, [x16, #CACHE]				// p10 = mask|buckets
	lsr	p11, p10, #48			// p11 = mask
	and	p10, p10, #0xffffffffffff	// p10 = buckets
	and	w12, w1, w11			// x12 = _cmd & mask
#elif CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_HIGH_16
	ldr	p11, [x16, #CACHE]			// p11 = mask|buckets
#if CONFIG_USE_PREOPT_CACHES
#if __has_feature(ptrauth_calls)
	tbnz	p11, #0, LLookupPreopt\Function
	and	p10, p11, #0x0000ffffffffffff	// p10 = buckets
#else
	and	p10, p11, #0x0000fffffffffffe	// p10 = buckets
	tbnz	p11, #0, LLookupPreopt\Function
#endif
	eor	p12, p1, p1, LSR #7
	and	p12, p12, p11, LSR #48		// x12 = (_cmd ^ (_cmd >> 7)) & mask
#else
	and	p10, p11, #0x0000ffffffffffff	// p10 = buckets
	and	p12, p1, p11, LSR #48		// x12 = _cmd & mask
#endif // CONFIG_USE_PREOPT_CACHES
#elif CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_LOW_4
	ldr	p11, [x16, #CACHE]				// p11 = mask|buckets
	and	p10, p11, #~0xf			// p10 = buckets
	and	p11, p11, #0xf			// p11 = maskShift
	mov	p12, #0xffff
	lsr	p11, p12, p11			// p11 = mask = 0xffff >> p11
	and	p12, p1, p11			// x12 = _cmd & mask
#else
#error Unsupported cache mask storage for ARM64.
#endif

	add	p13, p10, p12, LSL #(1+PTRSHIFT)
						// p13 = buckets + ((_cmd & mask) << (1+PTRSHIFT))

						// do {
1:	ldp	p17, p9, [x13], #-BUCKET_SIZE	//     {imp, sel} = *bucket--
	cmp	p9, p1				//     if (sel != _cmd) {
	b.ne	3f				//         scan more
						//     } else {
2:	CacheHit \Mode				// hit:    call or return imp
						//     }
3:	cbz	p9, \MissLabelDynamic		//     if (sel == 0) goto Miss;
	cmp	p13, p10			// } while (bucket >= buckets)
	b.hs	1b

	// wrap-around:
	//   p10 = first bucket
	//   p11 = mask (and maybe other bits on LP64)
	//   p12 = _cmd & mask
	//
	// A full cache can happen with CACHE_ALLOW_FULL_UTILIZATION.
	// So stop when we circle back to the first probed bucket
	// rather than when hitting the first bucket again.
	//
	// Note that we might probe the initial bucket twice
	// when the first probed slot is the last entry.


#if CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_HIGH_16_BIG_ADDRS
	add	p13, p10, w11, UXTW #(1+PTRSHIFT)
						// p13 = buckets + (mask << 1+PTRSHIFT)
#elif CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_HIGH_16
	add	p13, p10, p11, LSR #(48 - (1+PTRSHIFT))
						// p13 = buckets + (mask << 1+PTRSHIFT)
						// see comment about maskZeroBits
#elif CACHE_MASK_STORAGE == CACHE_MASK_STORAGE_LOW_4
	add	p13, p10, p11, LSL #(1+PTRSHIFT)
						// p13 = buckets + (mask << 1+PTRSHIFT)
#else
#error Unsupported cache mask storage for ARM64.
#endif
	add	p12, p10, p12, LSL #(1+PTRSHIFT)
						// p12 = first probed bucket

						// do {
4:	ldp	p17, p9, [x13], #-BUCKET_SIZE	//     {imp, sel} = *bucket--
	cmp	p9, p1				//     if (sel == _cmd)
	b.eq	2b				//         goto hit
	cmp	p9, #0				// } while (sel != 0 &&
	ccmp	p13, p12, #0, ne		//     bucket > first_probed)
	b.hi	4b

LLookupEnd\Function:
LLookupRecover\Function:
	b	\MissLabelDynamic

#if CONFIG_USE_PREOPT_CACHES
#if CACHE_MASK_STORAGE != CACHE_MASK_STORAGE_HIGH_16
#error config unsupported
#endif
LLookupPreopt\Function:
#if __has_feature(ptrauth_calls)
	and	p10, p11, #0x007ffffffffffffe	// p10 = buckets
	autdb	x10, x16			// auth as early as possible
#endif

	// x12 = (_cmd - first_shared_cache_sel)
	adrp	x9, _MagicSelRef@PAGE
	ldr	p9, [x9, _MagicSelRef@PAGEOFF]
	sub	p12, p1, p9

	// w9  = ((_cmd - first_shared_cache_sel) >> hash_shift & hash_mask)
#if __has_feature(ptrauth_calls)
	// bits 63..60 of x11 are the number of bits in hash_mask
	// bits 59..55 of x11 is hash_shift

	lsr	x17, x11, #55			// w17 = (hash_shift, ...)
	lsr	w9, w12, w17			// >>= shift

	lsr	x17, x11, #60			// w17 = mask_bits
	mov	x11, #0x7fff
	lsr	x11, x11, x17			// p11 = mask (0x7fff >> mask_bits)
	and	x9, x9, x11			// &= mask
#else
	// bits 63..53 of x11 is hash_mask
	// bits 52..48 of x11 is hash_shift
	lsr	x17, x11, #48			// w17 = (hash_shift, hash_mask)
	lsr	w9, w12, w17			// >>= shift
	and	x9, x9, x11, LSR #53		// &=  mask
#endif

	ldr	x17, [x10, x9, LSL #3]		// x17 == sel_offs | (imp_offs << 32)
	cmp	x12, w17, uxtw

.if \Mode == GETIMP
	b.ne	\MissLabelConstant		// cache miss
	sub	x0, x16, x17, LSR #32		// imp = isa - imp_offs
	SignAsImp x0
	ret
.else
	b.ne	5f				// cache miss
	sub	x17, x16, x17, LSR #32		// imp = isa - imp_offs
.if \Mode == NORMAL
	br	x17
.elseif \Mode == LOOKUP
	orr x16, x16, #3 // for instrumentation, note that we hit a constant cache
	SignAsImp x17
	ret
.else
.abort  unhandled mode \Mode
.endif

5:	ldursw	x9, [x10, #-8]			// offset -8 is the fallback offset
	add	x16, x16, x9			// compute the fallback isa
	b	LLookupStart\Function		// lookup again with a new isa
.endif
#endif // CONFIG_USE_PREOPT_CACHES

.endmacro
```
#### 自己写的伪代码
```objc 
void objc_msgSend(id receiver,SEL selector){
  if (receiver == nil){
      return;
  }
  //查找缓存
}
```
### objc_msgSend执行流程01-消息发送
a. 调用方法结束查找并将方法缓存到reveiverClass的cache中
1. receiver是否为空，如果是直接return，否则继续执行
1. 从reveiverClass的cache中查找方法，如果找到方法调用方法结束，否则继续执行
1. 从reveiverClass的class_rw_t中查找方法，如果找到方法执行上面的a，否则继续执行
   > 已经排序的方法列表，二分查找  
   > 没有排序的，遍历查找 
1. 从superClass的cahce中查找方法，如果找到方法执行上面的a，否则继续执行
1. 从superClass的class_rw_t中查找方法，如果找到方法执行上面的a，否则继续执行
1. 上层是否还有superClass
   > 如果有：继续循环执行第4步  
   > 如果没有：进入objc_msgSend的第二阶段（动态方法解析）

⚠️ receiver通过isa指针找到receiverClass  
⚠️ receiverClass通过superclass指针找到superClass
### objc_msgSend执行流程02-动态方法解析
1. 是否曾经有动态解析，如果有消息转发，如果没有继续执行
1. 调用+resolveInstanceMethod:或者+resolveClassMethod:方法来动态解析方法
1. 标记为已经动态解析
1. 消息发送
- 开发者可以实现以下方法，来动态添加方法实现
  > +resolveInstanceMethod:  
  > +resolveClassMethod:
- 动态解析过后，会重新走“消息发送”的流程
  > “从receiverClass的cache中查找方法”这一步开始执行

源码
```objc
    if ((behavior & LOOKUP_RESOLVER)  &&  !triedResolver) {
        methodListLock.unlock();
        _class_resolveMethod(cls, sel, inst);
        triedResolver = YES;
        goto retry;
    }
```
### objc_msgSend执行流程03-消息转发
#### 源码
```objc
 // No implementation found, and method resolver didn't help. 
    // Use forwarding.
    _cache_addForwardEntry(cls, sel);
    methodPC = _objc_msgForward_impcache;
```
#### 步骤
1. 调用forwardingTargetForSelector方法，如果返回值不为nil，调用objc_msgSend(返回值，SEL);如果返回值为nil，则继续第2步
1. 调用methodSignatureForSelector方法，如果返回值为nil，调用doesNotRecognizeSelector:方法，如果返回值不为空，调用forwardInvocation  

#### _objc_msgForward_impcache的内部实现（精简）:
```objc
int __forwarding__(void *frameStackPointer, int isStret) {
    id receiver = *(id *)frameStackPointer;
    SEL sel = *(SEL *)(frameStackPointer + 8);
    const char *selName = sel_getName(sel);
    Class receiverClass = object_getClass(receiver);

    // 调用 forwardingTargetForSelector:
    if (class_respondsToSelector(receiverClass, @selector(forwardingTargetForSelector:))) {
        id forwardingTarget = [receiver forwardingTargetForSelector:sel];
        if (forwardingTarget && forwardingTarget != receiver) {
            return objc_msgSend(forwardingTarget, sel, ...);
        }
    }

    // 调用 methodSignatureForSelector 获取方法签名后再调用 forwardInvocation
    if (class_respondsToSelector(receiverClass, @selector(methodSignatureForSelector:))) {
        NSMethodSignature *methodSignature = [receiver methodSignatureForSelector:sel];
        if (methodSignature && class_respondsToSelector(receiverClass, @selector(forwardInvocation:))) {
            NSInvocation *invocation = [NSInvocation _invocationWithMethodSignature:methodSignature frame:frameStackPointer];

            [receiver forwardInvocation:invocation];

            void *returnValue = NULL;
            [invocation getReturnValue:&value];
            return returnValue;
        }
    }

    if (class_respondsToSelector(receiverClass,@selector(doesNotRecognizeSelector:))) {
        [receiver doesNotRecognizeSelector:sel];
    }

    // The point of no return.
    kill(getpid(), 9);
}
```
1. 调用forwardingTargetForSelector方法
```objc
- (id)forwardingTargetForSelector:(SEL)aSelector{
	if (aSelector == @selector(test)){
      return <能处理消息的实例对象>
	}
   return [super forwardingTargetForSelector:aSelector];
}

+ (id)forwardingTargetForSelector:(SEL)aSelector{
   return <能处理消息的类对象>
}
```
2. 调用 methodSignatureForSelector 获取方法签名后再调用 forwardInvocation
```objc
//方法签名：返回值类型、参数类型
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
   if (aSelector == @selector(test)){
	   return [NSMethodSignature signatureWithObjcTypes:@"v16@0:8"];
   }
   return [super methodSignatureForSelector:aSelector];
}
// NSInvocation封装了一个方法调用，包括：方法调用者、方法名、方法参数
/*
anInvocation.target 方法调用者
anInvocation.selector 方法名
[anInvocation getArgument:NULL atIndex:0]
*/
- (void)forwardInvocation:(NSInvocation *)anInvocation{
   anInvocation.target = 对象;
   [anInvocation invoke];
   //或者
   [anInvocation invokeWithTarget:对象];
}
```
## 【super message】的底层实现
- 消息接收者仍然是子类对象
- 从夫类开始查找方法的实现
```objc
- (Class)class{
	return object_getClass(self);
}
```
```objc
- (Class)superclass{
	return class_getSuperclass(object_getClass(self));
}
```
### 涉及super的底层代码
```objc
+ (Class)superclass {
    return self->getSuperclass();
}

- (Class)superclass {
    return [self class]->getSuperclass();
}

+ (BOOL)isMemberOfClass:(Class)cls {
    return self->ISA() == cls;
}

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

+ (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = self->ISA(); tcls; tcls = tcls->getSuperclass()) {
        if (tcls == cls) return YES;
    }
    return NO;
}

- (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = [self class]; tcls; tcls = tcls->getSuperclass()) {
        if (tcls == cls) return YES;
    }
    return NO;
}
```
### super的本质
#### super调用，底层会转换为objc_msgSendSuper2函数的调用，接收2个参数
```objc
struct objc_super2 {
	id receiver;//消息接收者
	Class current_class;//current_class是receiver的Class对象
}
```

## 面试题
### 讲一下 OC 的消息机制
#### OC中的方法调用其实都是转成了objc_msgSend函数的调用，给receiver（方法调用者）发送了一条消息（selector方法名）
#### objc_msgSend底层有3大阶段
- 消息发送（当前类、父类中查找）
- 动态方法解析
- 消息转发
### 什么是Runtime？平时项目中有用过么？
#### OC是一门动态性比较强的编程语言，允许很多操作推迟到程序运行时再进行
#### OC的动态性就是由Runtime来支撑和实现的，Runtime是一套C语言的API，封装了很多动态性相关的函数
#### 平时编写的OC代码，底层都是转换成了Runtime API进行调用
### 具体应用
- 利用关联对象（AssociatedObject）给分类添加属性
- 遍历类的所有成员变量（修改textfield的占位文字颜色、字典转模型、自动归档解档）
- 交换方法实现（交换系统的方法）
- 利用消息转发机制解决方法找不到的异常问题
### 打印结果分别是什么？
```objc
@interface MJPerson:NSObject
@end

@interface MJStudent:MJPerson
@end
@implementation MJStudent
- (instancetype)init{
	if (self = [super init]){
		//MJStudent
        NSLog(@"%@",[self class]);
        //MJStudent
        NSLog(@"%@",[super class]);
        //MJPerson
        NSLog(@"%@",[self superclass]);
        //MJPerson
        NSLog(@"%@",[super superclass]);
        
        //1(这个是Runtime的指针图，NSObject的元类最终指向类对象，所以是1)
        NSLog(@"%d",[[NSObject class] isKindOfClass:[NSObject class]]);
        //0
        NSLog(@"%d",[[NSObject class] isMemberOfClass:[NSObject class]]);
        //0
        NSLog(@"%d",[[MJPerson class] isKindOfClass:[MJPerson class]]);
        //0
        NSLog(@"%d",[[MJPerson class] isMemberOfClass:[MJPerson class]]);
	}
	 return  self;
}
@end
```
### 以下代码能不能执行成功？如果可以，打印结果是什么？
```objc
@interface MJPerson : NSObject
@property (nonatomic, copy) NSString *name;
- (void)print;
@end
@implementation MJPerson
- (void)print{
	//[ViewController class]，原理是【super ViewDidLoad】会生成一个ViewController的结构体，cls相当于isa，obj相当于MJPerson的指针，打印name就是打印isa指针后面的8个字节，8个字节刚好就是ViewControler的结构体
	NSLog(@"%@",self.mame);
}
@end
@implementation ViewController
- (void)viewDidLoad{
	[super viewDidLoad];
	id cls = [MJPerson class];
	void *obj = &cls;
	[(__bridge id)obj print];
}
@end
```
[super viewDidLoad]会调用_objc_msgSendSuper或者_objc_msgSendSuper2
```objc
	ENTRY _objc_msgSendSuper
	UNWIND _objc_msgSendSuper, NoFrame
	
// search the cache (objc_super in %a1)
	movq	class(%a1), %r10	// class = objc_super->class
	movq	receiver(%a1), %a1	// load real receiver
	// calls IMP on success
	CacheLookup NORMAL, CALL, _objc_msgSendSuper

// cache miss: go search the method lists
LCacheMiss_objc_msgSendSuper:
	// class still in r10
	jmp	__objc_msgSend_uncached
	
	END_ENTRY _objc_msgSendSuper
```

```objc
	ENTRY _objc_msgSendSuper2
	UNWIND _objc_msgSendSuper2, NoFrame
	
	// objc_super->class is superclass of class to search
	
// search the cache (objc_super in %a1)
	movq	class(%a1), %r10	// cls = objc_super->class
	movq	receiver(%a1), %a1	// load real receiver
	movq	8(%r10), %r10		// cls = class->superclass
	// calls IMP on success
	CacheLookup NORMAL, CALL, _objc_msgSendSuper2

// cache miss: go search the method lists
LCacheMiss_objc_msgSendSuper2:
	// superclass still in r10
	jmp	__objc_msgSend_uncached
	
	END_ENTRY _objc_msgSendSuper2
```

## LLVM的中间代码
### OC-> 中间代码(.ll) -> 汇编、机器代码
### Objective-C在变为机器代码之前，会被LLVM编译器转换为中间代码（Intermediate Representation）
### 可以使用以下命令行指令生成中间代码
```objc
clang -emit-llvm -S main.m
```
### 语法简介
- @ - 全局变量
- % - 局部变量
- alloca - 在当前执行的函数的堆栈帧中分配内存，当该函数返回到其调用者时，将自动释放内存
- i32 - 32位4字节的整数
- align - 对齐
- load - 读出，store 写入
- icmp - 两个整数值比较，返回布尔值
- br - 选择分支，根据条件来转向label，不根据条件跳转的话类似 goto
- label - 代码标签
- call - 调用函数
### 具体可以参考官方文档：https://llvm.org/docs/LangRef.html


## Runtime-API
### API - 类
动态创建一个类（参数：父类，类名，额外的内存空间）
```objc
Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)
```
注册一个类（要在类注册之前添加成员变量）
```objc
void objc_registerClassPair(Class cls) 
```
销毁一个类
```objc
void objc_disposeClassPair(Class cls)
```
获取isa指向的Class
```objc
Class object_getClass(id obj)
```
设置isa指向的Class
```objc
Class object_setClass(id obj, Class cls)
```
判断一个OC对象是否为Class
```objc
BOOL object_isClass(id obj)
```
判断一个Class是否为元类
```objc
BOOL class_isMetaClass(Class cls)
```
获取父类
```objc
Class class_getSuperclass(Class cls)
```
### API - 成员变量
获取一个实例变量信息
```objc
Ivar class_getInstanceVariable(Class cls, const char *name)
```
拷贝实例变量列表（最后需要调用free释放）
```objc
Ivar *class_copyIvarList(Class cls, unsigned int *outCount)
```
设置和获取成员变量的值
```objc
void object_setIvar(id obj, Ivar ivar, id value)
id object_getIvar(id obj, Ivar ivar)
```
动态添加成员变量（已经注册的类是不能动态添加成员变量的）
```objc
BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types)
```
获取成员变量的相关信息
```objc
const char *ivar_getName(Ivar v)
const char *ivar_getTypeEncoding(Ivar v)
```
### API - 属性
获取一个属性
```objc
objc_property_t class_getProperty(Class cls, const char *name)
```

拷贝属性列表（最后需要调用free释放）
```objc
objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
```

动态添加属性
```objc
BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
                  unsigned int attributeCount)
```

动态替换属性
```objc
void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
                      unsigned int attributeCount)
```
获取属性的一些信息
```objc
const char *property_getName(objc_property_t property)
const char *property_getAttributes(objc_property_t property)
```
### API - 方法
获得一个实例方法、类方法
```objc
Method class_getInstanceMethod(Class cls, SEL name)
Method class_getClassMethod(Class cls, SEL name)
```
方法实现相关操作
```objc
IMP class_getMethodImplementation(Class cls, SEL name) 
IMP method_setImplementation(Method m, IMP imp)
void method_exchangeImplementations(Method m1, Method m2) 
```
- method_exchange的源码
```objc
void method_exchangeImplementations(Method m1, Method m2)
{
    if (!m1  ||  !m2) return;

    mutex_locker_t lock(runtimeLock);

    IMP imp1 = m1->imp(false);
    IMP imp2 = m2->imp(false);
    SEL sel1 = m1->name();
    SEL sel2 = m2->name();

    m1->setImp(imp2);
    m2->setImp(imp1);


    // RR/AWZ updates are slow because class is unknown
    // Cache updates are slow because class is unknown
    // fixme build list of classes whose Methods are known externally?

    flushCaches(nil, __func__, [sel1, sel2, imp1, imp2](Class c){
        return c->cache.shouldFlush(sel1, imp1) || c->cache.shouldFlush(sel2, imp2);
    });

    adjustCustomFlagsForMethodChange(nil, m1);
    adjustCustomFlagsForMethodChange(nil, m2);
}
```
- 交换方法清除方法缓存的源码
```objc
static void flushCaches(Class cls, const char *func, bool (^predicate)(Class))
{
    runtimeLock.assertLocked();
#if CONFIG_USE_CACHE_LOCK
    mutex_locker_t lock(cacheUpdateLock);
#endif

    const auto handler = ^(Class c) {
        if (predicate(c)) {
            c->cache.eraseNolock(func);
        }

        return true;
    };

    if (cls) {
        foreach_realized_class_and_subclass(cls, handler);
    } else {
        foreach_realized_class_and_metaclass(handler);
    }
} 
```

拷贝方法列表（最后需要调用free释放）
```objc
Method *class_copyMethodList(Class cls, unsigned int *outCount)
```
动态添加方法
```objc
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)
```
动态替换方法
```objc
IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
```
获取方法的相关信息（带有copy的需要调用free去释放）
```objc
SEL method_getName(Method m)
IMP method_getImplementation(Method m)
const char *method_getTypeEncoding(Method m)
unsigned int method_getNumberOfArguments(Method m)
char *method_copyReturnType(Method m)
char *method_copyArgumentType(Method m, unsigned int index)
```
选择器相关
```objc
const char *sel_getName(SEL sel)
SEL sel_registerName(const char *str)
```
用block作为方法实现
```objc
IMP imp_implementationWithBlock(id block)
id imp_getBlock(IMP anImp)
BOOL imp_removeBlock(IMP anImp)
```

## 方法交换拦截系统方法
### 按钮的点击事件
```objc
+ (void)load
{
    // hook：钩子函数
    Method method1 = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method method2 = class_getInstanceMethod(self, @selector(mj_sendAction:to:forEvent:));
    method_exchangeImplementations(method1, method2);
}

- (void)mj_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    // 调用系统原来的实现
    [self mj_sendAction:action to:target forEvent:event]; 
//    if ([self isKindOfClass:[UIButton class]]) {
//        // 拦截了所有按钮的事件
//
//    }
}
```
### 数组的添加事件
```objc
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇：NSString、NSArray、NSDictionary，真实类型是其他类型
        Class cls = NSClassFromString(@"__NSArrayM");
        Method method1 = class_getInstanceMethod(cls, @selector(insertObject:atIndex:));
        Method method2 = class_getInstanceMethod(cls, @selector(mj_insertObject:atIndex:));
        method_exchangeImplementations(method1, method2);
    });
}

- (void)mj_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject == nil) return;
    
    [self mj_insertObject:anObject atIndex:index];
}
```
### 字典的事件
```objc
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"__NSDictionaryM");
        Method method1 = class_getInstanceMethod(cls, @selector(setObject:forKeyedSubscript:));
        Method method2 = class_getInstanceMethod(cls, @selector(mj_setObject:forKeyedSubscript:));
        method_exchangeImplementations(method1, method2);
        
        Class cls2 = NSClassFromString(@"__NSDictionaryI");
        Method method3 = class_getInstanceMethod(cls2, @selector(objectForKeyedSubscript:));
        Method method4 = class_getInstanceMethod(cls2, @selector(mj_objectForKeyedSubscript:));
        method_exchangeImplementations(method3, method4);
    });
}

- (void)mj_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if (!key) return;
    
    [self mj_setObject:obj forKeyedSubscript:key];
}

- (id)mj_objectForKeyedSubscript:(id)key
{
    if (!key) return nil;
    
    return [self mj_objectForKeyedSubscript:key];
}
```
### 也可以用Runtin实现fontSize全局适配字体
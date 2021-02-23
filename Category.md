# Category  
## 通过runtime动态将分类方法合并到类对象、元类对象中
## 生成分类的编译文件
```
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc MJRefresh+Footer.m
```
## 一个分类最终都转换成一个结构体
```objc
struct _category_t {
    const char *name;
    struct _class_t *cls;
    const struct _method_list_t *instance_methods;
    const struct _method_list_t *class_methods;
    const struct _protocol_list_t *protocols;
    const struct _prop_list_t *properties;
}
```
## Category的底层结构
定义在objc-runtime-new.h中
```objc
struct category_t {
    const char *name;
    classref_t cls;
    WrappedPtr<method_list_t, PtrauthStrip> instanceMethods;
    WrappedPtr<method_list_t, PtrauthStrip> classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
    // Fields below this point are not always present on disk.
    struct property_list_t *_classProperties;

    method_list_t *methodsForMeta(bool isMeta) {
        if (isMeta) return classMethods;
        else return instanceMethods;
    }

    property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
    
    protocol_list_t *protocolsForMeta(bool isMeta) {
        if (isMeta) return nullptr;
        else return protocols;
    }
};
```

## Category的加载处理过程
- 通过Runtime加载某个类的所有Category数据
- 把所有Category的方法、属性、协议数据，合并到一个大数组中
  > 后面参与编译的Category数据，会在数组的前面
- 将合并后的分类（方法、属性、协议），插入到类原来数据的前面

## Category的objc源码读解顺序
- objc-os.mm
  > _objc_init  
  > //images是镜像、模块的意思  
  > map_images  
  > map_images_nolock  

- objc-runtime-new.mm
  > _read_images  
  > remethodizeClass(重新方法化，重新组织一下)  
  > attachCategories  
  > attachLists  
  > realloc、memmove、memcpy

```objc
    void attachLists(List* const * addedLists, uint32_t addedCount) {
        if (addedCount == 0) return;

        if (hasArray()) {
            // many lists -> many lists
            uint32_t oldCount = array()->count;
            uint32_t newCount = oldCount + addedCount;
            array_t *newArray = (array_t *)malloc(array_t::byteSize(newCount));
            newArray->count = newCount;
            array()->count = newCount;

            for (int i = oldCount - 1; i >= 0; i--)
                newArray->lists[i + addedCount] = array()->lists[i];
            for (unsigned i = 0; i < addedCount; i++)
                newArray->lists[i] = addedLists[i];
            free(array());
            setArray(newArray);
            validate();
        }
        else if (!list  &&  addedCount == 1) {
            // 0 lists -> 1 list
            list = addedLists[0];
            validate();
        } 
        else {
            // 1 list -> many lists
            Ptr<List> oldList = list;
            uint32_t oldCount = oldList ? 1 : 0;
            uint32_t newCount = oldCount + addedCount;
            setArray((array_t *)malloc(array_t::byteSize(newCount)));
            array()->count = newCount;
            if (oldList) array()->lists[addedCount] = oldList;
            for (unsigned i = 0; i < addedCount; i++)
                array()->lists[i] = addedLists[i];
            validate();
        }
    }
```
  > 后编译的分类会覆盖（假）前面相同的方法，编译的顺序根据Build Phases->Compile Sources的顺序编译

## Category的实现原理
- Category编译之后的底层结构是struct category_t，里面储存着分类的对象方法、类方法、属性、协议信息
- 在程序运行的时候，runtime会将Category的数据，合并到类信息中(类对象、元类对象中)

## Category和Class Extension的区别是什么？
- Class Extension在编译的时候，它的数据就已经包含在类信息中
- Category是在运行时才会将数据合并到类信息中

## +load方法解读
- +load方法会在runtime加载类、分类时调用
- 每个类、分类的+load，在程序运行过程中只调用一次
- 调用顺序(和编译顺序无关)
  > 先调用类的+load（所有的都调用完了才调用分类）  
  >> 1. 按照编译  
  >> 2. 调用子类的+load之前会先调用夫类的+load  
  >
  > 再调用分类的+load
  > 按照编译先后顺序调用(先编译，先调用)  

顺序的原理是：调用的时候，是从0开始遍历load的数组，load的数组处理的时候，是使用add添加的，先add夫类的load，再add Category的load

- load方法源码解读过程  
objc-os.mm  
  > _objc_init  
  > load_images  
  > prepare_load_methods
  >> schedule_class_load  
  >> add_class_to_loadable_list  
  >> add_category_to_loadable_list  
  > 
  > call_load_methods  
  >> call_class_loads  
  >> call_category_loads  
  >> (*load_method)(cls,SEL_load)

```objc
void call_load_methods(void)
{
    static bool loading = NO;
    bool more_categories;

    loadMethodLock.assertLocked();

    // Re-entrant calls do nothing; the outermost call will finish the job.
    if (loading) return;
    loading = YES;

    void *pool = objc_autoreleasePoolPush();

    do {
        // 1. Repeatedly call class +loads until there aren't any more
        while (loadable_classes_used > 0) {
            call_class_loads();
        }

        // 2. Call category +loads ONCE
        more_categories = call_category_loads();

        // 3. Run more +loads if there are classes OR more untried categories
    } while (loadable_classes_used > 0  ||  more_categories);

    objc_autoreleasePoolPop(pool);

    loading = NO;
}
```
 
## +initialize方法解读
- initialize方法会在类第一次收到消息的时候调用
- 调用顺序：
  > 先调用夫类的+initialize再调用子类+initialize
  > 先初始化夫类，再初始化子类，每个类只会初始化一次
- 源码解读过程
> objc-msg-arm64.s
>> objc_msgSend
>    
> objc-runtime-new.mm  
>> class_getInstanceMethod  
>> lookUpImpOrNil  
>> lookUpImpOrForward  
>> _class_initialize  
>> callInitialize   
>> objc_msgSend(cls,SEL_initialize)

```objc
NEVER_INLINE
IMP lookUpImpOrForward(id inst, SEL sel, Class cls, int behavior)
{
    const IMP forward_imp = (IMP)_objc_msgForward_impcache;
    IMP imp = nil;
    Class curClass;

    runtimeLock.assertUnlocked();

    if (slowpath(!cls->isInitialized())) {
        // The first message sent to a class is often +new or +alloc, or +self
        // which goes through objc_opt_* or various optimized entry points.
        //
        // However, the class isn't realized/initialized yet at this point,
        // and the optimized entry points fall down through objc_msgSend,
        // which ends up here.
        //
        // We really want to avoid caching these, as it can cause IMP caches
        // to be made with a single entry forever.
        //
        // Note that this check is racy as several threads might try to
        // message a given class for the first time at the same time,
        // in which case we might cache anyway.
        behavior |= LOOKUP_NOCACHE;
    }
     ...
    //此处省略很多代码
    
    //这里会调用
    cls = realizeAndInitializeIfNeeded_locked(inst, cls, behavior & LOOKUP_INITIALIZE);
    ...
    //此处省略很多代码
    return imp;
}

static Class
realizeAndInitializeIfNeeded_locked(id inst, Class cls, bool initialize)
{
    runtimeLock.assertLocked();
    if (slowpath(!cls->isRealized())) {
        cls = realizeClassMaybeSwiftAndLeaveLocked(cls, runtimeLock);
        // runtimeLock may have been dropped but is now locked again
    }

    if (slowpath(initialize && !cls->isInitialized())) {
        cls = initializeAndLeaveLocked(cls, inst, runtimeLock);
        // runtimeLock may have been dropped but is now locked again

        // If sel == initialize, class_initialize will send +initialize and
        // then the messenger will send +initialize again after this
        // procedure finishes. Of course, if this is not being called
        // from the messenger then it won't happen. 2778172
    }
    return cls;
}
```
##  +load和+initialize的区别
- +initialize是通过objc_msgSend进行调用的
- 如果子类没有实现+initialize，会调用夫类的+initialize（所以夫类的+initialize可能会被调用多次）
```objc
//+initialize
if(自己没有初始化){
  if(夫类没有初始化){
    objc_msgSend([夫类 class],@selector(initialize))
  } 
  objc_msgSend([自己 class],@selector(initialize))
}
```
- 调用方式
> load是根据函数地址直接调用  
> initialize是通过objc_msgSend调用
- 调用时刻
> load是runtime加载类、分类的时候调用（只会调用1次）  
> initialize是类第一次接收到消息的时候调用，每一个类只会initialize一次（夫类的initialize方法可能会被调用多次）
- 调用顺序
> load  
>> 先调用类的load  
>> 1. 先编译的类，优先调用load
>> 1. 调用子类的load之前，会先调用夫类的load  
>>
>> 再调用分类的load
>> 1. 先编译的分类，优先调用load
>>
> initialize  
>> 先初始化夫类
>> 再初始化子类(可能最终调用的是夫类的initialize方法)

## Category中添加属性
### 分类中不能添加成员变量
### 添加属性之后，会自动生成set和get方法，但是set和get什么都没有处理
### 自己处理set和get
```objc
@property (copy, nonatomic) NSString *name;
```
```objc
- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name
{
    // 隐式参数
    // _cmd == @selector(name)
    return objc_getAssociatedObject(self, _cmd);
}
```
```objc
@property (assign, nonatomic) int weight;
```
```objc
- (void)setWeight:(int)weight
{
    objc_setAssociatedObject(self, @selector(weight), @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)weight
{
    // _cmd == @selector(weight)
    return [objc_getAssociatedObject(self, _cmd) intValue];
}
```
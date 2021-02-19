# KVO
#### DSMessage类为例，以text属性(@property(nonatomic,copy)NSString *text)为例

## 添加了KVO的类，runtime会动态生成一个NSKVONotifying_的子类(如DSMessage，会动态生成一个NSKVONotifying_DSMessage类) ，并让instance对象的isa指向这个全新的子类
- 当instance属性发生改变的时候，会通过NSKVONotifying_DSMessage子类中的set方法调用_NSSet*ValueAndNotify方法
```objc
- (void)setText:(NSString*)text{
  _NSSetObjectValueAndNotify();  
}
```
- 调用_NSSet*ValueAndNotify的内部方法
```objc
//如果监听的对象是object就是_NSSetObjectValueAndNotify，如果是int就是_NSSetIntValueAndNotify，如果是double就是_NSSetDoubleValueAndNotify
_NSSetObjectValueAndNotify
_NSSetIntValueAndNotify
_NSSetDoubleValueAndNotify
_NSSetCharValueAndNotify
....
```
```objc
void _NSSetObjectValueAndNotify(){
 [self willChangeValueForKey:@"text"];
 //调用原来的set方法
 [super setText:age];
 [self didChangeValueForKey:@"text"];
}

- (void)didChangeValueForKey:(NSString*)key{
    //通知监听器，某个属性的值发生改变
    [observer observeValueForKeyPath:key ofObject:self change:nil context:nil];
}
```
- didChangeValueForKey中会触发监听器（observer）的监听方法observeValueForKeyPath 



## NSKVONotifying_DSMessage 的内部实现
```objc
- (void)setText:(NSString*)text{
  _NSSetObjectValueAndNotify();  
}

void _NSSetObjectValueAndNotify(){
 [self willChangeValueForKey:@"text"];
 //调用原来的set方法
 [super setText:age];
 [self didChangeValueForKey:@"text"];
}

- (void)didChangeValueForKey:(NSString*)key{
    //通知监听器，某个属性的值发生改变
    [observer observeValueForKeyPath:key ofObject:self change:nil context:nil];
}
//屏蔽内部KVO的实现，隐藏NSKVONotifying_DSMessage类的存在
- (Class)class{
    return [DSMessage class];
}
- (void)dealloc{

}
- (BOOL)_isKVOA{
    return YES;
}
```

## 手动触发KVO
```objc
//一定要加willChangeValueForKey才行，不能只调didChangeValueForKey
 [self willChangeValueForKey:@"text"];
 [self didChangeValueForKey:@"text"];
```

## 手动修改属性的值，不会触发KVO
```objc
self->_text = @"32323"
```
KVO是通过set方法触发的

## 窥探Foundation
使用Hopper Disassembler反编译软件工具打开./Static/Foundation文件即可查看，内部可以找到_NSSet*ValueAndNotify方法
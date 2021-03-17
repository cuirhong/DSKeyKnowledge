# KVC  
Key-Value Coding

## setValue: forKey和setValue:forKeyPath
forKeyPath可以设置对象的子属性

## KVC也能触发KVO的监听

## KVC赋值的原理
- 首先会去寻找setKey，如果没有寻找_setKey
- 以上两个没找到，查看accessInstanceVariablesDirectly(是否允许访问成员变量)，如果返回NO，则调用setValue:forundefinedKey:并抛出异常NSUnknownKeyException
```objc
-(BOOL)accessInstanceVariablesDirectly{
    //如果返回YES，则会寻找成员变量，默认返回就是YESs
    return YES
}
```
- 如果accessInstanceVariablesDirectly返回YES，则顺序查找_key、_isKey、key、isKey成员变量，如果找到直接赋值，如果没有则调用setValue:forundefinedKey:并抛出异常NSUnknownKeyException，找到成员变量会触发willChangeValueForKey和didChangeValueForKey，所以也是能触发KVO

## KVC取值的原理
- 会顺序查找getKey、key、isKey、_key的方法，存在直接返回值；如果不存在，查看accessInstanceVariablesDirectly返回值，如果返回NO调用setValue:forundefinedKey:并抛出异常NSUnknownKeyException
- accessInstanceVariablesDirectly返回YES，顺序查找成员变量（_key、_isKey、key、isKey），找到成员变量直接取值，没有找到调用setValue:forundefinedKey:并抛出异常NSUnknownKeyException


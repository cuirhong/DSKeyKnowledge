## debug调试，IMP打印
```objc
p (IMP)0x104f38b57
```
```objc
//输出结果
(IMP) $1 = 0x0000000104f38b57 (Foundation`_NSSetObjectValueAndNotify)
```
## debug调试，bt打印
bt可以打印出更多的线程信息
```objc
bt
```
## debug调试，si
```objc
// si调试可以一步一步执行汇编语言
si
```
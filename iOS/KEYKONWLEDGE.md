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
## debug调试
```objc
//打印一个对象的isa指针地址
p/x (long)person->isa
```
## 查看内存数据
步骤(快捷键：shift+commond+M)：Debug(Xcode)->Debug Workflow->View Memory->在底部的Address输入指针的地址值->回车键即可看到
```objc
/**
1个字节等于2个16进制字符
1个16进制位等于4个2进制位
2个16进制位等于8个2进制位，也就是一个字节 (一个字节等于8位)
/
```
## 常用的LLDB指令
### print、p ： 打印
### po : 打印对象
### 读取内存
- memory read/(数量+格式+字节数) 内存地址
```ruby
# 格式：x是16进制，f是浮点，d是10进制
# 字节大小：
# - b：byte 1字节
# - h：half word 2字节
# - w：word 4字节
# - g：giant word 8字节
memory read/3xw 0x10010
```
- x/(数量+格式+字节数) 内存地址
```ruby
x/3xw 0x10010
```
### 修改内存中的值
- memory write 内存地址 数值
```ruby
memory write 0x10010 10
```
## 苹果的源码库
https://opensource.apple.com/tarballs/


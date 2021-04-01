## Android studio打包
```android
打开Android studio->工具栏点击Build->点击Generate Signed bundle / APK -> 选择APK（点击next)->选择相应的keystore->点击next，等待完成(完成之后在工程目录下有一个release目录)
```
- 创建keystore文件
  - Key store path中添加文件后缀.keystore，创建完成之后不会自动添加
  - 密码要牢记，经常使用
  - Alias:别名（会用到，起一个合适的)
  - Certificate验证和应用市场上架有关系，后面不可修改
- 查看keystore文件的信息
```ruby
keytool -list -v -keystore 【文件绝对路径】
```
 

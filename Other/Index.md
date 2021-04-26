# Index
## markdown编写目录树
### 先全局安装tree
```ruby
npm i tree-node-cli -g
```
### 参数解析
```ruby
tree --help
```
-L 是确定要几级目录，-I是排除哪个文件夹下的，然后我是要在README里面生成项目结构树
### 生成目录
先cd到需要生成目录的文件夹下，然后输入
```ruby
tree -L 1 -I "node_modules" > README.md
```
生成的结果
```
expressDemo
├── TREE.md
├── app.js
├── bin
├── dist
├── package-lock.json
├── package.json
├── public
├── routes
└── views
```
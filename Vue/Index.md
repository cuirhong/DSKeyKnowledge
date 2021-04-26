# Vue
## 配置Vue CLI
[官方文档](https://cli.vuejs.org/zh/guide/creating-a-project.html#vue-create)
### 安装Node.js
- Mac OS使用brew安装
```ruby
brew install node
```
### 安装Vue CLI
```ruby
npm install -g @vue/cli
# OR
yarn global add @vue/cli
```
查看是否安装成功
```ruby
vue --version
```
### 创建Vue项目
命令行进入一个你想安装的文件夹，运行以下命令
```ruby
# my-project-demo是你的项目名称，根据提示选择合适的配置即可
vue create my-project-demo
```
你会被提示选取一个 preset。你可以选默认的包含了基本的 Babel + ESLint 设置的 preset，也可以选“手动选择特性”来选取需要的特性。
### 运行项目
```ruby
cd my-project-demo
npm run server
```
### 构建Vue项目
通过Ctrl-C停止运行后，构建项目。打包好的文件会存放在dist文件夹下。
```ruby
npm run build
```
但是dist文件夹下的index.html我们通过本地浏览器是打不开的，所以我们需要一个Node.js服务器，我使用的是Express。下面就进入Express的配置
## 配置Express
参考[官方文档](https://www.expressjs.com.cn/starter/installing.html)
### 安装Express
```ruby
mkdir myapp
cd myapp
```
通过 npm init 命令为你的应用创建一个 package.json 文件。
```ruby
npm init
```
此命令将要求你输入几个参数，例如此应用的名称和版本。 你可以直接按“回车”键接受大部分默认设置即可，下面这个除外：
```ruby
entry point: (index.js)
```
键入 app.js 或者你所希望的名称，这是当前应用的入口文件。如果你希望采用默认的 index.js 文件名，只需按“回车”键即可。

接下来在 myapp 目录下安装 Express 并将其保存到依赖列表中。如下：

```ruby
npm install express --save
```
### 创建项目
1. 方式一
  直接创建（推荐）
  ```ruby
  express my-project
  ```
2. 方式二

通过应用生成器工具 express-generator 可以快速创建一个应用的骨架。
```ruby
npx express-generator
```
对于较老的 Node 版本，请通过 npm 将 Express 应用程序生成器安装到全局环境中并执行即可。
```ruby
npm install -g express-generator
express
```
安装时会提示文件夹非空，是否确定安装，输入y然后回车即可  
然后安装所有依赖包：
```ruby
npm install
```
在 MacOS 或 Linux 中，通过如下命令启动此应用：
```ruby
DEBUG=myapp:* npm start
```
在 Windows 中，通过如下命令启动此应用：
```ruby
set DEBUG=myapp:* & npm start
```
然后在浏览器中打开 http://localhost:3000/ 网址就可以看到这个应用了。  
同样使用Ctrl-C停止运行，下面将Vue项目构建的文件部署到Express。
## 使用Express部署Vue项目
 
将Vue项目通过npm run build之后生成的dist文件夹复制到Express项目myapp文件夹
复制完成之后，myapp文件夹的目录树应该是这样的
```ruby
xxx/myapp
├── app.js
├── bin
├── dist
├── package-lock.json
├── package.json
├── public
├── routes
└── views
```
安装connect-history-api-fallback中间件
```ruby
npm install --save connect-history-api-fallback
```
安装完成以后，修改app.js
```js
// ----------------这两行被我们注释掉了-----------
// app.use('/', indexRouter);
// app.use('/users', usersRouter);
//---------------------------------------------

// ----------------这三行是我们新添加的-----------
var history = require('connect-history-api-fallback');
app.use(express.static(path.join(__dirname, 'dist')));
app.use(history());
//---------------------------------------------
```
让页面自动访问index.html

### 启动Express
```ruby
npm start
```
在浏览器中打开http://localhost:3000/，看到Vue的界面就大功告成了  
[参考文档](https://zhuanlan.zhihu.com/p/116749549)
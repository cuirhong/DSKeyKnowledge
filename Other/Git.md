# Git命令
## 将远程仓库克隆到本地:
```ruby
$ git clone 你的仓库地址
$ git config --global user.name "你的名字ddecd或昵称"
$ git config --global user.email "你的邮箱"
```

##  提交代码
```ruby
#将当前目录所有文件添加到git暂存区
$ git add .    
 #提交并备注提交信息        
$ git commit -m “代码提交备注”    
#将本地提交推送到远程仓库        
$ git push                      
```

## 创建分支
- 方式一: 
```ruby
$ git checkout -b dev 
```
Switched to a new branch 'dev'     (已经成功创建并切换到了dev分支)

- 方式二:
```ruby
$ git branch dev
$ git checkout dev 
```

指定提交版本创建分支：
```ruby
git branch feature/dev  <提交版本号>
```

## 合并分支(将dev分支合并到master分支)
```ruby
$ git checkout master
```
```ruby
$ git merge dev
```
查看是否有冲突，没有冲突直接push提交代码，有冲突走冲突解决

## 解决冲突
- $ git status (查看有冲突的文件)
- 解决冲突：
  - 方式一：打开对应文件解决冲突
  - 方式二：$ git mergettool

## 强制拉取代码(覆盖本地)
```ruby
git fetch --all
git reset --hard origin/dev
git pull

# 单条执行 
git fetch --all && git reset -hard origin/dev && git pull
```

## 清除git本地缓存(.gitignore文件不生效)
```dart
git rm -r --cached .
```
如果上清除不生效：
- 文件之前被提交过，需要删除该文件，先提交一次
- 提交之后再生成该文件则会被忽略

## 本地git与远程关联/删除
```ruby
# 关联 
git remote add origin 远程地址
# 删除
git remote remove origin
```

## 删除分支
删除远程分支：
```ruby
git push origin --delete <远程分支名字>
git push origin :<远程分支名字> 
```

删除本地分支: 
安全删除
```ruby
git branch -d <本地分支名字>
```
强制删除
```ruby
git branch -D <分支名字>
```
## 在当前分支拉取其他分支
```ruby
git fetch origin master:master
git pull origin master:master(这种会和当前分支merge)
```

##  查看某一个分支是否被合并过
```ruby
git log 分支名
git log master | grep commitid  如果包含过就证明已经合并过
```

##  同步本地的远程分支
```ruby
#可以发现红框中的分支是远程分支已经被删除的分支
git remote show origin  
# 根据提示可以使用 git remote prune  来同步删除这些分支
git remote prune 
```
 

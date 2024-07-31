# Git常用操作

**git常用操作**

git remote -v  **查看本地的远程仓库**

git fetch **更新远程分支列表**

git clone -b branch repository_url **git指定分支克隆**

git branch --show-current **显示当前分支**

----

拉取远程分支，本地并切换到这个分支

1. 首先，使用**git fetch**命令来更新远程分支列表。

1. 1. git fetch

1. 然后，使用**git checkout**命令创建并切换到一个新的本地分支，该分支将会与远程分支关联。

1. 1. **git checkout -b 本地分支名 origin/远程分支名**
   2. 例如有远程分支(feature)  ：git checkout -b feature origin/feature

---

未关联git仓库，且本地代码版本比远程仓库代码版本高，如何将代码提交到远程仓库

1. 初始化本地仓库
   ```git
   git init
   ```

2. 添加远程仓库
   ```git
   git remote add origin https://github.com/yourusername/your-repo.git
   ```

3. 将本地仓库代码提交
   ```git
   git add .
   git commit -m "Initial commit with modifications"
   ```

4. 拉取远程仓库的最新修改，并允许不相关的历史记录
   ```git
   git pull origin master --allow-unrelated-histories
   ```

5. 解决冲突(如果有)
   如果在拉取远程更改时出现冲突，需要手动解决
   在手动解决后需要提交解决冲突的文件

   ```git
   git add .
   git commit -m "Resolved merge conflict"
   ```

6. 推送本地更改到远程仓库
   ```git
   git push -u origin master
   ```

----

Git 配置user.name & user.email

查看全局配置的用户名和邮箱

```bash
git config --global user.name
git config --global user.email
```

查看当前项目的用户名和邮箱

```bash
git config --local user.name
git config --local user.email
```

配置全局用户名和邮箱

```bash
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱@example.com"
```

配置当前项目的用户名和邮箱

```bash
git config --local user.name "你的用户名"
git config --local user.email "你的邮箱@example.com"
```

----

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

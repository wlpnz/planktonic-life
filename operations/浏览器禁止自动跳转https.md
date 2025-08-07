### 浏览器禁止自动跳转https

#### chrome

- 地址栏中输入 chrome://net-internals/#hsts
- 可以先 Query 测试一下，再 delete。

#### edge

- 地址栏输入：edge://net-internals/#hsts
- 同样的，也具有 add， query，delete 功能

#### Safari

- 完全关闭Safari浏览器。
- 删除 ~/Library/Cookies/HSTS.plist 这个文件。
- 重新打开Safari即可（极少数情况下，可能需要重启系统）

#### Firefox 

- 关闭所有已打开的页面。
- 清空历史记录和缓存。
- 地址栏输入about:permissions
- 搜索项目域名，并点击 Forget About This Site
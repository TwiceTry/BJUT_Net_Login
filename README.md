## BJUT_Net_Login
Linux shell script for network of BJUT including wifi,lgn,broadband.
用于北京工业大学校园网认证的shell脚本

***

北工大校园网认证服务同时运行多种网络环境，目前已知有bjut_wifi，寝室光满wifi，传统网线接口三种

|网络环境|初次认证页面|二次认证页面|
|-|-|-|
|bjut_wifi|wlgn.bjut.edu.cn|无|
|寝室光满wifi|10.21.221.98|lgn.bjut.edu.cn|
|传统网络接口|lgn.bjut.edu.cn|无|

三种网络环境认证后均可访问lgn.bjut.edu.cn，导致难以识别
故本人以shell脚本利用curl命令实现自动识别三种网络环境并进行认证登录
***
本脚本为校园网内自用linux主机自动联网使用

脚本文件中每一步都有中文注释，使用其他语言的同学可以参考具体方法
## 简单使用
克隆所有文件到运行目录 
赋予CaseLogin.sh执行权限
使用方式CaseLogin.sh username password

## 更新记录
 2023-04-26 更新网络环境判定方法 

~~2023-04-21 纯lgn.bjut.edu.cn网络访问不了Blgn服务 自动判定失效~~

## 更多玩法
### 指定网络接口
适合多网卡用户
```
CaseLogin.sh username password interface
```
### 维持登录 
添加crontab 定时任务
```
*/10 * * * * {你的文件夹路径}/CaseLogin.sh 参数
```
为每10分钟执行登录

### 单一网络页面认证
net_login_methods文件夹中有各个页面的登录脚本
|网络环境|初次认证页面|认证脚本名|
|-|-|-|
|bjut_wifi|wlgn.bjut.edu.cn|Wlgn.sh|
|寝室光满wifi|10.21.221.98|Blgn.sh|
|传统网络接口|lgn.bjut.edu.cn|lgn.sh|
## 其他
json字符串解析使用到：
<span>&nbsp;&nbsp;&nbsp;&nbsp;<span><a href="https://github.com/dominictarr/JSON.sh">dominictarr/JSON.sh</a>
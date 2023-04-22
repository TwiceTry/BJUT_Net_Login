# BJUT_Net_Login
Linux shell script for network of BJUT including wifi,lgn,broadband.
用于北京工业大学校园网认证的shell脚本 
# 介绍
主要使用curl命令，如环境中无curl请自行安装，额外参数利用了curl指定网络接口功能   
具体用法在文件中的注释写了一遍
##### json字符串解析使用到：
<span>&nbsp;&nbsp;&nbsp;&nbsp;<span><a href="https://github.com/dominictarr/JSON.sh">dominictarr/JSON.sh</a>
## 简单使用
克隆所有文件到运行目录 
给CaseLogin.sh执行权限
使用方式CaseLogin.sh username password
### CaseLogin.sh文件 
#### 2023-4-21 纯lgn.bjut.edu.cn网络访问不了Blgn服务 CaseLogin失效（待更新）
此文件为自动识别网络环境并执行对应登录脚本
登录脚本为net_login_methods中脚本
## 更多玩法
### 指定网络接口（适合多网卡用户）
```
CaseLogin.sh username password interface
```
### 维持登录 
添加crontab 定时任务
```
*/10 * * * * {你的文件夹路径}/CaseLogin.sh 参数
```
为每10分钟执行登录

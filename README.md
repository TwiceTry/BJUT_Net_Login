# BJUT_Net_Login
Linux shell script for network of bjut including wifi,lgn,broadband. 
# 文件介绍
使用curl命令，如环境中无curl请自行安装，所有脚本均支持指定网卡   
具体用法文件注释也写了一遍
## lgnall.sh
分不清网络环境或混合网络环境时使用  
必须文件中填入关键信息  
识别网络环境，再调用对应脚本故此脚本需要 Broadband_login.sh  lgn.sh  wifi_login.sh  
## Broadband_login.sh 
适合寝室新装运营商光猫（BJUT_WIFI_2.4G，BJUT_WIFI_5G）使用  
可以文件中填入关键信息，也可带参数运行
## lgn.sh
适合全校网线插口，老的认证lgn.bjut.edu.cn网络下使用  
可以文件中填入关键信息，也可带参数运行
## lgnout.sh
全校网线插口，老的认证lgn.bjut.edu.cn网络 下注销认证  
可以文件中填入关键信息，也可带参数运行
支持 ipv6 单独认证
## wifi_login.sh
适合校园Wi-Fi: bjut_wifi使用  
可以文件中填入关键信息，也可带参数运行
# 使用方法
linux环境下，可以添加进开机启动，  
也可以添加crontab 定时任务  
如： */10 * * * * /lgnall.sh

#!/bin/ash
# 参数     id     pw     interface
# 参数解释 用户名  密码   网卡名（可选）
# bjut_wifi登录用 参考使用 wifi_login.sh id pw 
# bjut_wifi登录用 参考使用 wifi_login.sh id pw interface

 
# 也可在此处填写账号 密码 
cd $(cd "$(dirname "$0")"; pwd)
id=""
pw=""
interface=""
# interface 指定网卡
# 看不懂不要动下面的
#function rand(){                                                                                           
#    min=$1                                                                                                 
#    max=$2                                                                                                 
#    be=$(($max-$min+1))                                                                                    
#    num=$((`date +%s`+1000000000))                                                                         
#    echo $(($num%$max+$min))                                                                            #
#} 
#参数获取
if [ $# -ge 3 ]
then
    id=$1
    pw=$2
    interface=$3
fi
if [ $# -ge 2 ]
then
    id=$1
    pw=$2
fi

# 认证地址 2022.2.16 IP地址 10.21.250.3 -> 10.21.251.3 域名可用 wlgn.bjut.edu.cn
serip=10.21.251.3
# 请求浏览器标
ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"
# 获取状态
url0="http://"$serip"/drcom/chkstatus"        
ts=`date +%s`
ts=$ts'123'               
url0=$url0"?callback=dr1002&jsVersion=4.1&v=1234&lang=zh"

# wget -q -O status.json -U "$ua" $url0
if [ -z $interface ]
then
    curl -A "$ua" -o status.json -s -X GET $url0
else
    curl -A "$ua" -o status.json  --interface $interface -s -X GET $url0
fi
index=`grep -o -E "\"result\":[01]" status.json` 
bool=${index:9:1} # bash
if [ $bool -eq 1 ]
then
    echo "1"  # 已经登录了
    rm status.josn
    exit 0
fi

# 最小参数设置  但可上网

url="http://"$serip"/drcom/login?callback=dr1002&DDDDD="$id"&upass="$pw"&0MKKey=123456&R1=0&R2=&R3=0&R6=0&para=00&v6ip=&terminal_type=1&lang=zh%2Dcn&jsVersion=4.1&v=1234&lang=zh"


# 请求动作 

# wget -q -O result.json -U "$ua" $url
if [ -z $interface ]
then
    curl -A "$ua" -o result.json -s -X GET $url
else
    curl -A "$ua" -o result.json --interface $interface -s -X GET $url
fi
index=`grep  -o -E "\"result\":[01]" result.json`
bool=${index:9:1} # bash
if [ $bool -eq 1 ]
then
    echo "1"  # 登录成功
    rm result.json
else
    echo "0"    # 登录失败
fi


exit 0

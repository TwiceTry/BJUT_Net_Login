#!/bin/ash
# 参数  4/6                         interface
# 解释 ipv4/ipv6用 4或6 不填默认4    网卡名 可不填
# 下线用 参考使用 lgnout.sh 4
# 下线用 参考使用 lgnout.sh 6
# 下线用 参考使用 lgnout.sh 4 eth0
# 下线用 参考使用 lgnout.sh eth0 6
cd $(cd "$(dirname "$0")"; pwd)
errorfile="logout.log"
fake_header="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36 Edg/92.0.902.67"
url4="http://172.30.201.10/F.htm"
url6="http://[2001:da8:216:30c9::2]/F.htm"
v46="4" # 参数 获取默认值
interface=""
all_if=` ifconfig | grep ^[a-z0-9] | awk -F: '{print $1}' `
#判断所有参数 此sh 有2个参数 一为判断ipv4 ipv6 使用4或6传入；一为网卡名。无顺序
if [ $# -ge 1 ]
then
    para=$1
    case $para in
        "") pass=1 ;;
        "4") v46=4 ;;
        "6") v46=6 ;;
        *) result=` echo $all_if | grep "$para" `
        if [ "$result" != "" ]
        then 
        interface=$para
        fi
        ;;
    esac
    para=$2
    case $para in
        "") pass=1 ;;
        "4") v46=4 ;;
        "6") v46=6 ;;
        *) result=` echo $all_if | grep "$para" `
        if [ "$result" != "" ]
        then 
        interface=$para
        fi
        ;;
    esac    
fi
url=` eval echo '$'url${v46} `
echo $url $interface
if [ -z "$interface" ]
then
    res=` curl -o $errorfile -m 5 -A "$fake_header" -s "$url" -g `
else
    res=` curl -o $errorfile -m 5 -A "$fake_header" -s --interface "$interface" "$url" -g `
fi
Msg=`  cat $errorfile | grep -o -E "Msg=[1234567890]+;" `
Msg=${Msg:4:2}
if [ "$Msg" == "14" ]
then
    rm $errorfile
    echo '1'
else
    echo '0'
fi
exit 0

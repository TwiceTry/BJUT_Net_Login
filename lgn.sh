#!/bin/ash
# 参数 id     pw    4/6/46                     interface
# 解释 用户名 密码 ipv4/ipv6/ipv4+ipv6用 4或6或46 不填默认4    网卡名 可不填
#  参考使用 lgn.sh id password 
# lgn认证用 参考使用 lgn.sh id password 4
# lgn认证用 参考使用 lgn.sh id password 6 eth1
# lgn认证用 参考使用 lgn.sh id password eth1 4
# lgn认证用 参考使用 lgn.sh id password eth1 46
cd $(cd "$(dirname "$0")"; pwd)

fake_header="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"
url46="http://lgn6.bjut.edu.cn/V6?https://lgn.bjut.edu.cn"
url4="http://172.30.201.10" # http://lgn.bjut.edu.cn
url6="http://[2001:da8:216:30c9::a]" # https://lgn6.bjut.edu.cn
v46="4" # 参数 获取默认值 4： ipv4 6： ipv6
all_if=` ifconfig | grep ^[a-z0-9] | awk -F: '{print $1}' `' '
DDDDD=""  #id
upass=""  #pw
v46s='1'  #ipv4 或 ipv6 默认 1 ： ipv4 2： ipv6
v6ip=''
f4serip="172.30.201.2"
A0MKKey=''
interface=''
# 前两个参数 为 id pw
if [ $# -ge 2 ]
then
    DDDDD=$1
    upass=$2
fi
#判断剩余参数 还有2个参数 一为判断ipv4 ipv6 使用4或6传入；一为网卡名。无顺序
if [ $# -ge 3 ]
then
    para0=$3
    case $para0 in
        "") pass=1 ;;
        "4") v46=4 ;;
        "6") v46=6 ;;
        "46") v46=46 ;;
        *) result=` echo $all_if | grep "$para0 " `
        if [ "$result" != "" ]
        then 
        interface=$para0
        fi
        ;;
    esac
    para0=$4
    case $para0 in
        "") pass=1 ;;
        "4") v46=4 ;;
        "6") v46=6 ;;
        "46") v46=46 ;;
        *) result=` echo $all_if | grep "$para0 " `
        if [ "$result" != "" ]
        then 
        interface=$para0
        fi
        ;;
    esac   
fi
errorfile="$DDDDD$v46$interface""lgn.log"
url=` eval echo '$'url${v46} `
if [ "$v46" == "4" ]
then
    v46s='1'
elif [ "$v46" == "6" ]
then
    v46s='2'
elif [ "$v46" == "46" ]
then
    v46s='0'
fi
para="--data-urlencode DDDDD=$DDDDD --data-urlencode upass=${upass//'\r'/} --data-urlencode v46s=$v46s --data-urlencode v6ip=$v6ip --data-urlencode f4serip=$f4serip --data-urlencode 0MKKey=$A0MKKey"
if [ "$interface" == '' ]
then
    body=`curl -o $errorfile -s -m 5 -A  "$fake_header" $para "$url" -g ` 
else
    body=`curl -o $errorfile -s -m 5 -A  "$fake_header" $para  --interface "$interface" "$url" -g ` 
fi
if [ "$v46" == "46" ]
then
    url=$url4
    v6ip=` cat $errorfile | grep -o -E "name='v6ip' value='[1234567890a-z:]+'" `
    v6ip=` echo $v6ip | grep -o -E "value='[1234567890a-z:]+'" `
    v6ip=` echo $v6ip | grep -o -E "'[1234567890a-z:]+'" `
    v6ip=` echo $v6ip | grep -o -E "[1234567890a-z:]+" `
    A0MKKey="Login"
    para="--data-urlencode DDDDD=$DDDDD --data-urlencode upass=${upass//'\r'/} --data-urlencode 0MKKey=$A0MKKey --data-urlencode v6ip=$v6ip"
    if [ "$interface" == '' ]
    then
        body=`curl -o $errorfile -s -m 5 -A  "$fake_header" $para "$url" -g ` 
    else
        body=`curl -o $errorfile -s -m 5 -A  "$fake_header" $para  --interface "$interface" "$url" -g ` 
    fi
fi
Gno=` cat $errorfile | grep -o -E "Gno=[1234567890]+" `

Gno=` echo ${Gno:4:2} `
flag=` cat $errorfile | grep -o -E "<!--Dr.COMWebLoginID_3.htm-->" `
if [ "$flag" == "<!--Dr.COMWebLoginID_3.htm-->" ]
then
    rm $errorfile
    echo 1
else
    echo 0
fi


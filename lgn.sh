#!/bin/ash
cd $(cd "$(dirname "$0")"; pwd)
errorfile="lgn.log"
fake_header="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"
url4="http://172.30.201.10" # http://lgn.bjut.edu.cn
url6="http://[2001:da8:216:30c9::2]" # https://lgn6.bjut.edu.cn
v46="4" # 参数 获取默认值 4： ipv4 6： ipv6
all_if=` ifconfig | grep ^[a-z0-9] | awk -F: '{print $1}' `' '
DDDDD=""  #id
upass=""  #pw
v46s='1'  #ipv4 或 ipv6 默认 1 ： ipv4 2： ipv6
v6ip=''
f4serip="172.30.201.10"
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
        *) result=` echo $all_if | grep "$para0 " `
        if [ "$result" != "" ]
        then 
        interface=$para0
        fi
        ;;
    esac   
fi
url=` eval echo '$'url${v46} `
if [ "$v46" == "4" ]
then
    v46s='1'
else
    v46s='2'
fi
para="--data-urlencode DDDDD=$DDDDD --data-urlencode upass=${upass//'\r'/} --data-urlencode v46s=$v46s --data-urlencode v6ip=$v6ip --data-urlencode f4serip=$f4serip --data-urlencode 0MKKey=$A0MKKey"
if [ "$interface" == '' ]
then
    body=`curl -o $errorfile -s -m 5 -A  "$fake_header" $para "$url" -g ` 
else
    body=`curl -o $errorfile -s -m 5 -A  "$fake_header" $para  --interface "$interface" "$url" -g ` 
fi
Gno=` cat $errorfile | grep -o -E "Gno=[1234567890]+" `

Gno=` echo ${Gno:4:2} `
if [ "$Gno" == '01' ]
then
    rm $errorfile
    echo 1
else
    echo 0
fi


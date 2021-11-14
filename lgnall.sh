#!/bin/ash
cd $(cd "$(dirname "$0")"; pwd)
# 自动识别网络所处类型 lgn.bjut.edu.cn bjut_wifi 寝室光猫 ，然后选择shell间隔时间循环登录
# 请填入以下信息
id=""
pw=""
interface="" # 网卡参数 curl指定网卡用 不指定 也可用
v46="4"  # lgn网 4：ipv4 6：ipv6 参数 其他网则忽略
ser="0" # 宽带网用参数 0 校内网 campus 1 移动 cmcc 2 联通 unicom 3 电信 telecom 其他网则忽略
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
url1="10.21.250.3"
url2="10.21.221.98"
url3="172.30.201.10"
fake_header="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"
back_url=''
set=` set ` 
for var in $set
do
    var_url=` echo $var | grep -o -E "url[0-9]+" `
    if [ "$var_url" == "" ]
    then
        a=a
    else
        url=$(eval echo \$$var_url)
        if [ "$url" == '' ]
        then
             a=a
        else
            if [ "$interface" == "" ]
            then
                body=` curl -s -m 2 -A  "$fake_header" "http://""$url" `
            else
                body=` curl -s -m 2 -A  "$fake_header" "http://""$url" --interface $interface `
            fi
            if [ "$body" == "" ]
            then
                a=a
            else
                back_url=$url
                break
            fi
        fi
    fi
done

case $back_url in
    $url1) netlocation="WiFI"
    ;;
    $url2 | $url3)  if [ "$interface" == "" ]
            then
                ip=` curl -s -m 1 $url2"/drcom/chkstatus?callback=dr&v=101" | grep -o -E "\"v46ip\"\:\"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\"" | grep -o -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" `
            else
                ip=` curl -s -m 1 $url2"/drcom/chkstatus?callback=dr&v=101" --interface $interface | grep -o -E "\"v46ip\"\:\"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\"" | grep -o -E "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" `
            fi
    if [ ${ip%%.*} == "172" ]  # [[ "$ip" == "172"* ]] #tongper
    then 
        back_url=$url3
    elif [ ${ip%%.*} == "10"  ] 
    then 
    back_url=$url2 
    fi
    ;;
    *) echo "Not compus network"
    ;;
esac
echo "http://"$back_url
while [ -n "$back_url" ] # 定时登录持在线
do
    case $back_url in 
        $url1) res=` ./wifi_login.sh $id $pw $interface `
        ;;
        $url3)  res=` ./lgn.sh $id $pw $v46 $interface `
        ;;
        $url2) res=` ./Broadband_login.sh $id $pw $ser $interface `
        ;;
        *) res=0
        ;;
    esac
    sleep 1800s    # 间隔时间
done



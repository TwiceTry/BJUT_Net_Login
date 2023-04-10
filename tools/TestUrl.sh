#!/bin/sh
# 简介 在一定时间内 head请求url 访问的返回1否则0
# 参数 url(可选)   seconds(可选)  interface(可选)
# 参数解释 测试地址 超时时间 ([1-9]秒)    网卡名
# 默认值    百度    1              系统默认
# 依赖 curl
# 依赖 AllIf.sh 相对本脚本位置 ./AllIf.sh

###  参考使用样例
# TestUrl.sh "http://www.baidu.com" 5 eth0
# TestUrl.sh "http://www.baidu.com" 5
# TestUrl.sh "http://www.baidu.com" eth0
# TestUrl.sh "http://www.baidu.com"
# TestUrl.sh eth0
# TestUrl.sh 5
# TestUrl.sh
###  参考使用样例
cd $(
    cd "$(dirname "$0")"
    pwd
)
# 设置参数默认值
testUrl="www.baidu.com"
seconds=1
interface=""

### 脚本参数判定获取
for args in $*; do
    case "$args" in
    $(./AllIf.sh $args))
        interface="$args"
        ;;
    [1-9]) seconds="$args" ;;
    *)
        testUrl="$args"
        ;;
    esac
done

# 模拟UserAgent
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"

if [ "$interface" = "" ]; then
    body=$(curl "$testUrl" -s -I -m "$seconds" -A "$UA" -g)
else
    body=$(curl "$testUrl" -s -I -m "$seconds" -A "$UA" --interface "$interface" -g)
fi

if [[ "$body" = "" || "$body" = *"Location: "* ]]; then
    echo "0"
else
    echo "1"
fi
exit 0

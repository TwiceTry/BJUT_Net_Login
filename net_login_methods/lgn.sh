#!/bin/sh
# 参数 id     pw    4/6/46(可选)                    interface(可选)
# 参数解释 用户名 密码 ipv4/ipv6/ipv4+ipv6用 4或6或46 默认4    网卡名
# 依赖 curl
# 依赖 AllIf.sh 相对本脚本位置 ../tools/AllIf.sh
# 依赖 TestUrl.sh 相对本脚本位置 ../tools/TestUrl.sh

### lgn.bjut.edu.cn上网认证 参考使用样例
# lgn.sh id password
# lgn.sh id password 4
# lgn.sh id password 46
# lgn.sh id password 4 eth1
# lgn.sh id password eth1
### lgn.bjut.edu.cn上网认证 参考使用样例

cd $(
    cd "$(dirname "$0")"
    pwd
)

### 也可在此处填写 无参数运行
# 账号
id=""
# 密码
pw=""
# ipv4/ipv6/ipv4+ipv6 4或6或46 默认4
ipv46="4"
# 网络接口
if=""
# 执行命令
execName="login"
extraExecName="connected ip status logout"
# 1已登录则登出后登录 0已登录则不进行操作
force="1"
###

### 脚本参数判定获取
if [ -z "$1" ]; then
    execName="login"
elif [ -n "$(echo $extraExecName | grep -w $1)" ]; then
    execName="$1"
    tmp=$2
    case $tmp in
    [46] | 46) ipv46=$tmp && if=$(../tools/AllIf.sh "$3") ;;
    *) if=$(../tools/AllIf.sh "$2") ;;
    esac
elif [ $# -ge 2 ]; then
    id=$1
    pw=$2
    tmp=$3
    case $tmp in
    [46] | 46) ipv46=$tmp && if=$(../tools/AllIf.sh "$4") ;;
    *) if=$(../tools/AllIf.sh "$3") ;;
    esac
fi

###

#
url46="http://lgn6.bjut.edu.cn/V6?https://lgn.bjut.edu.cn"
url4="http://172.30.201.2"           # 或 http://172.30.201.10 域名 http://lgn.bjut.edu.cn
url6="http://[2001:da8:216:30c9::2]" # 或http://[2001:da8:216:30c9::a] 域名 https://lgn6.bjut.edu.cn

logoutUrl4="http://172.30.201.2/F.htm"
logoutUrl6="http://[2001:da8:216:30c9::2]/F.htm"
#
# $1 url $2 参数字符串 ; $3 结果保存文件
postSub() {
    url="$1"
    para="$2"
    errorFile="$3"
    touch $errorFile
    ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"
    if [ -z $if ]; then
        body=$(curl -o $errorFile -s -m 5 -A "$ua" $para "$url" -g)
    else
        body=$(curl -o $errorFile -s -m 5 -A "$ua" $para --interface "$if" "$url" -g)
    fi
    echo $(cat $errorFile)
}

# $1 4/6 (ipv4/ipv6)
getStatusHtml() {
    # 按 ipv4/ipv6 设置url
    case "$1" in
    [46] | 46) ipv46="$1" ;;
    *) ipv46="4" ;;
    esac
    url=$(eval echo '$'url$ipv46)
    errorFile="$interface""status"$ipv46".html"
    para="-X GET"
    # 传para参为get方法
    html=$(postSub "$url" "$para" "$errorFile")

    echo $html
}

# $1 4/6 (ipv4/ipv6)
getIp() {

    html=$(getStatusHtml "$1")
    flag=$(echo $html | grep -o -E "<!--Dr.COMWebLoginID_1.htm-->")
    if [ "$flag" = "<!--Dr.COMWebLoginID_1.htm-->" ]; then
        valName="v"$1"ip"
    else
        valName="v46ip"
    fi
    # 返回的html <script>中v4ip/v6ip
    if [ "$1" = "4" ]; then
        # 正则查询ipv4
        flag=$(echo $html | egrep -m 1 -o $valName"='[0-9]{1,3}(\.[0-9]{1,3}){3}'" | head -1 | awk -F "'" '{print $2}')
    elif [ "$1" = "6" ]; then
        # 正则查询ipv6
        flag=$(echo $html | egrep -o $valName"='[0-9a-fA-F]{0,4}(\:[0-9a-fA-F]{0,4})*'" | head -1 | awk -F "'" '{print $2}')
    fi
    echo $flag
}

# $1 4/6 (ipv4/ipv6)
getStatus() {

    html=$(getStatusHtml "$1")

    # 返回的html中的注释标签判断是否已登录
    flag=$(echo $html | grep -o -E "<!--Dr.COMWebLoginID_1.htm-->")
    if [ "$flag" = "<!--Dr.COMWebLoginID_1.htm-->" ]; then
        #rm $errorFile
        echo 1
    else
        echo 0
    fi
}

# $1 id ; $2 pw ; $3 ipv46
postLogin() {
    # 按post 参数设置变量
    DDDDD="$1"
    upass="$2"
    case "$3" in
    4) v46s="1" ;;
    6) v46s="2" ;;
    46) v46s="0" ;;
    *) v46s="1" ;;
    esac
    v6ip=""
    f4serip="172.30.201.2"
    A0MKKey=""

    # 按 ipv4/ipv6 设置url
    url=$(eval echo '$'url$3)

    # 请求错误地返回结果保存地址
    errorFile="$interface""login"$3".html"

    # 设置post参数字符串 urlencode
    para="--data-urlencode DDDDD=$DDDDD --data-urlencode upass=$upass --data-urlencode v46s=$v46s --data-urlencode v6ip=$v6ip --data-urlencode f4serip=$f4serip --data-urlencode 0MKKey=$A0MKKey"

    # post 请求
    html=$(postSub "$url" "$para" "$errorFile")

    # ipv4与ipv6一同认证 多一步
    if [ "$v46s" = "0" ]; then
        url=$url4
        # 正则查询ipv6 下一步作参数
        v6ip=$(echo $html | grep -o -E "value='[0-9a-fA-F]{0,4}(\:[0-9a-fA-F]{0,4})*'" | head -1 | awk -F "'" '{print $2}')
        A0MKKey="Login"
        para="--data-urlencode DDDDD=$DDDDD --data-urlencode upass=$upass --data-urlencode 0MKKey=$A0MKKey --data-urlencode v6ip=$v6ip"
        # post 请求
        html=$(postSub "$url" "$para" "$errorFile")
    fi

    # 最后判断是否成功 此登录无需登出可覆盖登录
    # 返回的html中script标签中变量 Gno 判断是否成功
    # Gno=$(cat $errorFile | grep -o -E "Gno=[1234567890]+" )
    # Gno=$(echo ${Gno:4:2})

    # 返回的html中的注释标签判断是否成功
    flag=$(echo $html | grep -o -E "<!--Dr.COMWebLoginID_3.htm-->")
    if [ -n $flag ]; then
        #rm $errorFile
        echo 1
    else
        echo 0
    fi
}

# $1 ipv46 登出 操作为访问登出页面即可
getLogout() {
    # 按 ipv4/ipv6 设置url
    case "$1" in
    [46] | 46) ipv46="$1" ;;
    *) ipv46="4" ;;
    esac
    url=$(eval echo '$'logoutUrl$ipv46)
    errorFile="$interface""logout"$ipv46".html"
    para="-X GET"
    # 传para参为get方法
    html=$(postSub "$url" "$para" "$errorFile")

    # 返回的html中的注释标签判断是否成功
    flag=$(echo $html | grep -o -E "<!--Dr.COMWebLoginID_2.htm-->")
    if [ "$flag" = "<!--Dr.COMWebLoginID_2.htm-->" ]; then
        #rm $errorFile
        echo 1
    else
        echo 0
    fi
}

# 测试链接是否连通
if [ "$execName" = "connected" ]; then
    url=$(eval echo '$'url$ipv46)
    echo $(../tools/TestUrl.sh "$url")
    exit 0
elif [ "$execName" = "ip" ]; then
    echo $(getIp "$ipv46")
    exit 0
fi
# 获取当前网络状态
if [ "$execName" = "status" ]; then
    echo $(getStatus "$ipv46")
    exit 0
elif [ "$force" != "1" ]; then
    if [[ "$(getStatus "$ipv46")" = "1" && "$execName" = "login" || "$(getStatus "$ipv46")" = "0" && "$execName" = "logout"]]; then
        # 进行操作前已处于将要操作后的状态 也无强制 则不进行操作
        # 已经符合要求了（已登录或已登出）
        echo 1
        # 结束脚本退出
        exit 0
    fi
fi
#

# 登出
if [ "$execName" = "logout" ]; then
    res=$(getLogout "$ipv46")
    echo $res
# 登录
elif [ "$execName" = "login" ]; then
    if [[ -z "$id" || -z "$pw" ]]; then
        echo error:id,pw为空
        exit 0
    fi
    res=$(postLogin "$id" "$pw" "$ipv46")
    echo $res
fi

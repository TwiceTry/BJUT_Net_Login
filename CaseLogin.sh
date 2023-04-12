#!/bin/sh
# 参数 id     pw         interface(可选)
# 参数解释 用户名 密码    网卡名
# 依赖 curl
# 依赖 AllIf.sh 相对本脚本位置 ../tools/AllIf.sh
# 依赖 lgn.sh 相对本脚本位置 ./net_login_methods/lgn.sh
# 依赖 Wlgn.sh 相对本脚本位置 ./net_login_methods/Wlgn.sh
# 依赖 Blgn.sh 相对本脚本位置 ./net_login_methods/Blgn.sh
# 依赖 JSON.sh(来源于https://github.com/dominictarr/JSON.sh 相对本脚本位置 ./tools/JSON.sh ) egrep

### 参考使用样例
# CaseLogin.sh id pw
# CaseLogin.sh id pw 1 interface
# CaseLogin.sh id pw 1
# CaseLogin.sh id pw interface
### 参考使用样例
cd $(
    cd "$(dirname "$0")"
    pwd
)
pwd=$(pwd)

### 也可在此处填写 无参数运行
# 是否覆盖已记录网络类型
recover=0
# 账号
id=""
# 密码
pw=""
# 网络接口
if=""
# 执行命令
execName="login"
extraExecName="server"
###

### 脚本参数判定获取
if [ -z "$1" ]; then
    execName="login"
elif [ -n "$(echo $extraExecName | grep -w $1)" ]; then
    execName="$1"
    tmp=$2
    if=$(./tools/AllIf.sh "$2")
elif [ $# -ge 2 ]; then
    id=$1
    pw=$2
    tmp=$3
    case $tmp in
    [01])
        recover=$tmp
        if=$(./tools/AllIf.sh "$4")
        ;;
    *) if=$(./tools/AllIf.sh "$tmp") ;;
    esac
fi
###

#记录网络环境
loginScriptFile="loginScript.txt"

touch $loginScriptFile
# $1 json $2 key 获取json中key的值 依赖../tools/JSON.sh
getValByKeyFromJson() {
    json="$1"
    key="$2"
    # 解析json 获取json key的值
    val=$(echo "$json" | ./tools/JSON.sh | egrep '\["'$key'"\]' | awk -F' ' '{print $2}')

    echo $val
}

# 判断网络环境 2022 网络环境复杂，依赖判定的先后顺序
getServer() {
    # 先试试是否在bjut_wifi
    wlgnIsConnected=$(./net_login_methods/Wlgn.sh isConnected "$if")
    if [ "$wlgnIsConnected" = "1" ]; then
        echo "Wlgn.sh"
    else
        # 再试试10.21.221.98能不能连通（在bjut_wifi连不通）
        blgnIsConnected=$(./net_login_methods/Blgn.sh isConnected "$if")
        if [ "$blgnIsConnected" = "1" ]; then
            # 获取网络状态
            status=$(./net_login_methods/Blgn.sh status "$if")
            # 根据状态json解析出当前校园网ipv4地址
            json=$(cat "./net_login_methods/"$if"status.json")
            myv4Ip=$(getValByKeyFromJson "$json" "ss5")
            # 不是很优雅地去除字符串""包裹
            myv4Ip=$(eval " echo $myv4Ip ")
            # 根据ip地址判断所在网络环境
            first=${myv4Ip%%.*}
            if [ $first = "172" ]; then
                echo "lgn.sh"
            elif [ $first = "10" ]; then
                echo "Blgn.sh"
            else
                echo ""
            fi
        fi
    fi
}

loginScript=$(cat $loginScriptFile)
# 如果记录文件loginScript为空或recover为1或是server命令则获取网络环境并记录进loginScript
if [[ "$recover" = "1" || -z "$loginScript" || "$execName" = "server" ]]; then
    loginScript=$(getServer)
    echo $loginScript >$loginScriptFile
    if [ "$execName" = "server" ]; then exit 0; fi
fi

# 根据网络环境记录文件loginScript进行登录操作
case $loginScript in
Wlgn.sh)
    # 登录bjut_wifi
    result=$(./net_login_methods/Wlgn.sh "$id" "$pw" "$if")
    # 判断ipv6是否可用，是则再登录ipv6
    if [["$result" = "1" && "$(./net_login_methods/lgn.sh isConnected 6 "$if")" = "1" ]]; then
        result=$(./net_login_methods/lgn.sh "$id" "$pw" 6 "$if")
    fi
    ;;
Blgn.sh)
    # 登录光猫网络认证
    result=$(./net_login_methods/Blgn.sh "$id" "$pw" "$if")
    
    if [ "$result" = "1" ]; then
        # 判断ipv6是否可用
        ipv6=$(./net_login_methods/lgn.sh isConnected 6 "$if")
        # 此方式还需再次登录lgn.bjut.edu.cn，根据ipv6是否可用进行ipv4或一起登录操作
        if [ "$ipv6" = "1" ]; then
            result=$(./net_login_methods/lgn.sh "$id" "$pw" 46 "$if")
        else
            result=$(./net_login_methods/lgn.sh "$id" "$pw" 4 "$if")
        fi
    fi
    ;;
lgn.sh)
    ipv6=$(./net_login_methods/lgn.sh isConnected 6 "$if")
    # 根据ipv6是否可用进行ipv4或一起登录操作
    if [ "$ipv6" = "1" ]; then
        result=$(./net_login_methods/lgn.sh "$id" "$pw" 46 "$if")
    else
        result=$(./net_login_methods/lgn.sh "$id" "$pw" 4 "$if")
    fi
    ;;
*)
    result="网络错误"
    ;;
esac
echo $result
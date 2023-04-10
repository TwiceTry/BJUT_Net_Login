#!/bin/sh
# 参数  id   pw    interface
# 参数解释 用户名  密码   网卡名（可选）
# 依赖 curl
# 依赖 AllIf.sh 相对脚本位置 ../tools/AllIf.sh
# 依赖 TestUrl.sh 相对本脚本位置 ../tools/TestUrl.sh
# 依赖 JSON.sh(来源于https://github.com/dominictarr/JSON.sh 相对本脚本位置 ../tools/JSON.sh) egrep


### bjut_wifi上网认证 参考使用样例
# Wlgn.sh id pw
# Wlgn.sh id pw interface
### bjut_wifi上网认证 参考使用样例

cd $(
    cd "$(dirname "$0")"
    pwd
)

### 也可在此处填写 无参数运行
# 账号
id=""
# 密码
pw=""
# 网络接口
if=""
# 执行命令
execName="login"
extraExecName="isConnected status logout"

# 1已登录则登出后登录 0已登录则不进行操作
force="1"
### 也可在此处填写 无参数运行

### 脚本参数判定获取
if [ -z "$1" ]; then
    execName="login"
elif [ -n "$(echo $extraExecName | grep -w $1)" ]; then
    execName="$1"
    if=$(../tools/AllIf.sh "$2")
elif [ $# -ge 2 ]; then
    id=$1
    pw=$2
    if=$(../tools/AllIf.sh "$3")
fi

### 脚本参数判定获取

# json文件 以参数网络接口名前缀 避免在多网卡使用条件下文件名重复
jsonFileNamePrefix="${if}"

# 认证地址 2022.2.16 IP地址 10.21.250.3 -> 10.21.251.3 域名可用 wlgn.bjut.edu.cn
serHost=10.21.251.3

# $1 url $2 输出文件 $3 网络接口名（可选） 获取url的返回jsonp,json文本输出到$2
getJson() {
    url="$1"
    output="$2"
    interface="$3"

    # 请求伪造浏览器标标识
    ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"

    # # wget 获取方法（不支持指定网卡弃用）
    # wget -q -U "$ua" $url

    # curl请求操作
    if [ -z $interface ]; then
        jsonp=$(curl -A "$ua" -s $url)
    else
        jsonp=$(curl -A "$ua" -s --interface $interface $url)
    fi

    # 去除jsonp函數包裹
    json=$(echo ${jsonp#*(})
    json=$(echo ${json%*)})
    echo $json >$output

    echo $json
}

# 获取网络状态
getStatus() {
    # 获取状态url
    statusUrl="http://"$serHost"/drcom/chkstatus?callback=dr"$(date +%s)"123"

    # 状态保存文件名（或完整路径）
    statusFile=${jsonFileNamePrefix}"status.json"

    # 获取状态json
    json=$(getJson "$statusUrl" "$statusFile" $if)

    # 获取result
    result=$(getValByKeyFromJson "$json" "result")

    echo $result
}

# 登录过程 $1 默认0，1则返回之前的json，没有json则立即获取
getLogin() {
    reJson="$1"

    # 最小参数登录url设置  但可上网
    loginUrl="http://"$serHost"/drcom/login?callback=dr1002&DDDDD="$id"&upass="$pw"&0MKKey=123456&R1=0&R2=&R3=0&R6=0&para=00&v6ip=&terminal_type=1&lang=zh%2Dcn&jsVersion=4.1&v=1234&lang=zh"

    # 登录结果json
    resultFile=${jsonFileNamePrefix}"login.json"

    if [ "$reJson" = "1" ]; then
        if [ ! -e $resultFile ]; then
            # 登录并获取登录结果json
            json=$(getJson "$loginUrl" "$resultFile" $if)
        fi
        echo $(cat $resultFile)
    else
        # 登录并获取登录结果json
        json=$(getJson "$loginUrl" "$resultFile" $if)

        # 获取result
        result=$(getValByKeyFromJson "$json" "result")

        echo $result
    fi

}

# 登出方法
getLogout() {
    # 登出地址
    logoutUrl="http://"$serHost"/drcom/logout?callback=dr1002&jsVersion=4.1&v=1234$lang=zh"

    # 登出结果json
    resultFile=${jsonFileNamePrefix}"logout.json"

    # 登出并获取登出结果json
    json=$(getJson "$logoutUrl" "$resultFile" $if)

    # 获取result
    result=$(getValByKeyFromJson "$json" "result")

    echo $result
}
# 测试服务主机是否连通
if [ "$execName" = "isConnected" ]; then
    echo $(../tools/TestUrl.sh "$serHost")
    exit 0
# 获取当前网络状态
elif [ "$execName" = "status" ]; then
    echo $(getStatus)
    exit 0
fi
# 获取当前网络状态
status=$(getStatus)
# 登出
if [ "$execName" = "logout" ]; then
    if [ "$status" = "1" ]; then
        echo $(getLogout)
    else
        echo $status
    fi
    exit 0
    # 登录
elif [ "$execName" = "login" ]; then
    if [[ -z "$id" || -z "$pw" ]]; then
        echo error:id,pw为空
        exit 0
    fi
    # 进行登录前已登录状态先登出
    if [[ "$force" = "1" && "$status" = "1" ]]; then
        $(getLogout)
    elif [[ "$force" != "1" && "$status" = "1" ]]; then
        echo $status
        exit 0
    fi
    # 登录操作
    if [ $(getLogin) -eq 1 ]; then
        # 登录成功
        echo 1
    fi
fi

exit 0

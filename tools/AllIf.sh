#!/bin/sh
# 参数 $1 网卡名 判断是否在网卡列表里 是 返回网卡名 否返回空字符串
# 无参数返回所有网卡名
# 依赖 ifconfig

cd $(
    cd "$(dirname "$0")"
    pwd
)

# $1 传入网卡名 判断是否在网卡列表里 是 返回网卡名 否返回空字符串
ifInAllIf() {
    ifName="$1"
    allIfName=$(ifconfig | grep ^[a-z0-9] | awk -F: '{print $1}')

    if [ "$ifName" = "all" ]; then
        echo $allIfName
    else
        result=$(echo $allIfName | grep "$ifName ")
        if [ "$result" != "" ]; then
            if=$ifName
            echo $if
        else
            echo ""
        fi
    fi
}

echo $(ifInAllIf "$1")

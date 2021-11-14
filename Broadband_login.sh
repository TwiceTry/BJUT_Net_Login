#!/bin/ash
# 参数     id     pw    ser            interface
# 参数解释 用户名  密码  服务提供（数字） 网卡名（可选）
# 首先 chmod +x 此脚本完整路径
#赋予执行权
# 带参数运行 此文件名.sh 账号 密码 运营商（0 校内网 campus 1 移动 cmcc 2 联通 unicom 3 电信 telecom） 
# 也可在此处填写账号 密码 其他处勿动  无参数运行
id=""
pw=""
ser="0" #2
# ser 0 校内网 campus 1 移动 cmcc 2 联通 unicom 3 电信 telecom
if=""
#
#建议 添加进 crontab 定时任务
# 例：*/5 * * * * 此脚本路径
# 为每整五分钟执行一次
# 看不懂不要动下面的
cd $(cd "$(dirname "$0")"; pwd)
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
    tmp=$3
    if [ ${#tmp} == 1 ]
    then
        if [ ` expr index $tmp "123" ` ]
        then
            ser=$3
        fi
    fi
    if=$4
fi
jsonfname="${id}${if}"
#字符串配置 %40 为@url编码
case $ser in
    0)  id=$id'%40campus'
    ;;
    1)  id=$id'%40cmcc'
    ;;
    2)  id=$id'%40unicom'
    ;;
    3)  id=$id'%40telecom'
    ;;
esac
# 认证地址
serip=10.21.221.98
# 请求浏览器标
ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"
# 获取状态
url0="http://"$serip"/drcom/chkstatus"        
ts=`date +%s`
ts=$ts'123'               
url0=$url0"?callback=dr"$ts"&v="
url0=$url0'1234'
# wget -q -O status.json -U "$ua" $url0
sleep 3s
if [ -z $if ]
then
    curl -o ${jsonfname}status.json -A  "$ua" -s $url0
else
    curl -o ${jsonfname}status.json -A  "$ua" -s --interface $if $url0
fi
index=`grep -o -E "\"result\":[01]" ${jsonfname}status.json` 
bool=${index:9:1} # bash
if [ $bool -eq 1 ]
then
    echo "1"  # 已经登录了
    rm ${jsonfname}status.json  # 状态输出日志
    exit 0
fi

# 最小参数设置  但可上网

url="http://"$serip":801/eportal/?c=Portal&a=login&user_account="$id"&user_password="$pw"&login_method=1"


# 请求动作 
# wget -q -O result.json -U "$ua" $url
if [ -z $if ]
then
    curl -o ${jsonfname}result.json -A  "$ua" -s $url
else
    curl -o ${jsonfname}result.json -A  "$ua" -s --interface $if $url
fi
index=`grep  -o -E "\"result\":\"[01]\"" ${jsonfname}result.json`
bool=${index:10:1} # bash
if [ $bool -eq 1 ]
then
    echo "1"  # 登录成功
    rm ${jsonfname}result.json
else
    ret=`grep  -o -E "\"ret_code\":\"[012]{1,2}\"" ${jsonfname}result.json`
    if [ $ret == '2' ]
    then
        url2="http://"$serip":801/eportal/?c=Portal&a=logout"
        if [ -z $if ]
        then
            curl -o ${jsonfname}logout.json -A  "$ua" -s $url2
        else
            curl -o ${jsonfname}logout.json -A  "$ua" -s --interface $if $url2
        fi
        index=`grep -o -E "\"result\":[01]" ${jsonfname}logout.json` 
        bool=${index:9:1} # bash
        if [ $bool -eq 1 ]
        then
            # 请求动作 
            # wget -q -O result.json -U "$ua" $url
            if [ -z $if ]
            then
                curl -o ${jsonfname}result.json -A  "$ua" -s $url
            else
                curl -o ${jsonfname}result.json -A  "$ua" -s --interface $if $url
            fi
            index=`grep  -o -E "\"result\":\"[01]\"" ${jsonfname}result.json`
            bool1=${index:10:1} # bash
            if [ $bool1 -eq 1 ]
            then
                echo "1"  # 登录成功
                rm ${jsonfname}result.json # 登录结果输出日志
            else
                echo '0'
            fi
        fi
    fi
    echo "0"    # 登录失败
fi


exit 0

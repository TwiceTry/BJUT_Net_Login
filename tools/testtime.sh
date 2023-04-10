start_time=$(date +%s)
cd $(
    cd "$(dirname "$0")"
    pwd
)
if [ -z $1 ]; then
    filepath=$1
fi

execres=$($*)
end_time=$(date +%s)
cost_time=$(expr $end_time - $start_time)
echo "run ""$*"" with result: ""$execres"
echo "Time the program spent is "$cost_time" s"
exit 0

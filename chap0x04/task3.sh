#!/usr/bin/env bash

function help {
    echo "-t        统计访问来源主机TOP 100和分别对应出现的总次数"
    echo "-i        统计访问来源主机TOP 100 IP和分别对应出现的总次数"
    echo "-u        统计最频繁被访问的URL TOP 100"
    echo "-s        统计不同响应状态码的出现次数和对应百分比"
    echo "-c        分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
    echo "-f url    给定URL,输出对应TOP 100访问来源主机"
    echo "-h        帮助文档"

}


function CheckFile {
    if [[ ! -f "web_log.tsv.7z" ]];then
        wget https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z
        7z x web_log.tsv.7z
    elif [[ ! -f "web_log.tsv" ]];then
        7z x web_log.tsv.7z
    fi
}

# - 统计访问来源主机TOP 100和分别对应出现的总次数

function CountHost {
    printf "******************\n"
    printf "|出现次数|主机名称|\n"
    printf "******************\n"
    awk -F '\t' '
    NR>1{
        hosts[$1]++;
    }
    END{
        for(host in hosts){
            printf("%d\t%s\t\n",hosts[host],host)
        }
    }' web_log.tsv | sort -k1 -rg | head -100
    exit 0
}

# - 统计访问来源主机TOP 100 IP和分别对应出现的总次数
function CountIP {
    printf "******************\n"
    printf "|主机IP名称|出现次数|\n"
    printf "******************\n"
    awk -F '\t' '
    NR>1{
        if(match($1,/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/)){
            hosts[$1]++;
        }
    }
    END{
        for(host in hosts){
            printf("%s\t\t%d\t\n",host,hosts[host])
        }
    }' web_log.tsv | sort -k1 -rg | head -100
    exit 0
}


# - 统计最频繁被访问的URL TOP 100
function MostFrequent {
    printf "******************\n"
    printf "|出现次数||URL名称|\n"
    printf "******************\n"
    awk -F '\t' '
    NR>1{
        urls[$5]++;
    }
    END{
        for(url in urls){
            printf("%d\t%s\t\t\n",urls[url],url)
        }
    }
    ' web_log.tsv | sort -k1 -rg | head -100
    exit 0
}


# - 统计不同响应状态码的出现次数和对应百分比
function CountState {
    printf "***********************************\n"
    printf "|响应状态码名称|出现次数|对应百分比|\n"
    printf "***********************************\n"
    awk -F '\t' 'BEGIN { total=0;}
    NR>1{
        response[$6]++;
        total++;
    }
    END{
        for(rep in response){
            printf("%s\t%d\t%.2f%\t\n",rep,response[rep],response[rep]/total*100)
        }
    }
    ' web_log.tsv
    exit 0
}

# - 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
function Count4XX {
    printf "**********************************\n"
    printf "|4XX状态码名称|出现的次数|对应的URL|\n"
    printf "**********************************\n"
    awk -F '\t' '
    NR>1{
        if(match($6,/^4[0-9]{2}$/)){
            response[$6][$5]++;
        }
    }
    END{
        for(resp in response){
            for(url in response[resp]){
                    print resp,response[resp][url],url;
            }
        }
    }' web_log.tsv | sort -k1,1 -k2,2gr | head -10
    exit 0
}


# - 给定URL输出TOP 100访问来源主机
function FindHost {
    printf "**********************\n"
    printf "|出现次数|对应主机名称|\n"
    printf "**********************\n"
    awk -F '\t' -v url="$1" '
    NR>1{
        if($5==url){
            hosts[$5][$1]++
        }
    }
    END{
        for(ul in hosts){
            for(host in hosts[ul]){
                    printf("%d\t%s\t\n",hosts[ul][host],host)
            }
        }
    }
    ' web_log.tsv | sort -k1 -rg | head -100
    exit 0
}

[[ $# -eq 0 ]] && help

while getopts 'tiuscf:h' OPT; do
    case $OPT in
        t)  
            CountHost
            ;;
        i)
            CountIP
            ;;
        u)
            MostFrequent
            ;;
        s)
            CountState
            ;;
        c)
            Count4XX
            ;;
        f)
            FindHost "$2"
            ;;
        h | *) 
            help
            ;;
    esac
done 

CheckFile
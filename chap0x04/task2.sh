#!/usr/bin/env bash

function help {
    echo "-a       统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员**数量**、**百分比**"
    echo "-p       统计不同场上位置的球员**数量**、**百分比**"
    echo "-n       查找名字最长的球员是谁？名字最短的球员是谁？"
    echo "-m       年龄最大的球员是谁？年龄最小的球员是谁？"
    echo "-h       帮助手册"
}

# - - 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员**数量**、**百分比**
#   - 统计不同场上位置的球员**数量**、**百分比**
#   - 名字最长的球员是谁？名字最短的球员是谁？（字节、字符统计）
#   - 年龄最大的球员是谁？年龄最小的球员是谁？（最可能有多个）
# - 

# - - 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员**数量**、**百分比**
function Age {
    awk -F '\t' 'BEGIN {small=0; middle=0; high=0}
    NR>1{
        if($6 < 20) {small++;}
        else if($6 >= 20 && $6 <= 30) {middle++;}
        else {high++;}
    } 
    END{
        total=small+high+middle
        printf("------------------------------------------\n")
        printf("| 年龄范围\t | 人数\t | 所占比例\t | \n")
        printf("------------------------------------------\n")
        printf("| 小于20岁\t | %d\t | %.2f%\t | \n",small,small/total*100);
        printf("| 20~30之间\t | %d\t | %.2f%\t | \n",middle,middle/total*100);
        printf("| 大于30岁\t | %d\t | %.2f%\t | \n",high,high/total*100);
    }
    ' worldcupplayerinfo.tsv
    exit 0
}

#   - 统计不同场上位置的球员**数量**、**百分比**
function Position {
    awk -F '\t' 'BEGIN { total=0 }
    NR>1{
        positions[$5]++;total++;  
    }
    END{
        printf("------------------------------------------\n")
        printf("| 位置\t | 人数\t | 所占比例\t | \n")
        printf("------------------------------------------\n")
        for(position in positions) {
            printf("| %s\t | %d\t | %.2f%\t | \n",position,positions[position],positions[position]/total*100);
        }
    }' worldcupplayerinfo.tsv
    exit 0
}


#   - 名字最长的球员是谁？名字最短的球员是谁？（字节、字符统计）
function Name {
    awk -F "\t" 'BEGIN {max=0; min=100}
    NR>1{
        len=length($9);
        names[$9]=len;
        max=len>max?len:max;
        min=len<min?len:min;
    }
    END{
        printf("拥有最长名字的球员有： ")
        for(i in names){
            if(names[i]==max)
            printf("%s\t",i)
        }
        printf("\n")
        printf("拥有最短名字的球员有： ")
        for(i in names){
            if(names[i]==min)
            printf("%s\t",i)
        }
        printf("\n")
    } ' worldcupplayerinfo.tsv
    exit 0
}


#   - 年龄最大的球员是谁？年龄最小的球员是谁？（最可能有多个）
function Ages {
    awk -F "\t" 'BEGIN {max=0; min=100;}
    NR>1{
        ages[$9]=$6;
        max=$6>max?$6:max;
        min=$6<min?$6:min;
    }
    END{
        printf("拥有最大年龄的球员有： ")
        for(i in ages){
            if(ages[i]==max)
            printf("%s\t",i)
        }
        printf("\n")
        printf("拥有最小年龄的球员有： ")
        for(i in ages){
            if(ages[i]==min)
            printf("%s\t",i)
        }
        printf("\n")
    } ' worldcupplayerinfo.tsv
    exit 0
}

[[ $# -eq 0 ]] && help

while getopts 'apnmh' OPT; do
    case $OPT in
        a)  
            Age 
            ;;
        p)
            Position
            ;;
        n)
            Name
            ;;
        m)
            Ages
            ;;
        h | *) 
            help 
            ;;
    esac
done 



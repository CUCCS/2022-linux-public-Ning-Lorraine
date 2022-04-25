#!/usr/bin/env bash

# - 支持对jpeg格式图片进行图片质量压缩
# - 支持对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
# - 支持对图片批量添加自定义文本水印
# - 支持批量重命名（统一添加文件名前缀或后缀，不影响原始文件扩展名）
# - 支持将png/svg图片统一转换为jpg格式图片

function help {
    echo "-c Q               对jpg格式图片进行图片质量因子为Q的压缩"
    echo "-r T W             对jpg/png/svg格式图片在保持原始宽高比的前提下压缩至宽度为W的图片"
    echo "-w content size position对图片批量添加自定义文本水印
    content 写入水印内容
    size 一个数字，表示写入水印大小  
    position写入水印位置,如:NorthWest, North, NorthEast, West, East, SouthWest, South, SouthEast, center"
    echo "-p t               统一添加文件名前缀内容t，不影响原始文件扩展名"
    echo "-s t               统一添加文件名后缀内容t，不影响原始文件扩展名"
    echo "-t                 将png/svg图片统一转换为jpg格式图片"
    echo "-h                 帮助文档"
}

#图片质量压缩
function CompressQuality {
    Q=$1 #质量因子
    echo "${Q}"
    for imge in img/*;do
        type=${imge##*.} #取文件名后缀
        if [[ "${type}" != "jpeg" ]]; then continue;fi
        convert -quality "${Q}" "${imge}" "${imge}"
        echo "${imge} is Successfully compressed."
    done
}


#图片压缩分辨率
function CompressResolution {
    T=$1 #格式jpg\svg\png
    W=$2 #指压缩指定宽度
    for imge in img/*;do
        type=${imge##*.}
        if [[ "${type}" == "${T}" ]];then  
            convert "${imge}" -resize "${W}" "${imge}"
            echo "${imge} is Successfully compressed."
        elif [[ "${type}" != "${T}" ]];then continue;
        fi
    done 
}



#对图片批量添加自定义文本水印
function WaterMark {
    content=$1
    size=$2
    position=$3 
    echo "${content} ${size} ${position}"
    for imge in img/* ;do
        type=${imge##*.}
        if [[ ${type} = "jpg" ||  ${type} = "svg" ||  ${type} = "png" || ${type} = "jpeg" ]]; then
        convert "${imge}" -pointsize "${size}" -fill red -gravity "${position}" -draw "text 10,10 '${content}'" "${imge}"
        fi
        echo "${imge} is watermarked with ${content} successfully ."
    done
}

#批量重命名（统一添加文件名前缀，不影响原始文件扩展名）
function Rename_prefix {
    T="$1"
    for imge in img/*;do
        name=${imge##*/}  #取文件名
        new=img/"${T}${name}"
        mv "${imge}" "${new}"
        echo "${imge} is Successfully renamed to ${T}${name}."
    done

}

#批量重命名（统一添加文件名后缀，不影响原始文件扩展名）
function Rename_suffix {
    T=$1
    for imge in img/*;do
        type="."${imge##*.} #文件类型
        name=$(basename "${imge}" "${type}") #文件名字
        new=img/"${name}${T}${type}"
        mv "${imge}" "${new}"
        echo "${imge} is Successfully renamed to ${new}."
    done
}


#将png/svg图片统一转换为jpg格式图片 
function TransformToJpg {
    # T=$1
    for imge in img/* ;do
        type=${imge##*.}
        if [[ "${type}" == "png" || "${type}" == "svg" ]]; then
            new_name=${imge%.*}".jpg"
            convert "${imge}" "${new_name}"
            echo "${imge} has transformed into ${new_name}"
        else continue;
        fi
    done
}


[ $# -eq 0 ] && help
if [ "$1" != "" ];then #判断命令行要求做什么操作
    case "$1" in
        "-h")
            help
            exit 0
            ;;
        "-c")
            CompressQuality "$2"
            exit 0
            ;;
        "-r")
            CompressResolution "$2"
            exit 0
            ;;
        "-w")
            WaterMark "$2" "$3" "$4"
            exit 0
            ;;
        "-p")
            AddPrefix "$2"
            exit 0
            ;;
        "-s")
            AddSuffix "$2"
            exit 0
            ;;
        "-t")
            TransformToJpg
            exit 0
            ;;
    esac
fi


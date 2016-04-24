
SOURCE_FILE="README.ok.md"

if [ ! -z "$1" ]; then
    SOURCE_FILE=$1
fi

if [ ! -f $SOURCE_FILE ]; then
    echo "File $SOURCE_FILE does not exist!" >&2
    exit 1
fi

IFS=''

Trim() {
    echo $1 | sed 's/^ *//;s/ *$//'
}
GetCommand() {
    echo `Trim $1` | awk '{split($0,a," "); print a[1]}'
}
GetArguments() {
    repl=`GetCommand $1`
    echo `Trim $1` | sed 's/ *'$repl' *//'
}

ExtensionToLanguage() {
    echo ""
}

CommandInsert() {

    filename=${1%%:*};filename=${filename%%@*}
    filepath=$(dirname "$SOURCE_FILE")"/$filename"
    fileext=${filepath##*.}

    if [ ! -f $filepath ]; then
        echo "File $filepath does not exists!" >&2
        exit 1
    fi

    # subset checking
    subset=${1/$filename/}
    subset_type=0 # 0: none 1:lines 2:block

    if [ "${subset:0:1}" == ':' ]; then
        subset_type=1
        subset_ln_st=${subset:1};subset_ln_st=${subset_ln_st%%-*}
        subset_ln_ed=${subset##*-}
    fi
    if [ "${subset:0:1}" == '@' ]; then
        subset_type=2
        subset_blk_name=${subset:1};
        subset_blk_count=0
        subset_blk_trigger=0
    fi

    echo '```'$fileext

    # sed '!d' $filepath
    linenum=1
    while read line; do
        if [ $subset_type -eq 1 ]; then
            if [ $subset_ln_st -le $linenum ] && [ $subset_ln_ed -ge $linenum ]; then
                echo $line
            fi
        elif [ $subset_type -eq 2 ]; then
            if [[ $line == *$subset_blk_name ]]; then
                echo $line
                subset_blk_trigger=1
            elif [ $subset_blk_trigger -eq 1 ] && [[ $line == *"{" ]]; then
                echo $line
                subset_blk_trigger=2
                subset_blk_count=$(($subset_blk_count+1))
            elif [ $subset_blk_trigger -eq 2 ]; then
                echo $line
                if [[ $line == *"}" ]]; then
                    subset_blk_count=$(($subset_blk_count-1))
                fi
                if [ $subset_blk_count -eq 0 ]; then
                    subset_blk_trigger=0
                fi
            fi
        else
            echo $line
        fi
        linenum=$((linenum+1))
    done < $filepath

    # print last line
    if [ $subset_type -eq 1 ]; then
        if [ $subset_ln_st -le $linenum ] && [ $subset_ln_ed -ge $linenum ]; then
            if [ "$line" != '' ]; then
                echo $line
            fi
        fi
    elif [ $subset_type -eq 2 ]; then
        if [ $subset_blk_trigger -gt 0 ]; then
            if [ "$line" != '' ]; then
                echo $line
            fi
        fi
    else
        if [ "$line" != '' ]; then
            echo $line
        fi
    fi

    echo '```'
}

CommandPrint() {
    echo $1
}

code_block=false
# read line from SOURCE_FILE
while read line; do
    if [ "${line:0:2}" == "%%" ] && [ "$code_block" != true ]; then
        # get command
        command=`GetCommand ${line:2}`
        args=`GetArguments ${line:2}`

        # for debugging
        # echo "command : ($command)"
        # echo "arguments : ($args)"

        if [ "$command" == "insert" ]; then
            CommandInsert $args $code_block
        elif [ "$command" == "print" ]; then
            CommandPrint $args
        else
            echo "Command $command is not supported!" >&2
            exit 1
        fi
    else
        if [ "${line:0:3}" == "\`\`\`" ]; then
            if [ "$code_block" = true ]; then
                code_block=false
            else
                code_block=true
            fi
        fi
        echo $line
    fi
done < $SOURCE_FILE

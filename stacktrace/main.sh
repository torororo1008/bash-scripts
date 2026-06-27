#!/bin/bash

# エラーが発生したら処理を停止する（-e）
# trapコマンドで設定したエラーハンドラ（ERR トラップ）を、関数やサブシェル、コマンド置換の内部へも引き継がせる（-E）
set -Ee
#set -eo errtrace

# 関数読み込み
source ./lib1.sh

# スタックトレース出力関数
print_stacktrace() {

    echo "Error!"

    # 関数内のローカル変数を定義する
    local i=0
    local frame

    # callerコマンドが終了コード=0（成功）を返す間、処理を繰り返す
    while frame=$(caller $i); do

        # callerコマンドで取得した「行番号($1) 関数名($2) ファイル名($3)」を出力する
        echo "${frame}" | awk '{ printf  "at " $2"("$3":"$1")\n"}'

        # 必ず前置インクリメントにすること
        # 後置インクリメントにすると、i=0が評価されて終了コード=1（失敗）が返り、set -eしているので処理が停止してしまう
        ((++i))
    done
}

# 方法１：callerコマンドでスタックトレースを出力する（推奨）
# 終了コード≠0で終了した場合、スタックトレース出力関数を呼び出す
#trap print_stacktrace ERR

# 方法２：特別なシェル変数でスタックトレースを出力する
# 終了コード≠0で終了した場合、スタックトレースを出力する
# LINENOなど一部の特別なシェル変数は、trapコマンドの''中で改行すると、期待した位置を示さない場合があるため、ここではワンライナーとしている
#trap 'echo "Error!"; echo "Command : $BASH_COMMAND"; echo "Location: ${BASH_SOURCE[0]}:$LINENO"; for ((i=0;i<${#FUNCNAME[@]};i++)); do if [[ $i -eq 0 ]]; then printf "  at %s (%s:%s:%s)\n" "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "$LINENO" "$i"; else printf "  at %s (%s:%s:%s)\n" "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "${BASH_LINENO[$((i-1))]}" "$i"; fi; done' ERR

# 改行して記述すると以下
trap '
    echo "Error!"
    echo "Command : $BASH_COMMAND"
    echo "Location: ${BASH_SOURCE[0]}:$LINENO"
    for ((i=0;i<${#FUNCNAME[@]};i++)); do
        if [[ $i -eq 0 ]]; then
            printf "  at %s (%s:%s:%s)\n" "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "$LINENO" "$i"
        else 
            printf "  at %s (%s:%s:%s)\n" "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "${BASH_LINENO[$((i-1))]}" "$i"
        fi
    done
' ERR

# エラー発生
foo

#!/bin/bash

# ファイル名作成
OUTFILE="summary_$(date +"%Y%m%d").csv"

# 出力ファイル初期化
: > "$OUTFILE"

# ヘッダ出力
echo "product,origin,count" >> "$OUTFILE"

# 集計処理
awk -F',' 'NR>1 {print $1","$2}' ./list.csv \
| sort \
| uniq -c \
| awk 'BEGIN{OFS=","} 
      {
       # uniq -cした時点では区切り文字が空白とカンマが混在しており、このままだとsortできないため、区切り文字をカンマに統一する
       print $2,$1
       }' \
| sort -t',' -k3,3nr -k1,1 -k2,2  >> "$OUTFILE"

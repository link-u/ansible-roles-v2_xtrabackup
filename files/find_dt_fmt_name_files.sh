#!/bin/sh
# 日付が含まれたファイル名のファイルを出力する
# 条件としては指定のパターンにファイル名がマッチ
# かつ指定の日数より古いファイル名である必要がある
# 日数を指定したくない場合はthreshold_days=0を指定する
# pattern変数はsedの正規表現で(年)(月)(日)となるよう指定する
# (年)(月)(日)、(年)_(月)_(日)、(年)-(月)-(日)とかで指定可能
# 例）pattern=(20[0-9]{2})([01][0-9])([0-9]{2})

# variables
target_file_type='any'  # [dir|file|any]
pattern='(20[0-9]{2})([01][0-9])([0-9]{2})'
threshold_days=7
ymd_fmt="\1\2\3"

usage_exit() {
        echo "Usage: $0 [-d DAYS] [-t (dir|file|any)] [-p MATCH_PATTERN] [-f YMD_FORMAT] /path/to/directory" 1>&2
        exit 1
}

while getopts d:t:p:r:h OPT
do
  case $OPT in
    d) threshold_days="$OPTARG"
       ;;
    t) target_file_type="$OPTARG"
       ;;
    p) pattern="$OPTARG"
       ;;
    f) ymd_fmt="$OPTARG"
       ;;
    h) usage_exit
       ;;
  esac
done

shift $((OPTIND - 1))

target_dir=$1

if [ ! $target_dir ]; then
  usage_exit
fi

if [ ! -e $target_dir ]; then
  echo "Directory not found."
  exit 2
fi

find_opts=""
if [ $target_file_type = 'dir' ]; then
  find_opts="-type d"
elif [ $target_file_type = 'file' ]; then
  find_opts="-type f"
fi

files=`find $target_dir -maxdepth 1 -mindepth 1 $find_opts`
threshold_dt=`date +"%Y%m%d" -d "$threshold_days days ago"`
for f in $files; do
  name=`basename $f`
  dt=`echo $name | sed -En "s/.*$pattern.*/$ymd_fmt/p"`
  if [ $dt ]; then
    if [ $dt -le $threshold_dt ]; then
      echo $f
    fi
  fi
done

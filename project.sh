#!/usr/bin/env bash
# References:
#   Ref1: https://linuxize.com/post/bash-increment-decrement-variable/
#   Ref2: https://unix.stackexchange.com/questions/32250/why-does-a-0-let-a-return-exit-code-1
#
set -eou pipefail
cd `dirname "$0"`
source ./config.sh
list=$MATRIX_PROJECTS_DIR/list.txt
count=0
action=${1:-add}
while IFS= read -r line; do
  # Ref1, Ref2
  (( count+=1 ))
  if (( count == 1 )); then
    file=`echo "$line" | cut -f1 -d'|'`
    line=`echo "$line" | cut -f2 -d'|'`
    file_dirname=`dirname "$file"`
    file_name=`basename "$file"`
    file_dir=$MATRIX_PROJECTS_DIR/$file_dirname
    mkdir -p $file_dir
    ! [ -f $list ] && { mkdir -p `dirname $list`; touch $list; }
    if ! grep -q "$file_dirname" $list; then
      echo "Adding project $file_dirname"
      echo "$file_dirname" >> $list
    else
      if [ "$action" = "remove" ]; then
        echo "Removing project $file_dirname"
        grep -v "$file_dirname" $list > $list.tmp || :
        mv $list.tmp $list
        break
      fi
      action=update
      echo "Updating project $file_dirname"
    fi
    > "$file_dir"/$file_name
  fi
  echo "$line" >> "$file_dir"/$file_name
done < <(cat -)
if source "$file_dir/$file_name" &> /dev/null; then
  case "$action" in
    add|remove) fun=$FUNCTIONS_PREFIX-project-$action;;
    *) exit 0
  esac
  source ./matrix.sh
  if type $fun &> /dev/null; then
    echo "Running $fun ..."
    set +e; $fun
  fi
fi

#!/usr/bin/env bash
MATRIX_HOME=`cd $(dirname "${BASH_SOURCE[0]}"); pwd -P`
cd "$MATRIX_HOME"
case "$OSTYPE" in
  darwin*)
    which gsed &> /dev/null || {
      echo -e "Install gsed!\n$ brew install gnu-sed"
      return 1
    }
    sed() { gsed "$@"; }
    which ggrep &> /dev/null || {
      echo -e "Install ggrep!\n$ brew install grep"
      return 1
    }
    function grep { ggrep "$@"; }
esac
[ -f ./config.sh ] || cp ./config.sample.sh ./config.sh
source ./config.sh || {
  echo "File \"$PWD/config.sh\" could not be read!"
  return 1
}
[ -f /.dockerenv ] &&
  source ./matrix.sh ||
  source ./real-world.sh
cd "$OLDPWD"

#!/usr/bin/env bash
# References:
#   Ref1: https://stackoverflow.com/questions/28302178/how-can-i-add-a-volume-to-an-existing-docker-container
#   Ref2: https://container42.com/2016/03/27/docker-quicktip-7-psformat/
#

#################################################
# Matrix Internal Functions BEGIN (starts with _)

_matrix-start() {
  local dir=$1
  docker run -d --name $MATRIX_CONTAINER_NAME -p $MATRIX_PORT:8080 \
    -v "$MATRIX_HOME":/matrix \
    $MATRIX_ENVIRONMENT \
    $MATRIX_IMAGE_NAME
  docker exec -t $MATRIX_CONTAINER_NAME /bin/bash -c 'source /matrix/functions.sh'
  _matrix-project "$dir"
}

_matrix-project() {
  local dir=$1
  local action=$2
  local file=$dir/matrix-functions.sh
  if [ "$dir" ]; then
    echo -e "$file|`cat "$file"`" |
      docker exec -i $MATRIX_CONTAINER_NAME /matrix/project.sh $action
  fi
}

_matrix-dir() {
  local dir=${1:-.}; [ $dir = . ] && dir=`pwd -P` || dir=`cd "$dir";pwd -P`
  [ -f "$dir"/matrix-functions.sh ] || return 1
  echo -n "$dir"
}

# Matrix Internal Functions END -----------------
#################################################

#################################
# Matrix callable functions BEGIN

matrix-home() { # Go to $MATRIX_HOME
  cd "$MATRIX_HOME"
}

matrix-set-version() { # Changes the Matrix version (inside config.sh)
  sed -i "s/^\(MATRIX_VERSION=\).*/\1$1/g" "$MATRIX_HOME"/config.sh
}

matrix-create() { # Creates a connection with Matrix!
  ! [ -f matrix-functions.sh ] || set -- --project-add .
  case "$1" in
    --project-add)
      shift; [ "$1" ] || { echo "Which dir?"; return 1; }
      _matrix-start `_matrix-dir "$1"`
      ;;
    *) _matrix-start
  esac
}

matrix-ui() { # Open the Matrix UI
  open $MATRIX_ADMIN_URL
}

matrix-enter() { # Enters you in Matrix
  docker exec -it $MATRIX_CONTAINER_NAME /bin/bash
}

matrix-stop() { # Stops the Matrix
  docker stop $MATRIX_CONTAINER_NAME
}

matrix-start() { # Recreates the connection with Matrix
  docker start $MATRIX_CONTAINER_NAME
}

matrix-status() { # Shows the Matrix status
  # Ref2
  local ps=$(docker ps -a --format '{{.Names}}\t{{.Status}}')
  ! [ "$ps" ] && echo not-created || {
    local status
    status=$(set -o pipefail && grep -P "^$MATRIX_CONTAINER_NAME\t" <<< "$ps" | cut -f2) && {
      [[ $status =~ ^Up ]] && echo up || echo down
    } || echo not-created
  }
}

matrix-destroy() { # Destroy the Matrix ... Ok, I know ... it's almost impossible! :D
  matrix-stop
  docker rm $MATRIX_CONTAINER_NAME
  rm -rf "$MATRIX_HOME"/$MATRIX_PROJECTS_DIR
}

matrix-reload() { # Reloads the Matrix functions
  . "$MATRIX_HOME"/functions.sh
}

matrix-project-add() { # Add a project (a dir where matrix-functions.sh are located)
  [ "$1" ] || set -- .
  local dir
  dir=`_matrix-dir "$1"` || {
    echo "File \"$1/matrix-functions.sh\" not found!"
    return 1
  }
  case "`matrix-status`" in
    not-created) matrix-create; return 0;;
    down) matrix-start;;
  esac
  _matrix-project "$dir"
}

matrix-project-remove() { # Remove a project
  [ "$1" ] || set -- .
  local dir
  dir=`_matrix-dir "$1"` || {
    echo "File \"$1/matrix-functions.sh\" not found!"
    return 1
  }
  case "`matrix-status`" in
    down) matrix-start;;
  esac
  _matrix-project "$dir" remove
}


# Matrix callable functions END--
#################################

profile=~/.bash_profile
[[ $OSTYPE =~ ^linux ]] && profile=~/.bashrc
functions_sh=$MATRIX_HOME/functions.sh
if ! [ -f $profile ] || ! grep -q "^source \"$functions_sh\"$" $profile; then
  echo "source \"$functions_sh\"" >> $profile
  echo "'source \"$functions_sh\"' added to $profile"
fi

[ -f ~/.keycloak-matrix ] || cat - <<EOF
Hello Neo! You are in the real world (that is, without superpowers)!
The Matrix setup was loaded from "$functions_sh" script.

Inside the real world, you have access to following Matrix (version $MATRIX_VERSION) functions:
$(grep '^matrix-.*{' ${BASH_SOURCE[0]} | sed 's/) { #/) -/g' | sort)

You can access the Matrix UI by calling the matrix-ui function which will open this URL:
$MATRIX_ADMIN_URL
Then you need will need to enter the Username ($MATRIX_ADMIN_USER) and the Password ($MATRIX_ADMIN_PASSWORD)
EOF

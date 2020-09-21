#!/usr/bin/env bash
case "$MATRIX_NAME" in
  keycloak)
    export KEYCLOAK_HOME=/opt/jboss/keycloak
    export PATH=$KEYCLOAK_HOME/bin:$PATH
  ;;
  rh-sso*)
    export RH_SSO_HOME=/opt/eap
    export PATH=$RH_SSO_HOME/bin:$PATH
  ;;
esac

matrix-path() {
  echo $PATH | tr : '\n'
}

matrix-master-realm-login() {
  local host=localhost
  case "$MATRIX_NAME" in
    rh-sso*)
      host=$(tail -1 /etc/hosts | cut -f1)
  esac
  kcadm.sh config credentials \
    --server http://$host:8080/auth --realm master \
    --user $MATRIX_ADMIN_USER --password $MATRIX_ADMIN_PASSWORD \
    --client admin-cli
}

matrix-echo() {
  echo "${FUNCNAME[1]}: $@"
}

matrix-show-log() {
  local ret=$?
  local fun=${FUNCNAME[1]}
  local log=$1
  [ $ret = 0 ] &&
    echo "$fun: executed successfuly!" ||
    echo "$fun: returned an error:"
  cat $log
}

matrix-show-log-clientId() {
  local ret=$?
  local fun=${FUNCNAME[1]}
  local log=$1
  [ $ret = 0 ] && {
    echo "$fun: returned a client with id $(cat $log)"
    return 0
  } || echo "$fun: returned an error:"
  cat $log
}

if ! [ -f ~/.bashrc ] || ! grep -q '# matrix-setup' ~/.bashrc; then
  echo "Setting up ~/.bashrc ..."
	cat <<-'EOF' | expand -t4 > ~/.bashrc
	# matrix-setup BEGIN
	echo "Hello Neo! You're inside the Matrix world!"
	source /matrix/functions.sh
	list=/matrix/$MATRIX_PROJECTS_DIR/list.txt
	if [ -f $list ]; then
	  while IFS= read -r dir
	  do
	    f=${list%/*}/${dir#/}/matrix-functions.sh
	    source "$f" &&
	      echo "File \"$f\ loaded!" ||
	      echo "File \"$f\" could not be loaded!"
	  done < $list
	  unset f
	fi
	unset list
	echo "Here you have access to the following Matrix functions:"
	set | grep ^matrix- | sort
	export PS1='matrix$ '
	# matrix-setup END
	echo
	EOF
fi

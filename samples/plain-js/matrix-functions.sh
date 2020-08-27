#!/usr/bin/env bash
# References:
#   Ref1: https://unix.stackexchange.com/questions/206886/print-previous-line-after-a-pattern-match-using-sed
#
export FUNCTIONS_PREFIX=plain-js

plain-js-create-demo-realm() {
  local log=`mktemp`
  matrix-echo "Creating demo realm"
  kcadm.sh create realms \
    -s realm=demo \
    -s enabled=true \
    -s registrationAllowed=true \
    -s registrationEmailAsUsername=true &> $log
  matrix-show-log $log
}

plain-js-remove-demo-realm() {
  matrix-echo "Removing demo realm"
  kcadm.sh delete realms/demo
  [ $? = 0 ] &&
    matrix-echo "Realm removed" ||
    matrix-echo "Realm could not be removed!"
}

plain-js-create-plain-js-client() {
  local log=`mktemp`
  local baseUrl=http://localhost:3000
  matrix-echo "Creating plain-js client"
  kcadm.sh create clients -r demo \
      -s clientId=plain-js \
      -s publicClient=true \
      -s baseUrl=$baseUrl/ \
      -s "redirectUris=[\"$baseUrl/*\"]" \
      -s directAccessGrantsEnabled=true \
      -i &> $log
  matrix-show-log-clientId $log
}

# TODO Use jq or eiiches/jackson-jq to parse the JSON returned by kcadm
plain-js-remove-plain-js-client() {
  local clientId
  matrix-echo "Removing plain-js client"
  # Ref1
  clientId=$(kcadm.sh get clients -r demo --fields id,clientId |
    sed -n '/plain-js/{x;p;d;}; x' |
    sed 's/.*"id" : "\(.*\)",/\1/g') &&
    kcadm.sh delete clients/$clientId -r demo
  [ $? = 0 ] &&
    matrix-echo "Client removed" ||
    matrix-echo "Client could not be removed!"
}

plain-js-project-add() {
  matrix-master-realm-login || {
    matrix-echo "Failed to login on master realm"
    return 1
  }
  plain-js-create-demo-realm
  plain-js-create-plain-js-client
}

plain-js-project-remove() {
  matrix-master-realm-login || {
    matrix-echo "Failed to login on master realm"
    return 1
  }
  plain-js-remove-plain-js-client
  plain-js-remove-demo-realm
}

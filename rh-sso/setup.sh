#!/usr/bin/env bash
set -eou pipefail

cd "`dirname "$0"`/.."
remove_only=false
[ "${1:-}" = "remove_only" ] && remove_only=true
rm -rf keystore jgroups truststore
! $remove_only || exit 0

echo "Configuring keystore ..."
{
  mkdir keystore
  openssl req -new -newkey rsa:2048 -x509 -keyout keystore/xpaas.key -out keystore/xpaas.crt -days 365 -subj "/CN=localhost" -nodes
  keytool -genkeypair -keyalg RSA -keysize 2048 -dname "CN=localhost" -alias jboss -keystore keystore/keystore.jks -storepass secret -keypass secret
  keytool -certreq -keyalg rsa -alias jboss -keystore keystore/keystore.jks -file keystore/sso.csr -storepass secret
  openssl x509 -req -CA keystore/xpaas.crt -CAkey keystore/xpaas.key -in keystore/sso.csr -out keystore/sso.crt -days 365 -CAcreateserial
  keytool -import -file keystore/xpaas.crt -alias xpaas.ca -keystore keystore/keystore.jks -storepass secret -trustcacerts -noprompt
  keytool -import -file keystore/sso.crt -alias jboss -keystore keystore/keystore.jks -storepass secret
} &> /dev/null

echo "Configuring jgroups ..."
{
  mkdir jgroups
  # https://stackoverflow.com/questions/45340079/why-i-can-not-generate-key-with-keytool-and-rsa
  keytool -genseckey -keyalg AES -keysize 256 -alias secret-key -storetype JCEKS -keystore jgroups/jgroups.jceks -storepass secret -keypass secret
} &> /dev/null

echo "Configuring truststore ..."
{
  mkdir truststore
  keytool -import -file keystore/xpaas.crt -alias xpaas.ca -keystore truststore/truststore.jks -storepass secret -trustcacerts -noprompt
} &> /dev/null

touch .setup-done
echo "Setup done!"

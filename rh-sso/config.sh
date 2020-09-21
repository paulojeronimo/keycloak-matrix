# Matrix name
MATRIX_NAME=rh-sso-73

# Container name
MATRIX_CONTAINER_NAME=$MATRIX_NAME

# Image version
MATRIX_VERSION=latest

# Image name
case "$MATRIX_NAME" in
  rh-sso-73)
    MATRIX_IMAGE_NAME=registry.access.redhat.com/redhat-sso-7/sso73-openshift
  ;;
  rh-sso-74)
    MATRIX_IMAGE_NAME=registry.redhat.io/rh-sso-7/sso74-openshift-rhel8
  ;;
esac
MATRIX_IMAGE_NAME=$MATRIX_IMAGE_NAME:$MATRIX_VERSION

# Container HOST port
MATRIX_PORT=8180

# Username and password
MATRIX_ADMIN_USER=admin
MATRIX_ADMIN_PASSWORD=admin

# Container allocated memory
MATRIX_MEMORY="-m 1Gi"

# Ports
MATRIX_PORTS="
-p 8443:8443
-p 8778:8778
-p $MATRIX_PORT:8080
-p 8888:8888
"

# Environment
MATRIX_ENVIRONMENT="
-e SSO_HOSTNAME=localhost
-e SSO_ADMIN_USERNAME=$MATRIX_ADMIN_USER
-e SSO_ADMIN_PASSWORD=$MATRIX_ADMIN_PASSWORD
-e HTTPS_KEYSTORE_DIR=/etc/keystore
-e HTTPS_KEYSTORE=keystore.jks
-e HTTPS_KEYSTORE_TYPE=jks
-e HTTPS_NAME=jboss
-e HTTPS_PASSWORD=secret
-e JGROUPS_ENCRYPT_KEYSTORE_DIR=/etc/jgroups
-e JGROUPS_ENCRYPT_KEYSTORE=jgroups.jceks
-e JGROUPS_ENCRYPT_NAME=secret-key
-e JGROUPS_ENCRYPT_PASSWORD=secret
-e JGROUPS_CLUSTER_PASSWORD=random
-e SSO_TRUSTSTORE=truststore.jks
-e SSO_TRUSTSTORE_DIR=/etc/truststore
-e SSO_TRUSTSTORE_PASSWORD=secret
"

# Volumes
MATRIX_VOLUMES="
-v $PWD/keystore:/etc/keystore
-v $PWD/jgroups:/etc/jgroups
-v $PWD/truststore:/etc/truststore
"

# Admin URL
MATRIX_ADMIN_URL=http://localhost:$MATRIX_PORT/auth/admin

# Projects dir
MATRIX_PROJECTS_DIR=projects

# Setup
setup=$PWD/rh-sso/setup.sh
[ -f $PWD/.setup-done ] || {
  [ -x "$setup" ] && "$setup" || echo "WARNING: File \"$setup\" is not executable!"
}

# Matrix name
MATRIX_NAME=keycloak

# Container name
MATRIX_CONTAINER_NAME=$MATRIX_NAME

# Image version
MATRIX_VERSION=11.0.2

# Image name
MATRIX_IMAGE_NAME=quay.io/keycloak/keycloak:$MATRIX_VERSION

# Container HOST port
MATRIX_PORT=8180

# Username and password
MATRIX_ADMIN_USER=admin
MATRIX_ADMIN_PASSWORD=admin

# Container allocated memory
#MATRIX_MEMORY=

# Ports
MATRIX_PORTS="
-p $MATRIX_PORT:8080
"

# Environment
MATRIX_ENVIRONMENT="
-e KEYCLOAK_USER=$MATRIX_ADMIN_USER
-e KEYCLOAK_PASSWORD=$MATRIX_ADMIN_PASSWORD
"

# Volumes
#MATRIX_VOLUMES=

# Admin URL
MATRIX_ADMIN_URL=http://localhost:$MATRIX_PORT/auth/admin

# Projects dir
MATRIX_PROJECTS_DIR=projects

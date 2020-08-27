# Matrix name
MATRIX_NAME=keycloak

# Container name
MATRIX_CONTAINER_NAME=$MATRIX_NAME

# Image version
MATRIX_VERSION=11.0.0

# Image name
MATRIX_IMAGE_NAME=quay.io/keycloak/keycloak:$MATRIX_VERSION

# Container HOST port
MATRIX_PORT=8080

# Username and password
MATRIX_ADMIN_USER=admin
MATRIX_ADMIN_PASSWORD=admin

# Environment
MATRIX_ENVIRONMENT="-e KEYCLOAK_USER=$MATRIX_ADMIN_USER -e KEYCLOAK_PASSWORD=$MATRIX_ADMIN_PASSWORD"

# Admin URL
MATRIX_ADMIN_URL=http://localhost:$MATRIX_PORT/auth/admin

# Projects dir
MATRIX_PROJECTS_DIR=projects

#!/usr/bin/env bash
set -eou pipefail

cd "`dirname "$0"`"
which ruby &> /dev/null || { echo "Install ruby!"; exit 1; }
ruby -run -e httpd webapp -p 3000

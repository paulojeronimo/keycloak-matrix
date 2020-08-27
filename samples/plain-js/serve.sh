#!/usr/bin/env bash
set -eou pipefail

which ruby &> /dev/null || { echo "Install ruby!"; exit 1; }
ruby -run -e httpd webapp -p 3000

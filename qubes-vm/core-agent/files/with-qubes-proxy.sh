#!/bin/sh

if [ -f /var/run/qubes/this-is-templatevm ]; then
    export http_proxy=127.0.0.1:8082
    export https_proxy=127.0.0.1:8082
fi

exec "$@"

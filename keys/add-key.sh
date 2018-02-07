#!/bin/sh

gpg2 --export --export-options export-minimal --armor "$@"

if [ -t 1 ]; then
    echo "" >&2
    echo "/!\\ /!\\" >&2
    echo "You should run this script by redirecting its output to a file in ‘$(dirname $0)/keys’" >&2
    echo "/!\\ /!\\" >&2
    exit 1
fi

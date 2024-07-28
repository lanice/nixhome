#!/usr/bin/env bash
basedir="$HOME/invokeai"



pushd $basedir
source .venv/bin/activate
invokeai-web --port 9000
popd

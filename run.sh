#!/bin/bash -e

source env.sh

# export DISPLAY=:0.0
url=`nodejs ./run.js 2>/dev/null`
echo "'$url',"


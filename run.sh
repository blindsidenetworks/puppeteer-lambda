#!/bin/bash -e

source env.sh

# export DISPLAY=:0.0
url=`nodejs ./run.js`
echo "'$url',"


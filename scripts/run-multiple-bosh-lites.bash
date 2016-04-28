#!/bin/bash 
set -e

NUM_INSTANCES=${1:-20} 

INSTALL=""
OS=$(uname -s)
BOSH_LITES_DIR=$HOME/tmp/bosh-lites

abspath() {
    local DIR=$(dirname "$1")
    cd $DIR
    printf "%s/%s\n" "$(pwd)" "$(basename "$1")" | perl -pe 's{/{2,}}{/}g'
    cd "$OLDPWD"
}

THIS_DIR=$(dirname $(abspath $0))
$THIS_DIR/mac-check-prerequsites.bash

seq 1 $NUM_INSTANCES |
    parallel --tag --line-buffer -I % -j 5 "$THIS_DIR/run-a-vagrant-bosh-lite.bash $BOSH_LITES_DIR/%; sleep 1"

. $THIS_DIR/shell_helpers.bash

our_boshlites 1; parallel -j 50 "ssh -o StrictHostKeyChecking=no ubuntu@{} id" ::: $OUR_BOSHLITES

$THIS_DIR/fixup-bosh-lite-vms.bash


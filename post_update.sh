#!/bin/bash

# $1 Path to the new version.
# $2 Path to the old version.

set -x
set -e

cp -a -n -r $2/android $1/

# Use pregenerated host-target.txt in the out directory.
mkdir out
echo -n "x86_64-unknown-linux-gnu" > out/host-target.txt
OLDSTR='include_str!(concat!(env!("OUT_DIR"), "/host-target.txt"));'
NEWSTR='include_str!("../out/host-target.txt");  // to build on ANDROID'
sed -i -e "s:$OLDSTR:$NEWSTR:" src/lib.rs
# Make sure that sed replaced $OLDSTR with $NEWSTR
grep "$NEWSTR" src/lib.rs > /dev/null

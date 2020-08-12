#!/bin/bash
#
# Copyright (C) 2020 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -e

# Ideally only 2 version numbers are changed after a new clang/rust release.
# libclang.so could be from prebuilts/clang-tools when available in the future.
CLANG_VERSION=clang-r383902c
CLANG_SO_GIT=11git

CLANG_HOST=prebuilts/clang/host
RUST_HOST=prebuilts/rust
MYDIR=`dirname $0`
MYDIR=`(cd $MYDIR ; pwd)`
case "$MYDIR" in
  */darwin-x86/bin)
    export CLANG_PATH=${CLANG_HOST}/darwin-x86/${CLANG_VERSION}/bin/clang
    export LIBCLANG_PATH=${CLANG_HOST}/darwin-x86/${CLANG_VERSION}/lib64/libclang.dylib
    export RUSTFMT=${RUST_HOST}/darwin-x86/stable/rustfmt
    ;;
  */linux-x86/bin)
    export CLANG_PATH=${CLANG_HOST}/linux-x86/${CLANG_VERSION}/bin/clang
    export LIBCLANG_PATH=${CLANG_HOST}/linux-x86/${CLANG_VERSION}/lib64/libclang.so.${CLANG_SO_GIT}
    export RUSTFMT=${RUST_HOST}/linux-x86/stable/rustfmt
    ;;
  *)
    # there is no rustfmt for windows
    echo "ERROR: bindgen.sh only works on linux-x86 and darwin-x86"
    exit 1
esac

for (( i=1; i <= $#; i++)); do
  if [[ ${!i} == "-v" || ${!i} == "--verbose" ]]
  then
    echo "### $0 called in `pwd`"
    echo "### CLANG_PATH=${CLANG_PATH}"
    echo "### LIBCLANG_PATH=${LIBCLANG_PATH}"
    echo "### RUSTFMT=${RUSTFMT}"
    break
  fi
done

if [ "$1" == "--bindgen-path" ]
then
  # non-standard installation; user given bindgen path
  BINDGEN=$2
  shift
  shift
else
  # standard installation; use bindgen in the same directory
  BINDGEN=`dirname $0`/bindgen
fi
${BINDGEN} $*

# find -MF flag and append tool paths to the dependent file
for (( i=1; i <= $#; i++)); do
  if [ ${!i} == "-MF" ]
  then
    j=$((i+1))
    DEPFILE="${!j}"
    echo "outputfile: ${CLANG_PATH}" >> $DEPFILE
    echo "outputfile: ${LIBCLANG_PATH}" >> $DEPFILE
    echo "outputfile: ${RUSTFMT}" >> $DEPFILE
    exit 0
  fi
done

echo "ERROR: bindgen.sh should be called with -MD -MF <dependent_file>"
exit 1

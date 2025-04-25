#!/usr/bin/env bash

set -eu -o pipefail

cd "${0%/*}/../.."

"${DOCKER:-docker}" run -v .:/app -w /app ubuntu:23.10 --rm bash -x -c '
set -eu -o pipefail

apt update

apt install ansible make -y

make ansible

source ~/.trainrc

python --version
which python

make clean_dev

export PYTHON_D=/tmp/python.d # can not write in docker home, this change not needed on laptop
make code_check

make run_all_test_coverage
'

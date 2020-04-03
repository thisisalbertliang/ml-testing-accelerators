#!/bin/bash

p=`echo $PWD | sed s/scripts//`
cd $p
set -e
set -x
which jsonnet &> /dev/null
rm k8s/gen/*yaml
jsonnet -S templates/multifile.jsonnet -m k8s/gen
cd -

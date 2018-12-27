#!/usr/bin/env bash

fullpath=$(readlink --canonicalize --no-newline $BASH_SOURCE)
file_folder=$(dirname $fullpath)

# load local yaml config
eval $(parse_yaml $file_folder/config.yaml "cfg__")

# use if set or a string argument otherwise
ACTION=${ACTION:=$1}

if [ -z "$ACTION" ] || [ "$ACTION" != "install" ] && [ "$ACTION" != "delete" ];then
        echo "usage: $0 {'install' | 'delete'}";
        exit 1
elif [ "$ACTION" = "install" ]; then
	helm repo update
	helm upgrade --install $cfg__dask__release \
	 --namespace $cfg__project__k8s_namespace \
	 -f $file_folder/$cfg__dask__config_file stable/dask
else
	helm delete $cfg__dask__release --purge
fi

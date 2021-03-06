#!/usr/bin/env bash

fullpath=$(readlink --canonicalize --no-newline $BASH_SOURCE)
file_folder=$(dirname $fullpath)

# load local yaml config
eval $(parse_yaml $file_folder/$CONFIG_FILE "cfg__")

# use if set or a string argument otherwise
ACTION=${ACTION:=$1}

if [ -z "$ACTION" ] || [ "$ACTION" != "install" ] && [ "$ACTION" != "delete" ];then
        echo "usage: $0 {'install' | 'delete'}";
        exit 1
elif [ "$ACTION" = "install" ]; then
	random_key=$(get_random_string_key 32)
	random_secret=$(get_random_secret_key)
	echo "Starting Minio with:"
	echo "- KEY:$random_key"
	echo "- SECRET:$random_secret"
	echo "- Mounting volume named $cfg__minio__volume_name"
	# https://github.com/helm/charts/tree/master/stable/minio#configuration	
	#helm install --set accessKey=$random_key,secretKey=$random_secret stable/minio
	helm upgrade $cfg__minio__release stable/minio \
	 --namespace $cfg__project__k8s_namespace \
	 --values $file_folder/$cfg__minio__config_file \
	 --set accessKey=$random_key,secretKey=$random_secret,persistence.existingClaim=$cfg__minio__volume_name \
	 --install --force
	unset random_key
	unset random_secret
else
	helm delete $cfg__minio__release --purge
fi

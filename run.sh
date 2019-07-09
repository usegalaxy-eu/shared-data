#!/bin/bash

setup_library() {
	server=$1
	key=$2
	lib_id=$3

	setup-data-libraries -g $server -a $key -vvv --legacy -i GTN.yaml 2>&1 | grep --line-buffered -v DEBUG

	# Super noisy so we'll disable it.
	for dataset in $(parsec libraries show_library $lib_id --contents | jq '.[] | select(.type == "file") | .id' -r); do
		echo -n "$dataset "
		for _ in $(seq 1 10); do
			echo -n '.'
			output="$(curl --silent "$server/api/libraries/datasets/$dataset/permissions?action=set_permissions&key=$GALAXY_API_KEY" --data '')"
			echo "$output" | grep --quiet access_dataset_roles
			ec=$?
			if (( ec == 0 )); then
				echo ''
				break
			else
				sleep 1
			fi
		done;
	done;
}


export IFS=$'\n';
for line in $(cat secrets.json| jq '.[] | [.email, .key, .url, .lib] | @tsv' -r); do
	email=$(echo "$line" | awk '{print $1}');
	key=$(echo "$line" | awk '{print $2}');
	url=$(echo "$line" | awk '{print $3}');
	lib=$(echo "$line" | awk '{print $4}');
	echo "Processing $url"
	setup_library $url $key $lib
done

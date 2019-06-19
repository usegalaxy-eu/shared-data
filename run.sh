#!/bin/bash
set -x

setup-data-libraries -g https://usegalaxy.eu -a $GALAXY_API_KEY -vvv --legacy -i GTN.yaml 2>&1 | grep -v DEBUG

for dataset in $(parsec libraries show_library 7d84c2ac21245dad --contents | jq '.[] | select(.type == "file") | .id' -r); do
	echo -n "$dataset "
	for _ in $(seq 1 10); do
		echo -n '.'
		output="$(curl --silent "https://usegalaxy.eu/api/libraries/datasets/$dataset/permissions?action=set_permissions&key=$GALAXY_API_KEY" --data '')"
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

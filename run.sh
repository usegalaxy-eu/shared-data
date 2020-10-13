#!/bin/bash

setup_library() {
    server=$1
    key=$2
    lib_yaml=$3
    lib_id=$4

    setup-data-libraries -g "$server" -a "$key" -vvv --training --legacy -i "$lib_yaml" 2>&1 | grep --line-buffered -v DEBUG

    # Super noisy so we'll disable it.
    for dataset in $(curl --silent "${server}/api/libraries/${lib_id}/contents" | jq '.[] | select(.type == "file") | .id' -r); do
        echo -n "$dataset "
        for _ in $(seq 1 10); do
            echo -n '.'
            output="$(curl --silent "${server}/api/libraries/datasets/${dataset}/permissions?action=set_permissions&key=$key" --data '')"
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
for line in $(cat secrets.json | jq -c '.[]'); do
    email=$(echo "$line" | jq -r '.email');
    key=$(echo "$line" | jq -r '.key');
    url=$(echo "$line" | jq -r '.url');
    for lib_yaml in $(echo "$line" | jq -r '.libs | keys[]'); do
        lib_id=$(echo "$line" | jq -r ".libs | .\"$lib_yaml\"");
        echo "Processing $lib_yaml for $url"
        setup_library "$url" "$key" "$lib_yaml" "$lib_id"
    done
done

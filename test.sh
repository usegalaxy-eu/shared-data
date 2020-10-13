#!/bin/bash
ec=0

IFS=$'\n';
for line in $(jq -c '.[]' < servers.json ); do
    id=$(echo "$line" | jq -r '.id');
    key=$(jq ".$id" -r < secrets.json);
    url=$(echo "$line" | jq -r '.url');

    for lib_yaml in $(echo "$line" | jq -r '.libs | keys[]'); do
        lib_id=$(echo "$line" | jq -r ".libs | .\"$lib_yaml\"");
        echo "# Checking $lib_id on $url";
        output="$(curl --silent "$url/api/libraries/$lib_id?key=$key")"

        lib_name="$(echo "$output" | jq .name -r)"
        lib_description="$(echo "$output" | jq .description -r)"
        lib_can_user_add="$(echo "$output" | jq .can_user_add -r)"

        if [ "$lib_yaml" = "GTN.yaml" ]; then
            if [ "$lib_name" != "GTN - Material" ]; then
                echo "ERROR: name is not correct ($lib_name != GTN - Material)"
                ec=1
            fi

            if [ "$lib_description" != "Galaxy Training Network Material" ]; then
                echo "ERROR: description is not correct ($lib_description != Galaxy Training Network Material)"
                ec=1
            fi
        fi

        if [ "$lib_can_user_add" != "true" ]; then
            echo "ERROR: user cannot add items to this library"
            ec=1
        fi
    done;
done;

exit $ec

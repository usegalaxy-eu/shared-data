#!/bin/bash
ec=0

IFS=$'\n';
for x in $(cat secrets.json | jq 'to_entries[] | "\(.key) \(.value.key) \(.value.email) \(.value.url) \(.value.lib)"' -r); do
	IFS=' ';
	read -a arr < <(echo $x)

	key=${arr[0]}
	api=${arr[1]}
	url=${arr[3]}
	lib=${arr[4]}

	echo "# Checking $key "

	output="$(curl --silent "$url/api/libraries/$lib/contents?key=$api" | jq '.[] | .name' | sort | uniq -c | grep -v '^\s*1 ')"
	lines=$(echo "$output" | wc -l)
	if (( lines > 0 )); then
		echo "	Error! Duplicates!"
		ec=1
		echo "$output"
	fi
done;

exit $ec

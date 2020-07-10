ec=0

IFS=$'\n';
for x in $(cat secrets.json | jq 'to_entries[] | "\(.key) \(.value.key) \(.value.email) \(.value.url) \(.value.lib)"' -r); do
	IFS=' ';
	read -a arr < <(echo $x)

	key=${arr[0]}
	api=${arr[1]}
	email=${arr[2]}
	url=${arr[3]}
	lib=${arr[4]}

	echo "# Checking $key "
	output="$(curl --silent "$url/api/libraries/$lib?key=$api")"

	lib_name="$(echo "$output" | jq .name -r)"
	lib_description="$(echo "$output" | jq .description -r)"
	lib_can_user_add="$(echo "$output" | jq .can_user_add -r)"

	if [[ "$lib_name" != "GTN - Material" ]]; then
		echo "ERROR: name is not correct ($lib_name != GTN - Material)"
		ec=1
	fi

	if [[ "$lib_description" != "Galaxy Training Network Material" ]]; then
		echo "ERROR: description is not correct ($lib_description != Galaxy Training Network Material)"
		ec=1
	fi

	if [[ "$lib_can_user_add" != "true" ]]; then
		echo "ERROR: user cannot add items to this library"
		ec=1
	fi

done;

exit $ec

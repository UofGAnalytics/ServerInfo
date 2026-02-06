#!/bin/bash
# Student-written helper script which uses "command" to check whether a command exists on each of the Euclids.
# Use at own risk, and always be careful not to cause any disruption to other users or access machines which you do not have permission to use.
# Specify --pip to check Python libraries instead of installed applications.

UNRESTRICTED_SERVERS="01 02 04 05 10 18 19 21 23 25 26 27 28 29 30"
RESTRICTED_SERVERS="03 06 07 08 09 12 17 22 24 32 35 36 37 "
SLURM_SERVERS="13 14 15 16 20 31 33"
RETIRED_SERVERS="11 34"

SERVERS=$UNRESTRICTED_SERVERS

cmdToCheck=$1

function cleanup {
	echo ""
}
trap cleanup EXIT

if [[ -z $cmdToCheck ]]; then
	echo "No command to check installation status specified, exiting."
	echo "Usage: ./check_installed.sh <command to check>"
	exit
fi

while true; do
    read -p "Check whether command '$cmdToCheck' exists on the euclid servers? Y/n " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Y/n.";;
    esac
done

# Run command & save output to temp directory
tmpdir=$(mktemp -d)
if [[ $* == *--pip* ]]; then
	cmd="pip list | grep '$cmdToCheck '"
else
	cmd="command -v $cmdToCheck" # Command to run on each euclid
fi
for euclid in $SERVERS; do
	echo $(if out=$(ssh "euclid-$euclid" -q -o RemoteCommand="$cmd" 2>&1); then
		echo "$out"
	else
		echo "Not installed"
	fi
	) > $tmpdir/euclid-$euclid &
done

# Display outputs:
n_servers=$(echo $SERVERS | wc --words)
while :; do
	done_count=0
	for euclid in $SERVERS; do
		if [[ -f "$tmpdir/euclid-$euclid" ]]; then
			printf "euclid-$euclid: %s\n" "$(tr '\n' ' ' < $tmpdir/euclid-$euclid)"
			((done_count++))
		else
			printf "euclid-$euclid:\n"
		fi
	done
	
	# Break if all servers have responded
	((done_count == n_servers)) && break
	
	# Move cursor back to top
	printf "\033[${n_servers}A"

	# Wait before re-checking
	sleep 0.2
done

rm -r "$tmpdir"

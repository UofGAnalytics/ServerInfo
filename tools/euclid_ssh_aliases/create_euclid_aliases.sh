#!/bin/bash

USAGE=$(cat <<-END
Usage: create_euclid_aliases [options]
Options:
    -s Specify server_types to include aliases for, where server_types must be one of:
        unrestricted: Add ssh aliases for all Euclid servers without a restriction on their use. (default)
        all_noslurm: Add ssh aliases for all Euclid servers, unrestricted and restricted, except SLURM nodes.
        all: Add ssh aliases for all Euclid servers.
    -c Path to SSH config file. Defaults to ~/.ssh/config
    -u Euclid server username. Defaults to system username.
    -h Display this help menu.
END
)

UNRESTRICTED_SERVERS="01 02 04 05 10 18 19 21 23 25 26 27 28 29 30"
RESTRICTED_SERVERS="03 06 07 08 09 12 17 22 24 32 35 36 37 "
SLURM_SERVERS="13 14 15 16 20 31 33"
RETIRED_SERVERS="11 34"

SERVERS=$UNRESTRICTED_SERVERS
SSH_CONFIG="~/.ssh/config"

# Try to extract Windows username (if in WSL), otherwise use system username.
if command -v whoami.exe >/dev/null 2>&1; then
	WINDOWS_USERNAME=$(whoami.exe | tr -d '\r')
	EUCLID_USERNAME="${WINDOWS_USERNAME##*\\}"
else
	EUCLID_USERNAME="$(whoami)"
fi

while getopts "s:h:c:u:" OPTION; do
	case $OPTION in
		s) # Which servers to include aliases for
			case $OPTARG in
				unrestricted)
					SERVERS=$UNRESTRICTED_SERVERS
					;;
				all_noslurm)
					SERVERS="$UNRESTRICTED_SERVERS $RESTRICTED_SERVERS"
					;;
				all)
					SERVERS="$UNRESTRICTED_SERVERS $RESTRICTED_SERVERS $SLURM_SERVERS"
					;;
				*)
					echo "Unknown server_type '$OPTARG', expected one of 'unrestricted', 'all_noslurm', 'all'."
					echo "$USAGE"
					exit
			esac
			;;
		c)
			SSH_CONFIG="$OPTARG"
			;;
		u)
			EUCLID_USERNAME="$OPTARG"
			;;
		h)
			echo "$USAGE"
			exit
			;;
		*)
			echo "$USAGE"
			exit
	esac
done

# Expand server ids to server names (e.g., 01 -> euclid-01) and sort.
SERVER_NAMES="slurmctl" 
SERVER_NAMES+=$(printf " euclid-%s" $(printf "%s\n" $SERVERS | sort))

eval SSH_CONFIG="$SSH_CONFIG" # Expand any ~ characters in path

# Prompt user for confirmation
echo "Adding aliases for Euclids: $SERVER_NAMES"
while true; do
    read -p "Do you wish to add SSH aliases to '$SSH_CONFIG' with Euclid username '$EUCLID_USERNAME'? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Save backup if file already exists, otherwise create new empty config file
if [ -f $SSH_CONFIG ]; then
	echo "Saving current config file to $SSH_CONFIG.backup":
	cp $SSH_CONFIG $SSH_CONFIG.backup
else
	> $SSH_CONFIG # Create empty config file
fi

for server in $SERVER_NAMES; do
	if grep -qw $server $SSH_CONFIG; then
		echo "$server already present in config, skipping..."
		continue
	fi
	echo -e "Host $server\n\tHostName $server.maths.gla.ac.uk\n\tUser $EUCLID_USERNAME" >> $SSH_CONFIG
done

echo "SSH aliases created successfully and saved to $SSH_CONFIG."

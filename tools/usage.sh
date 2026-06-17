#!/bin/bash
# Usage: usage.sh [euclid ids to check usage of]
# Student-written helper script to check the live CPU/Memory/GPU utilisation of the Euclid servers.
# Use at own risk, and always be careful not to cause any disruption to other users or access machines which you do not have permission to use.

UNRESTRICTED_SERVERS="01 02 04 05 10 18 19 21 23 25 26 27 28 29 30"
RESTRICTED_SERVERS="03 06 07 08 09 12 17 22 24 32 35 36 37 "
SLURM_SERVERS="13 14 15 16 20 31 33"
RETIRED_SERVERS="11 34"

SERVERS=$UNRESTRICTED_SERVERS

COLOUR_THRESHOLDS=(40 75 95)

# If any arguments given, set SERVERS to the input arguments
if [[ $# > 0 ]]; then
	SERVERS="$@"
fi

# Run command & save output to temp directory
tmpdir=$(mktemp -d)
run_cmd(){
	ssh "euclid-$euclid" -q -o RemoteCommand="$1"
}
for euclid in $SERVERS; do
	run_cmd "top -bn 5 -d 0.1 -E M" | grep -e '^%Cpu(s)\s*:' -e '^MiB Mem\s*:' | tail -n 2 > $tmpdir/euclid-$euclid-cpu-mem &
	run_cmd "lscpu" > $tmpdir/euclid-$euclid-lscpu &
	run_cmd "if nvidia-smi &>/dev/null; then nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits; else echo '-1'; fi" > $tmpdir/euclid-$euclid-gpu & # Saves each GPU percentage to a newline
done

# Set colour of percentages:
colour(){
	if (( $(echo "$1 < 0" | bc -l) )); then
		echo $(tput setaf sgr0) # Default
	elif (( $(echo "$1 < ${COLOUR_THRESHOLDS[0]}" | bc -l) )); then
		echo $(tput setaf 2) # Green
	elif (( $(echo "$1 < ${COLOUR_THRESHOLDS[1]}" | bc -l) )); then
		echo $(tput setaf 184) # Yellow
	elif (( $(echo "$1 < ${COLOUR_THRESHOLDS[2]}" | bc -l) )); then
		echo $(tput setaf 3) # Orange-Yellow
	elif (( $(echo "$1 <= 100" | bc -l) )); then
		echo $(tput setaf 1) # Red
	else
		echo $(tput setaf sgr0) # Default
	fi
}

# Display outputs:
n_servers=$(echo $SERVERS | wc --words)
echo "Total CPU Usage; Total Mem Usage; Physical(Logical) Cores; Total Mem; GPU Utilisation per GPU"
while :; do
	read -p letter &
	done_count=0
	for euclid in $SERVERS; do
		if [[ -s "$tmpdir/euclid-$euclid-cpu-mem" && -s "$tmpdir/euclid-$euclid-lscpu" && -s "$tmpdir/euclid-$euclid-gpu" ]]; then
			cpu_usage=$(cat $tmpdir/euclid-$euclid-cpu-mem | grep -e '^%Cpu(s)\s*:' | awk -F'[, ]+' '{print $2+$4+$6}')
			mem_usage=$(cat $tmpdir/euclid-$euclid-cpu-mem | grep -e '^MiB Mem\s*:' | awk -F'[, ]+' '{print $8*100/$4}')
			mem_size=$(cat $tmpdir/euclid-$euclid-cpu-mem | grep -e '^MiB Mem\s*:' | awk -F'[, ]+' '{print $4/1024}')
			cores=$(cat $tmpdir/euclid-$euclid-lscpu | grep -e '^Core(s) per socket\s*:' -e 'Socket(s)\s*:' | paste -s | awk '{print $4*$6}')
			threads=$(cat $tmpdir/euclid-$euclid-lscpu | grep '^CPU(s)\s*:' | awk '{print $2}')
			NORMAL=$(tput setaf sgr0) # Normal colour
			gpu_file=$(cat $tmpdir/euclid-$euclid-gpu)
			gpu_string=$(if [[ $gpu_file == "-1" || $gpu_file == *failed* ]]; then echo ""; else printf "   "; for usage in $gpu_file; do printf "$(colour $usage)$usage%%$NORMAL, "; done; printf "\b\b GPU"; fi)
			printf "euclid-$euclid: $(colour $cpu_usage)%5.1f%%$NORMAL CPU $(colour $mem_usage)%5.1f%%$NORMAL Mem   %-3d(%-3d) Cores %4.0f GiB%s\n" $cpu_usage $mem_usage $cores $threads $mem_size "$gpu_string"
			((done_count++))
		else
			printf "euclid-$euclid:\n"
		fi
	done
	
	# Break if all servers have responded
	((done_count == n_servers)) && break
	
	# Detect escape keypress	
	read -t 0.01 -N 1 input
    	if [[ $input = "q" ]] || [[ $input = "Q" ]]; then
		break
	fi
	
	# Move cursor back to top
	printf "\033[${n_servers}A"

	# Wait before re-checking
	sleep 0.5
done

rm -r "$tmpdir"

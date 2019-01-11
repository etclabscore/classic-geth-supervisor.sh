#!/usr/bin/env bash

# Either pass a first arg as the path to a geth logfile containing only grep'd BLOCKCHAIN.WRITE.BLOCK lines, or use my default sandbox file which doesn't exist on your computer.
F_blockchain_write_block="${1:-"$HOME/.mlog-monitor-data/blockchain.write.block"}"

# Set the margin of 'normal' variation between 'latest' and 'aggregate' etherbase percent share.
# In percent (absolute +/-).
M_margin_aggregate_diff=${2:-5} 

wcl=$(cat $F_blockchain_write_block | wc -l)
wcl_uniq=$(cat $F_blockchain_write_block | cut -d' ' -f3 | sort | uniq | wc -l)

calc(){ awk "BEGIN { print "$*"*100 }"; }

rank_uniq_etherbases(){
	f=$(tempfile)
	cut -d' ' -f3 |
		sort | uniq -c |
		while read n addr; do 
			echo $(printf '%02.f' "$(calc $n/$1)" && printf ' %s\n' "$addr") >> "$f"
		done
	cat "$f" | sort -r
	rm "$f"
}

send_alert_email(){
	# TODO: set me up
	# echo "$1" | mail -s '[etc.alert][etherbase rank]' isaac.ardis@gmail.com # et al, hopefully
	echo "$1" > /dev/null
}

aggregate=$(cat "$F_blockchain_write_block" | rank_uniq_etherbases $wcl)
latest=$(tail -n100 "$F_blockchain_write_block" | rank_uniq_etherbases 100)

# this a vanity fn that adds a symbolic delta prefix to numbers
prefix_delta(){
	if [[ $1 -eq 0 ]]; then
		echo ":$1"
	elif [[ $1 -gt 0 ]]; then
		echo "+$1"
	elif [[ $1 != -* ]]; then
		echo "-$1"
	else 
		echo "$1"
	fi
}

echo "last $wcl blocks (eb.uniq=$wcl_uniq)                      last 100 blocks (eb.uniq=$(tail -n100 $F_blockchain_write_block | cut -d' ' -f3 | sort | uniq | wc -l))"
echo
while read agg_percent agg_address; do
	l="$agg_percent $agg_address"
	if ! grep -q "$agg_address" <<< "$latest"; then
		# address has not mined a block in latest batch
		echo "$l" > /dev/null # noop
	else
		latest_line=$(grep "$agg_address" <<< "$latest")
		percent=$(echo "$latest_line" | cut -d' ' -f1)
		address=$(echo "$latest_line" | cut -d' ' -f2)

		l="$l  |  $percent" # don't also echo address, redundant

		addr_at_agg_percent=${agg_percent##0}
		addr_at_latest_percent=${percent##0}

		diff=$((addr_at_latest_percent - addr_at_agg_percent))

		if [[ $diff -lt $((-1 * M_margin_aggregate_diff)) ]]; then
			l="$l $diff [low]"
			send_alert_email "$l"

		elif [[ $diff -gt $((M_margin_aggregate_diff)) ]]; then
			l="$l +$diff [high]"
			send_alert_email "$l"

		else
			l="$l $(prefix_delta $diff)"
		fi
	fi
	echo "$l"
done <<< "$aggregate"


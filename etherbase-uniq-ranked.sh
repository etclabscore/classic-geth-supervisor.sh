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

echo "last blocks: $wcl, uniq etherbases: $wcl_uniq"
aggregate=$(cat "$F_blockchain_write_block" | rank_uniq_etherbases $wcl)
echo "$aggregate"

echo "last blocks: 100, uniq etherbases: $(tail -n100 $F_blockchain_write_block | cut -d' ' -f3 | sort | uniq | wc -l)"
latest=$(tail -n100 "$F_blockchain_write_block" | rank_uniq_etherbases 100)

while read percent address; do
	line_at_agg=$(grep "$address" <<< "$aggregate")

	addr_at_agg_percent=$(echo $line_at_agg | cut -d' ' -f1)

	# strip left-padded 0's
	addr_at_agg_percent=${addr_at_agg_percent##0} 
	percent=${percent##0}

	diff=$((percent - addr_at_agg_percent))

	l="$percent $address"

	if [[ $diff -lt $((-1 * M_margin_aggregate_diff)) ]]; then
		# alert, dropping
		l="$l [dropping] $diff"
	elif [[ $diff -gt $((M_margin_aggregate_diff)) ]]; then
		# alert, rising
		l="$l [rising] +$diff"
	else
		l="$l [normal] $diff"
	fi
	echo "$l"

done <<< "$latest"

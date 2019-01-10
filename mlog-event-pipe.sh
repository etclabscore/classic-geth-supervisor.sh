#!/usr/bin/env bash

use=$(cat <<EOF
Use: 
	tail -F geth.log | thisscript.sh

EOF
)

if [[ $1 == *-h || $1 == *help ]]; then
	echo "$use" && exit 1
fi


D_mlog_monitor_data=${1:-"$HOME/.mlog-monitor-data"}
data_max_length=${2:-5000}

mkdir -p "$D_mlog_monitor_data"

truncate_to_file_max(){
	tail -n "$data_max_length" "$1" > "$1.tmp"
	cat "$1.tmp" > "$f"
}

while read t line; do
	if grep -q --line-buffered 'BLOCKCHAIN WRITE BLOCK' <<< "$line"; then
		# #### BLOCKCHAIN WRITE BLOCK
		# Called when a single block is written to the chain database.
		# A STATUS of NONE means it was written _without_ any abnormal chain event, such as a split.

		# __Key value__:
		# ```
		# 2019/01/09 21:07:31 [blockchain] BLOCKCHAIN WRITE BLOCK session=dRdZ write.status=$STRING write.error=$STRING_OR_NULL block.number=$BIGINT block.hash=$STRING block.size=$INT64 block.transactions_count=$INT block.gas_used=$BIGINT block.coinbase=$STRING block.time=$BIGINT block.difficulty=$BIGINT block.uncles=$INT block.received_at=$BIGINT block.diff_parent_time=$BIGINT
		# ```

		f="$D_mlog_monitor_data/blockchain.write.block"

		bwstat=$(echo "$line" | sed -rn 's/.*write\.status=([A-Z]+).*/\1/p')
		addr=$(echo "$line" | sed -rn 's/.*block\.coinbase=([x0123456789abcdef]+).*/\1/p')

		# eg. 2019/01/09T21:07:31Z CANON 0x923fa3fa388812349bf 
		echo "$t $bwstat $addr -> $f" 
		echo "$t $bwstat $addr" >> "$f"

		truncate_to_file_max "$f"

	elif grep -q --line-buffered 'BLOCKCHAIN REORG BLOCKS' <<< "$line"; then
		# #### BLOCKCHAIN REORG BLOCKS
		# Called when a chain split is detected and a subset of blocks are reoganized.

		# __Key value__:
		# ```
		# 2019/01/09 21:08:33 [blockchain] BLOCKCHAIN REORG BLOCKS session=UZfO reorg.last_common_hash=$STRING reorg.split_number=$BIGINT blocks.length=$INT blocks.old_start_hash=$STRING blocks.new_start_hash=$STRING
		# ```

		f="$D_mlog_monitor_data/blockchain.reorg.blocks"
		blocks_len=$(echo "$line" | sed -rn 's/.*blocks\.length=([0-9]+).*/\1/p')
		blocks_last_common_hash=$(echo "$line" | sed -rn 's/.*reorg.last_common_hash=([x0123456789abcdef]+).*/\1/p')
			
		echo "$t $blocks_len $blocks_last_common_hash -> $f" 
		echo "$t $blocks_len $blocks_last_common_hash" >> "$f"

		truncate_to_file_max "$f"

	# Add your own here...
	
	fi
done

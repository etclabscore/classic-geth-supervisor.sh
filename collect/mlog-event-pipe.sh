#!/usr/bin/env bash

use=$(cat <<EOF
Use:

	$ tail -F geth.log | thisscript.sh [analyzerscript.sh] [alertingscript.sh]

      If an 'analyzerscript.sh' is provided, it will be run after each new interesting log line.
      If the analyzer script is subsequently passed an 'alertingscript.sh', then the analyzer
      script will call that script if it yields alert-worthy results.

      Since the analyzer script uses a static data store that's fed by this script, it doesn't get
      any arguments.

      The alerting script will be passed two arguments, where 1=[red|orange|yellow] 2=[body]

EOF
)

if [[ $1 == *-h || $1 == *help ]]; then
	echo "$use" && exit 1
fi

analyzerscript="$1"
if [[ -x "$1" ]]; then
    shift 1;
else
    echo "WARNING:"
    echo "No analyzer script provided."
    echo
    echo "That might be ok. You can run analyzer scripts separately, too."
    echo "Like from a cron, or whatever."
fi

D_mlog_monitor_data=${CGS_DATADIR:-"$HOME/.classic-geth-supervisor"}
data_max_length=${CGS_LINEMAX:-5000}

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
    # eg.
    # 2019-01-11T14:35:37Z [blockchain] BLOCKCHAIN WRITE BLOCK session=WRto write.status=CANON write.error=<nil> block.number=7282644 block.hash=0x44a12267fd59da128606af8372f023badb1d749757f3751108cdb53a198bc0b6 block.size=1523 block.transactions_count=3 block.gas_used=316401 block.coinbase=0xdf7d7e053933b5cc24372f878c90e62dadad5d42 block.time=1547217321 block.difficulty=121003239543687 block.uncles=1 block.received_at="2019-01-11 08:35:37.590462876 -0600 CST m=+74178.480035813" block.diff_parent_time=17

		f="$D_mlog_monitor_data/blockchain.write.block"

		bwstat=$(echo "$line" | sed -rn 's/.*write\.status=([A-Z]+).*/\1/p')
		addr=$(echo "$line" | sed -rn 's/.*block\.coinbase=([x0123456789abcdef]+).*/\1/p')
    delta_parent_time=$(echo "$line" | sed -rn 's/.*block\.diff_parent_time=([0-9]+).*/\1/p')
    uncles=$(echo "$line" | sed -rn 's/.*block\.uncles=([0-9]+).*/\1/p')

		# eg. 2019/01/09T21:07:31Z CANON 0x923fa3fa388812349bf
		echo "$t $bwstat $addr $delta_parent_time $uncles -> $f"
		echo "$t $bwstat $addr $delta_parent_time $uncles" >> "$f"

		truncate_to_file_max "$f"

    if [[ -x "$analyzerscript" ]]; then
        source "$analyzerscript"
    fi

	elif grep -q --line-buffered 'BLOCKCHAIN REORG BLOCKS' <<< "$line"; then
		# #### BLOCKCHAIN REORG BLOCKS
		# Called when a chain split is detected and a subset of blocks are reoganized.

		# __Key value__:
		# ```
		# 2019/01/09 21:08:33 [blockchain] BLOCKCHAIN REORG BLOCKS session=UZfO reorg.last_common_hash=$STRING reorg.split_number=$BIGINT blocks.length=$INT blocks.old_start_hash=$STRING blocks.new_start_hash=$STRING
		# ```

		f="$D_mlog_monitor_data/blockchain.reorg.blocks"
		blocks_len=$(echo "$line" | sed -rn 's/.*blocks\.length=([0-9]+).*/\1/p')
		blocks_last_common_hash=$(echo "$line" | sed -rn 's/.*reorg\.last_common_hash=([x0123456789abcdef]+).*/\1/p')

		echo "$t $blocks_len $blocks_last_common_hash -> $f"
		echo "$t $blocks_len $blocks_last_common_hash" >> "$f"

		truncate_to_file_max "$f"

    if [[ -x "$analyzerscript" ]]; then
        source "$analyzerscript"
    fi

	# Add your own line parsers here...

	fi
done

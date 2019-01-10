#!/usr/bin/env bash

# assume stdin == tail'd mlog file
#
# In order to install multiple greps against same log file, either redirect the tail of the original file to multiple dev/fd paths, or start one process for each grepping script.
# eg. 
#
#  2019-01-09T19:00:56Z [blockchain] BLOCKCHAIN REORG BLOCKS session=WRto reorg.last_common_hash=0x6e99ebb9ee46434c1b1cbcadc342792ad9d8e42e755bf767b978f1917e5dc2a9 reorg.split_number=7271508 blocks.length=2 blocks.old_start_hash=0xaa23a4c5b2743eb5de5d75c26b10fac0708a2ddbeba3bed4ef2b75a91dda5dd1 blocks.new_start_hash=0x4f9d9205ce92ff48bab0e75c77ae578f0524913ed0d412bf6bb35ba345520c6d

# 

# TODO; figure out output schema wants
# output:
# DATE REORG 

# #### BLOCKCHAIN WRITE BLOCK
# Called when a single block is written to the chain database.
# A STATUS of NONE means it was written _without_ any abnormal chain event, such as a split.
# 
# __Key value__:
# ```
# 2019/01/09 17:15:31 [blockchain] BLOCKCHAIN WRITE BLOCK session=FzGt write.status=$STRING write.error=$STRING_OR_NULL block.number=$BIGINT block.hash=$STRING block.size=$INT64 block.transactions_count=$INT block.gas_used=$BIGINT block.coinbase=$STRING block.time=$BIGINT block.difficulty=$BIGINT block.uncles=$INT block.received_at=$BIGINT block.diff_parent_time=$BIGINT
# ```

F_blockchain_write_etherbase="$HOME/sandbox/blockchain.write.etherbase"

while read t line; do
	if grep -q --line-buffered 'BLOCKCHAIN WRITE BLOCK' <<< "$line"; then
		bwstat=$(echo "$line" | sed -rn 's/.*write\.status=([A-Z]+).*/\1/p')
		addr=$(echo "$line" | sed -rn 's/.*block\.coinbase=([x0123456789abcdef]+).*/\1/p')

		echo "$t $bwstat $addr -> $F_blockchain_write_etherbase" 
		echo "$t $bwstat $addr" >> "$F_blockchain_write_etherbase"

		tail -n 5000 "$F_blockchain_write_etherbase" > "$F_blockchain_write_etherbase.tmp"
		cat "$F_blockchain_write_etherbase.tmp" > "$F_blockchain_write_etherbase"
	fi
done

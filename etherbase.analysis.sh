#!/usr/bin/env bash

F_blockchain_write_etherbase="${1:-"$HOME/sandbox/blockchain.write.etherbase"}"

wcl=$(cat $F_blockchain_write_etherbase | wc -l)
wcl_uniq=$(cat $F_blockchain_write_etherbase | cut -d' ' -f3 | sort | uniq | wc -l)

calc(){ awk "BEGIN { print "$*"*100 }"; }

rank_uniq_etherbases(){
	> /tmp/blockchain.write.etherbase.tmp
	cut -d' ' -f3 |
		sort | uniq -c |
		while read n addr; do 
			echo $(printf '%02.f' "$(calc $n/$wcl)" && printf ' %s\n' "$addr") >> /tmp/blockchain.write.etherbase.tmp
		done
	cat /tmp/blockchain.write.etherbase.tmp | sort -r
}

echo "last blocks: $wcl, uniq etherbases: $wcl_uniq"
> /tmp/blockchain.write.etherbase.tmp
cat "$F_blockchain_write_etherbase" |
       	cut -d' ' -f3 |
       	sort | uniq -c |
	while read n addr; do 
		echo $(printf '%02.f' "$(calc $n/$wcl)" && printf ' %s\n' "$addr") >> /tmp/blockchain.write.etherbase.tmp
       	done
cat /tmp/blockchain.write.etherbase.tmp | sort -r

echo "last blocks: 100, uniq etherbases: $(tail -n100 $F_blockchain_write_etherbase | cut -d' ' -f3 | sort | uniq | wc -l)"
> /tmp/blockchain.write.etherbase.tmp
tail -n100 "$F_blockchain_write_etherbase" |
       	cut -d' ' -f3 |
       	sort | uniq -c |
	while read n addr; do 
		echo $(printf '%02.f' "$(calc $n/$wcl)" && printf ' %s\n' "$addr") >> /tmp/blockchain.write.etherbase.tmp
       	done
cat /tmp/blockchain.write.etherbase.tmp | sort -r

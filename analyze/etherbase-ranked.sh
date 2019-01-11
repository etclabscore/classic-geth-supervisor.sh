#!/usr/bin/env bash

# Either pass a first arg as the path to a geth logfile containing only grep'd BLOCKCHAIN.WRITE.BLOCK lines, or use my default sandbox file which doesn't exist on your computer.
F_blockchain_write_block="${1:-"$HOME/.classic-geth-supervisor/blockchain.write.block"}"

# Set the margin of 'normal' variation between 'latest' and 'aggregate' etherbase percent share.
# In percent (absolute +/-).
M_margin_aggregate_diff=${2:-5}

wcl=$(cat $F_blockchain_write_block | wc -l)
wcl_uniq=$(cat $F_blockchain_write_block | cut -d' ' -f3 | sort | uniq | wc -l)

# Globals for alerting
alert_lev=0
alert_msg=""

# calc is a simple calculator that can handle floating points
calc(){ awk "BEGIN { print "$*"*100 }"; }

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

rank_uniq_etherbases(){
	f=$(tempfile)
	cut -d' ' -f3 |
	    sort |
      uniq -c |
      # reading here the output of uniq -c, which is sum line occurences
	    while read n addr;  do
		      echo $(printf '%02.f ' "$(calc $n/$1)" && printf '%d ' $n && printf '%s\n' "$addr") >> "$f"
	    done
	cat "$f" | sort -r
	rm "$f"
}

do_alert(){
   al=$1
   shift 1;
   msg="$@"
   >&2 echo " > debug.alerting: lev=$al alert=
---
$msg
---"

	 # TODO: set me up
   # say "ruh roh, $1 $2"
	 # echo "$2" | mail -s "[etc.$1-alert][etherbase share]" isaac.ardis@gmail.com # et al, hopefully
}

aggregate=$(cat "$F_blockchain_write_block" | rank_uniq_etherbases $wcl)
latest=$(tail -n100 "$F_blockchain_write_block" | rank_uniq_etherbases 100)

fn_greater_of(){
    if [[ $2 -gt $1 ]]; then echo $2; else echo $1; fi
}

fn_share_print(){
  local agg_percent=$1
  local agg_address=$2

 	if ! grep -q "$agg_address" <<< "$latest"; then
		# address has not mined a block in latest batch
		echo "$l" > /dev/null # noop
	else
		latest_line=$(grep "$agg_address" <<< "$latest")
		percent=$(echo "$latest_line" | cut -d' ' -f1)

		l="|  $percent" # don't also echo address, redundant

    # handle freq diff warnings
		addr_at_agg_percent=${agg_percent##0}
		addr_at_latest_percent=${percent##0}

		diff=$((addr_at_latest_percent - addr_at_agg_percent))

		if [[ $diff -lt $((-1 * M_margin_aggregate_diff)) ]]; then
			l="$l $diff [low]"

		elif [[ $diff -gt $((M_margin_aggregate_diff)) ]]; then
			l="$l +$diff [high]"

		else
			l="$l $(prefix_delta $diff)"
		fi
    echo -n "$l"
	fi
}

fn_share_analysis(){
  local agg_percent=$1
  local agg_address=$2

  local a_lev=0
  local a_msg=""

 	if ! grep -q "$agg_address" <<< "$latest"; then
		# address has not mined a block in latest batch
		echo "$l" > /dev/null # noop
	else
		latest_line=$(grep "$agg_address" <<< "$latest")
		percent=$(echo "$latest_line" | cut -d' ' -f1)

    # handle freq diff warnings
		addr_at_agg_percent=${agg_percent##0}
		addr_at_latest_percent=${percent##0}

		diff=$((addr_at_latest_percent - addr_at_agg_percent))

		if [[ $diff -lt $((-1 * M_margin_aggregate_diff)) ]]; then
			a_lev=$(fn_greater_of $a_lev 1)
      a_msg+="* etherbase share decreased significantly lately: $agg_percent $agg_address $l"

		elif [[ $diff -gt $((M_margin_aggregate_diff)) ]]; then
			a_lev=$(fn_greater_of $a_lev 1)
      a_msg+="* etherbase share increased significantly lately: $agg_percent $agg_address $l"
		fi

    # handle total share warning
    if [[ $addr_at_latest_percent -gt $((50-M_margin_aggregate_diff)) ]]; then
			  a_lev=$(fn_greater_of $a_lev 3)
        a_msg+="* total share exceeds $((50-2*M_margin_aggregate_diff))% $agg_percent $agg_address $l"
    elif [[ $addr_at_latest_percent -gt $((50-2*M_margin_aggregate_diff)) ]]; then
			  a_lev=$(fn_greater_of $a_lev 1)
        a_msg+="* total share exceeds $((50-2*M_margin_aggregate_diff))% $agg_percent $agg_address $l"
    fi
    echo "$a_msg"
	fi
  return $a_lev
}

# NOTE: avg is not necessarily a good indicator.
# A selfish miner could disguise 'fast batches' of wins with a few exceptionally long waits.
# I'm not sure of the economics or math of this though, 'cuz obviously the wait would be expensive too.
# Just saying.
# What we really want is to see if their long tail delta graph has an apex closer to 0 than competitors.
fn_blocktime_agg_avg(){
    local percent=${1##0}
    # selfish mining is only theoretically viable above 25% share.
    if [[ $percent -lt 25 ]]; then
        echo ""
        return
    fi
    local addr=$2
    local addr_list="$(grep "$addr" "$F_blockchain_write_block")"
    local addr_list_len=$(wc -l <<< "$addr_list")
    if [[ $addr_list_len -lt 1 ]]; then
        echo ""
        return
    fi
    # sum blocktime deltas
    local sum=0
    local n=0
    while read _ _ _ dt _; do
        if [[ ! -z $dt ]]; then
            n=$((n+1))
            sum=$((sum+dt))
        fi
    done <<< "$addr_list"
    if [[ $n -gt 0 ]]; then
        avg_blocktime_delta=$((sum/n))
        echo $avg_blocktime_delta
    else
        echo ""
    fi
}

fn_check_latest_etherbase_variation(){
    local a_lev=0
    local a_msg=""
    if [[ $(wc -l <<< "$latest") -lt 6 ]]; then
        a_msg="* very few unique etherbases participating in last 100 blocks
"
        a_lev=3

    elif [[ $(wc -l <<< "$latest") -gt 25 ]]; then
        a_msg="* unusually high numbers of etherbases participating in last 100 blocks
"
        a_lev=2

    fi
    echo "$a_msg"
    return $a_lev
}

output=""

echo "last $wcl blocks (eb.uniq=$wcl_uniq)                        | last 100 blocks (eb.uniq=$(tail -n100 $F_blockchain_write_block | cut -d' ' -f3 | sort | uniq | wc -l))"
echo
while read agg_percent agg_count agg_address _ uncles; do
    l="$agg_percent $agg_count $agg_address"

    latest_line=$(grep "$agg_address" <<< "$latest")
    percent=$(echo "$latest_line" | cut -d' ' -f1)
    if [[ ${percent##0} -lt 1 ]]; then continue; fi

    l+="  $(fn_share_print $agg_percent $agg_address)"

    am="$(fn_share_analysis $agg_percent $agg_address)"
    if [[ ! -z $am ]]; then
        alert_msg+="$am
"
    fi
    alert_lev=$(fn_greater_of $? $alert_lev)

    delta_selfish_candidates=$(fn_blocktime_agg_avg $agg_percent $agg_address)
    if [[ ! -z $delta_selfish_candidates ]]; then
        l="$l [avg blocktime delta = $delta_selfish_candidates]"
        if [[ $delta_selfish_candidates -lt 12 ]]; then
            alert_lev=$(fn_greater_of $alert_lev 1)
            alert_msg+="* potential indicator for selfish mining (low avg blocktime deltas): $l
"
        fi
    fi

    echo "$l"
    output+="$l
"
done <<< "$aggregate"


if [[ $alert_lev -ne 0 ]]; then
    do_alert $alert_lev "$alert_msg" "$output"
else
    >&2 echo "alert_lev=$alert_lev"
fi

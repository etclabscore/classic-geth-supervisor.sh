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

while read line; do
	echo "$line" | grep --line-buffered REORG
done

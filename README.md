:warning: :hammer: WIP: These tools are at a "Proof of Concept" development level.

A rudimentary collection of bash scripts to collect and analyze blockchain client metrics, providing basic alerting mechanisms for anomalous events and situations.

These are intended to exercise bash's ubiquity, providing lightweight and portable alternatives to heavy-duty diagnostic stacks like Elasticsearch's ELK stack. The focus is on their ability to trigger rudimentary alerting systems, like email, based on rule-of-thumb heuristics for anomalous or flagged chain behavior. Their design intends to minimize specialized dependencies and focus on providing simple and generic text-based datasets and analytics.

With these limitations in mind, it's clear these tools are best _adjacent_ to, or at least well-informed-by, the dynamic, investigative, and visual diagnostics available through something like an ELK stack system.

Here's what's in the folders as-is (and I'm going to regret hardcoding a directory structure in the README...):

```sh
$ tree analyze collect 
analyze                 
└── etherbase-ranked.sh # This script analyzes the blockhain.write.block data extracted by collect/mlog-event-pipe.sh
                        # and produces an alert-ready analysis of etherbase frequency.
collect/
└── mlog-event-pipe.sh # This script grep's specific events from stdin,
                       # extracting notable data points, and storing those points 
                       # by default in $HOME/.classic-geth-supervisor/
0 directories, 2 files
```

The data directory will look something like this:

```sh
$ tree .classic-geth-supervisor/
.classic-geth-supervisor/
├── blockchain.reorg.blocks
├── blockchain.reorg.blocks.tmp
├── blockchain.write.block
└── blockchain.write.block.tmp

0 directories, 4 files
```


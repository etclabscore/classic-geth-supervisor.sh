:warning: :hammer: WIP: These tools are at a "Proof of Concept" development level.

A rudimentary collection of bash scripts to collect and analyze blockchain client metrics, providing basic alerting mechanisms for anomalous events and situations.

These are intended to exercise bash's ubiquity, providing lightweight and portable alternatives to heavy-duty diagnostic stacks like Elasticsearch's ELK stack. The focus is on their ability to trigger rudimentary alerting systems, like email, based on rule-of-thumb heuristics for anomalous or flagged chain behavior. Their design intends to minimize specialized dependencies and focus on providing simple and generic text-based datasets and analytics.

With these limitations in mind, it's clear these tools are best _adjacent_ to, or at least well-informed-by, the dynamic, investigative, and visual diagnostics available through something like an ELK stack system.

### Quick start

Look here: [the All together example](#all-together-example)

### Usage/API overview

These scripts are designed to be configurable, so you can add your alerting services, or use only bits and pieces of the few scripts provided to suit your fancy.

- [./collect/mlog-event-pipe.sh](./collect/mlog-event-pipe.sh) collects and stores interesting data points coming from geth's `mlog` log API. 

    Reads from STDIN. 
    Data is stored by default in `$HOME/.classic-geth-supervisor`. Upon matching an interesting new data point, it calls the analyzer, if provided.
  
    > - If you want to add your own log lines to watch for and collect and analyze different events, look here: [./blob/master/collect/mlog-event-pipe.sh#L97](./blob/master/collect/mlog-event-pipe.sh#L97)
    > - If you want to use `--mlog=[json|plain]` you'll need to write new regexes to parse the data points, look here: [./blob/master/collect/mlog-event-pipe.sh#L46-L61](./blob/master/collect/mlog-event-pipe.sh#L61)
  
    ```sh
    $ tail -F $HOME/.ethereum-classic/mainnet/mlogs/geth.log | classic-geth-supervisor.sh/collect/mlog-event-pipe.sh [analysis-script.sh]
    ```
  
- [./analyze/supervise.sh](./analyze/supervise.sh) analyzes the stored data, determining if there's anything alert-worthy.
    + Notably, it doesn't receive any data from the mlog collector. It just analyzes the persisted data.

    API:
    ```sh
    ./analyze/supervise.sh [-m=N] [./alert/robot-computer.sh] [./another-alert-script.sh] [./the-one-that-feeds-my-dog-on-red-alerts.sh] [...]
    ```
    API in plain english:

    + It accepts one flag, `-m`, determining the margin of deviating percent from average that should be considered alert-worthy for etherbase share, increasing, decreasing, or nearing 50%. 
      The value can be a number between 1-26, by default is 5.
    + It accepts _n_ arguments, where each is an executable alerting script. See below for the data they're receive and how they'll receive it.
    + It prints all `echo`s to `stderr`, since it's purpose in life is not to print things to the shell, but to provide given subsequent interfaces with data.
    
    ```sh
    $ tail -F $HOME/.ethereum-classic/mainnet/mlogs/geth.log | classic-geth-supervisor.sh/collect/mlog-event-pipe.sh \
      classic-geth-supervisor.sh/analyze/supervise.sh -m=6
    ```
  
- [./alert/robot-computer.sh](./alert/robot-computer.sh) is the exemplary alerting tool. 

    API:
    ```sh
    $ ./my-alert.sh [red|orange|yellow] [<"bahhhhhhhhhhhhhhhhhhh!!!!!!!!!!!!!!!">]
    ```

    API in plain english:

    Alerting scripts receive two arguments from the supervisor: `<alert_level>` (`[red|orange|yellow]`), and an arbitrary string `<alert_msg>`.
  
    ```sh
    $ tail -F $HOME/.ethereum-classic/mainnet/mlogs/geth.log | classic-geth-supervisor.sh/collect/mlog-event-pipe.sh \
      classic-geth-supervisor.sh/analyze/supervise.sh -m=6 \
      classic-geth-supervisor.sh/alert/robot-computer.sh
    ```

- [./env.sh](./env.sh) use this script to export vars that will override defaults.

:clap: 

#### All together example

Shell #1: Start geth with `--mlog=kv`.

```sh
$ geth --mlog=kv
```

Shell #2: Supervise.

```sh
$ tail -F $HOME/.ethereum-classic/mainnet/mlogs/geth.log | 
  classic-geth-supervisor.sh/collect/mlog-event-pipe.sh \ # Collect data points, trigger analysis.
  classic-geth-supervisor.sh/analyze/supervise.sh \       # Analyze the data, looking for alertable outcomes.
  classic-geth-supervisor.sh/alert/isaacemail.sh \        # An exemplary script that sends emails.
  $HOME/bin/tweet-etc-redalerts.sh                        # My other special alerting script that only cares about red alerts.
                                                          # ...NOTE: that you can provide any number of alert scripts as args to the supervisor.
```

### Data directory overview

The data directory will look something like the following.

```sh
$ tree .classic-geth-supervisor/
.classic-geth-supervisor/
├── blockchain.reorg.blocks
├── blockchain.reorg.blocks.tmp
├── blockchain.write.block
└── blockchain.write.block.tmp

0 directories, 4 files
```


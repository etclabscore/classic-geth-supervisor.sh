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
    ./analyze/supervise.sh [-m=N] [./alert/echo.sh] [./say.sh] [./the-one-that-feeds-my-dog-on-red-alerts.sh] [...]
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
  
- [./alert/echo.sh](./alert/echo.sh) is the exemplary alerting tool. 

    API:
    ```sh
    $ ./my-alert.sh [red|orange|yellow] [<"bahhhhhhhhhhhhhhhhhhh!!!!!!!!!!!!!!!">]
    ```

    API in plain english:

    Alerting scripts receive two arguments from the supervisor: `<alert_level>` (`[red|orange|yellow]`), and an arbitrary string `<alert_msg>`.
  
    ```sh
    $ tail -F $HOME/.ethereum-classic/mainnet/mlogs/geth.log | classic-geth-supervisor.sh/collect/mlog-event-pipe.sh \
      classic-geth-supervisor.sh/analyze/supervise.sh -m=6 \
      classic-geth-supervisor.sh/alert/echo.sh
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

### Alert level and message

Alert levels will be one of `red`, `orange`, or `yellow`.

The alert message will look like the following.

```txt
* etherbase total share exceeds 40% 0xdf7d7e053933b5cc24372f878c90e62dadad5d42 [41%]

---
0xdf7d7e053933b5cc24372f878c90e62dadad5d42 39% 0178  |  41% +2 [avg blocktime delta = 15]
0x9eab4b0fc468a7f5d46228bf5a76cb52370d068d 21% 0095  |  19% -2
0x0073cf1b9230cf3ee8cab1971b8dbef21ea7b595 07% 0030  |  05% -2
0x004730417cd2b1d19f6be2679906ded4fa8a64e2 06% 0027  |  05% -1
0x1c0fa194a9d3b44313dcd849f3c6be6ad270a0a4 06% 0026  |  04% -2
0x00e39b0dde4c80d23cda79a8b6690d9db014490b 03% 0014  |  04% +1
0xfe0ca4e9d8b83ff2d03ef4f35f0b5f754e81d1fd 03% 0012  |  02% -1
0xfe96c2235e805ce312cc830a41d3b10f26a69057 01% 0006  |  01% :0
0xf35074bbd0a9aee46f4ea137971feec024ab704e 01% 0005  |  04% +3
0xeda79f0735a56510876a497e1c105916666b0199 01% 0005  |  01% :0
0x2387f8db786d43528ffd3b0bd776e2ba39dd3832 01% 0005  |  02% +1
0xd3bfd58a31ddeb2fdd2bc212e38c41725bc93ccd 01% 0004  |  02% +1
```

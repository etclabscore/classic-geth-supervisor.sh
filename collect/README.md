Currently `mlog` is used because it provides easy grepping. Standard verbosity logs can be used instead with small adjustments to the `grep` and `sed` patterns.

To use, tail geth's default `mlog` symlink file.

```sh
$ tail -F $HOME/.ethereum-classic/mainnet/mlogs/geth.log | ~/dev/etc/classic-geth-supervisor.sh/mlog-event-pipe.sh
```

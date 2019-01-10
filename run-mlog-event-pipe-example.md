Show all uniq `etherbase`'s for blocks written, ranked by frequency.

```sh
$ tail -F geth.log | ~/sandbox/mlog-analysis-poc.sh/mlog-event-pipe.sh
```

The numbers on the left represent percent share of etherbase across n blocks, so `0xdf7d7e053933b5cc24372f878c90e62dadad5d42` has mined 32% of the last 530 blocks. The first section is in aggregate (thru the max 5000 line limit, which last 5000 blocks written), and the second does the same analysis, but only across the last 100 blocks. If an etherbase's share in the last 100 blocks varies from the aggregate "normal" share it gets, then the `[normal]` becomes `[rising]` or `[dropping]`.

See script for details.
```sh
$ ./etherbase-ranked.sh
last 530 blocks (eb.uniq=32)                      last 100 blocks (eb.uniq=16

32 0xdf7d7e053933b5cc24372f878c90e62dadad5d42  |  32 [normal] 0
21 0x9eab4b0fc468a7f5d46228bf5a76cb52370d068d  |  18 [normal] -3
17 0x58b3cabd0c5c777da2c1c4d4f7ecc8afe5674f20  |  27 [high] +10
11 0x1c0fa194a9d3b44313dcd849f3c6be6ad270a0a4  |  07 [normal] -4
02 0xd144e30a0571aaf0d0c050070ac435deba461fab
02 0xc91716199ccde49dc4fafaeb68925127ac80443f  |  01 [normal] -1
02 0x0073cf1b9230cf3ee8cab1971b8dbef21ea7b595  |  02 [normal] 0
01 0xfe96c2235e805ce312cc830a41d3b10f26a69057
01 0xfe0ca4e9d8b83ff2d03ef4f35f0b5f754e81d1fd
01 0xf35074bbd0a9aee46f4ea137971feec024ab704e
01 0xc6e8933f2ce9ea2432a24e2752641e38ce0aaf06  |  01 [normal] 0
01 0x904db9b94455fd4491cc83081785bf82de8a0306  |  01 [normal] 0
01 0x864b2dbc20d7fda9e07d653aed76e8400796139e
01 0x50d2eedb5d786de86a6cd0d304ed480e4607652a  |  02 [normal] 1
01 0x368d1a9e402ea4dfcf1312dff003104689a0c6c7  |  03 [normal] 2
01 0x0c5466b30b8ead83fe534f96c2f18a308804570d
01 0x004730417cd2b1d19f6be2679906ded4fa8a64e2  |  01 [normal] 0
00 0xeda79f0735a56510876a497e1c105916666b0199
00 0xdb6ae77429d6d6425dcae4e1caa9d6604d24dcfb  |  01 [normal] 1
00 0xd3bfd58a31ddeb2fdd2bc212e38c41725bc93ccd
00 0xc7cbe8797136a2efd0d3af5f5b4d947041261b7c
00 0xc63e408c595eb0add9a054ccd18c9fd0e2f2b0a9
00 0xbc2443fcec11899f34954fca23ebe099fd661386
00 0xb628e2d24b711a60887a69b3518bcf70a00218de
00 0xa9a926bed50dc038b20bb20de361e4c35aae51fc  |  01 [normal] 1
00 0xa18c1d786695860ccec2a285da7c7fa626b14bf4
00 0x98eb6b16c7721ac01bf337c10eedcb024d32f4ee  |  01 [normal] 1
00 0x87cfd09c483fe65352456bb26c784a0e4c4ba389
00 0x6e4f3f1c81b7016c3deb8b2d434209b926d21aa2
00 0x625aaa3279a814db255fd2a31b3575d80898c143  |  01 [normal] 1
00 0x0b85d03faf9d4105d41d800000f58876e69692a7  |  01 [normal] 1
00 0x09e7f58e20d57cb9bdce296cb686d44d1b36404a
```

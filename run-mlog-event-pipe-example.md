Show all uniq `etherbase`'s for blocks written, ranked by frequency.

```sh
$ tail -F geth.log | ~/sandbox/mlog-analysis-poc.sh/mlog-event-pipe.sh
```

The numbers on the left represent percent share of etherbase across _n_ blocks, so of the last 5000 blocks, 38% were credited to etherbase `0xdf7d7e053933b5cc24372f878c90e62dadad5d42`. The first section is in aggregate (thru the default max 5000 log line limit, representing the last 5000 blocks written), and the second does the same analysis, but only across the last 100 blocks. If an etherbase's share in the last 100 blocks varies from it's aggregate "normal" share, where the variance delta is configurable with an argument (default +/- 5%), then `[high]` or `[low]` is appended and at the code level intended to indicate that further behavior can be supplemented based on this logic, eg. `echo "$line" | mail -s [etherbase variance] security@somewhere.org`.

See script for details.

```sh
$ ./etherbase-ranked.sh
last 5000 blocks (eb.uniq=56)                      last 100 blocks (eb.uniq=18)

38 0xdf7d7e053933b5cc24372f878c90e62dadad5d42  |  38 :0
19 0x9eab4b0fc468a7f5d46228bf5a76cb52370d068d  |  18 -1
13 0x1c0fa194a9d3b44313dcd849f3c6be6ad270a0a4  |  21 +8 [high]
08 0x58b3cabd0c5c777da2c1c4d4f7ecc8afe5674f20  |  02 -6 [low]
03 0x0073cf1b9230cf3ee8cab1971b8dbef21ea7b595  |  03 :0
02 0x004730417cd2b1d19f6be2679906ded4fa8a64e2  |  01 -1
01 0xfe96c2235e805ce312cc830a41d3b10f26a69057  |  01 :0
01 0xfe0ca4e9d8b83ff2d03ef4f35f0b5f754e81d1fd  |  03 +2
01 0xf35074bbd0a9aee46f4ea137971feec024ab704e
01 0xeda79f0735a56510876a497e1c105916666b0199  |  01 :0
01 0xd3bfd58a31ddeb2fdd2bc212e38c41725bc93ccd
01 0xd144e30a0571aaf0d0c050070ac435deba461fab
01 0xc91716199ccde49dc4fafaeb68925127ac80443f  |  01 :0
01 0xb628e2d24b711a60887a69b3518bcf70a00218de
01 0x904db9b94455fd4491cc83081785bf82de8a0306  |  01 :0
01 0x50d2eedb5d786de86a6cd0d304ed480e4607652a  |  01 :0
01 0x4c4e80746cd88d471d67e6b198a1ca403d63b500
01 0x00e39b0dde4c80d23cda79a8b6690d9db014490b  |  04 +3
00 0xfbb9a2ef93d9629a0aa074456e6dbac8839062ec
00 0xe029b6a51df171c168badbf5389d7613e9b3eab7
00 0xe0290a004a6cbc7c585871c945d1b540473ded0e
00 0xdb6ae77429d6d6425dcae4e1caa9d6604d24dcfb  |  01 +1
00 0xd4a56d70fb333a40f3e24b7ce8c37a75c4f489eb
00 0xc7cbe8797136a2efd0d3af5f5b4d947041261b7c
00 0xc6e8933f2ce9ea2432a24e2752641e38ce0aaf06
00 0xc63e408c595eb0add9a054ccd18c9fd0e2f2b0a9
00 0xbc2443fcec11899f34954fca23ebe099fd661386
00 0xb0e22e5dcd54b415567eaac00511644b9bde7d07
00 0xa9a926bed50dc038b20bb20de361e4c35aae51fc  |  01 +1
00 0xa18c1d786695860ccec2a285da7c7fa626b14bf4
00 0x9e3d391cd779b241f97c9c5b7d5e99dc6c23da10
00 0x98eb6b16c7721ac01bf337c10eedcb024d32f4ee
00 0x96c7288d90da45aa34690671d94d4e705beb6630
00 0x87cfd09c483fe65352456bb26c784a0e4c4ba389
00 0x864b2dbc20d7fda9e07d653aed76e8400796139e
00 0x85d4a33a48a3f6559136102c9843569c3cbe7c09
00 0x7f78dbcc82dd67bcec32398df1052e8130eaa62b
00 0x6e4f3f1c81b7016c3deb8b2d434209b926d21aa2
00 0x6607fe9f44ef1813b449834317651aacef07ceb4
00 0x625aaa3279a814db255fd2a31b3575d80898c143  |  01 +1
00 0x60f814acce2b2129707228c61065696bcc3e8b9f
00 0x5d5398cda7c17f864e084f385cf13298e5303c18
00 0x5928e011c3b8fc8bef32d5b86a19f2a54c5be654  |  01 +1
00 0x5253b33c1313a4449bc5304a9c55b4cc2bdf2872
00 0x4a48aa1cbcc01209be55c61cc06c263b6cbc1383
00 0x368d1a9e402ea4dfcf1312dff003104689a0c6c7
00 0x2a70e80ebaad80a6e1ef8da34d9ea5269a8e6fab
00 0x25117a5037a922ac5bd6472466a848cd2fe57ba7
00 0x24eeccf68b9772d60f2b5acabe6bb4c3221c302b
00 0x2495f2890805b2d1671fdad700fc1398c574722a
00 0x2387f8db786d43528ffd3b0bd776e2ba39dd3832
00 0x0ca507fc78216a934dfe38e0b81d5aa99fc27e96
00 0x0c5466b30b8ead83fe534f96c2f18a308804570d  |  01 +1
00 0x0b85d03faf9d4105d41d800000f58876e69692a7
00 0x09e7f58e20d57cb9bdce296cb686d44d1b36404a
00 0x0074ffd450de876c7dab1e14a65117399db26c00
```

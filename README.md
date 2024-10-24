# Kurtosis Package Runbook - taiko-preconf-devnet

# Kurtosis Package Deployment

<aside>
⏱️

The deployment normally takes ~ 25 mins.

</aside>

## Install Docker

1. If you don't already have Docker installed, follow the instructions [here](https://docs.docker.com/get-docker/) to install the Docker application specific to your machine (e.g. Apple Intel, Apple M1, etc.).
2. Start the Docker daemon (e.g. open Docker Desktop)
3. Verify that Docker is running:

    `docker image ls`


## Install Kurtosis CLI

For Ubuntu:

```jsx
echo "deb [trusted=yes] https://apt.fury.io/kurtosis-tech/ /" | sudo tee /etc/apt/sources.list.d/kurtosis.list
sudo apt update
sudo apt install kurtosis-cli
```

For MacOS:

```jsx
brew install kurtosis-tech/tap/kurtosis-cli
```

## Download preconfirm-devnet-package Repository and Start taiko-preconf-devnet Enclave

```jsx
git clone https://github.com/NethermindEth/preconfirm-devnet-package.git && \
cd preconfirm-devnet-package && \
git checkout origin/feat/core-rollup && \
kurtosis run --enclave core-rollup . --args-file network_params.yaml
```

After this you should see:

```jsx
INFO[2024-10-07T23:23:43+11:00] =============================================================
INFO[2024-10-07T23:23:43+11:00] ||          Created enclave: taiko-preconf-devnet          ||
INFO[2024-10-07T23:23:43+11:00] =============================================================
Name:            taiko-preconf-devnet
UUID:            512d51fcd07a
Status:          RUNNING
Creation Time:   Mon, 07 Oct 2024 23:00:26 AEDT
Flags:

========================================= Files Artifacts =========================================
UUID           Name
587a0e964dfc   1-lighthouse-nethermind-0-3-0
f045ac7a580a   1-lighthouse-nethermind-4-7-1
7f4551927d63   beacon-genesis-timestamp
2c438ae87ccd   cool-orchid
f2edd2875383   cool-thicket
243399956927   crimson-pumpkin
c33db090924e   el_cl_genesis_data
1ba080f33c5f   final-genesis-timestamp
3bf03b00c9a2   genesis-el-cl-env-file
2b0fefa39788   genesis_validators_root
1ba396af0533   jwt_file
62fdad0d2b6e   keymanager_file
cc231e877974   muddy-lilypad
19c1df8cef1a   prysm-password
a82b6543f36c   taiko_genesis
cef4ac3ce7b7   taiko_genesis_0
0365d410370c   taiko_genesis_1
5cbf8eac6b03   validator-ranges

========================================== User Services ==========================================
UUID           Name                                             Ports                                                  Status
7a8bafa500c7   adminer                                          adminer: 8080/tcp -> http://127.0.0.1:53524            RUNNING
907522f6374d   blockscout                                       http: 4000/tcp -> http://127.0.0.1:35001               RUNNING
60bce8b15be2   blockscout-postgres                              postgresql: 5432/tcp -> postgresql://127.0.0.1:53554   RUNNING
f868ac9b48d4   blockscout-verif                                 http: 8050/tcp -> http://127.0.0.1:35000               RUNNING
9501556037a1   cl-1-lighthouse-nethermind                       http: 4000/tcp -> http://127.0.0.1:33001               RUNNING
                                                                metrics: 5054/tcp -> http://127.0.0.1:33002
                                                                tcp-discovery: 33000/tcp -> 127.0.0.1:33000
                                                                udp-discovery: 33000/udp -> 127.0.0.1:33000
00531c0379c3   cl-2-lighthouse-geth-builder                     http: 4000/tcp -> http://127.0.0.1:33006               RUNNING
                                                                metrics: 5054/tcp -> http://127.0.0.1:33007
                                                                tcp-discovery: 33005/tcp -> 127.0.0.1:33005
                                                                udp-discovery: 33005/udp -> 127.0.0.1:33005
e008fa5d6174   el-1-nethermind-lighthouse                       engine-rpc: 8551/tcp -> 127.0.0.1:32001                RUNNING
                                                                metrics: 9001/tcp -> http://127.0.0.1:32004
                                                                rpc: 8545/tcp -> 127.0.0.1:32002
                                                                tcp-discovery: 32000/tcp -> 127.0.0.1:32000
                                                                udp-discovery: 32000/udp -> 127.0.0.1:32000
                                                                ws: 8546/tcp -> 127.0.0.1:32003
c8410963fc3f   el-2-geth-builder-lighthouse                     engine-rpc: 8551/tcp -> 127.0.0.1:32006                RUNNING
                                                                metrics: 9001/tcp -> http://127.0.0.1:32009
                                                                rpc: 8545/tcp -> 127.0.0.1:32007
                                                                tcp-discovery: 32005/tcp -> 127.0.0.1:32005
                                                                udp-discovery: 32005/udp -> 127.0.0.1:32005
                                                                ws: 8546/tcp -> 127.0.0.1:32008
ef6414e37975   mev-boost-1-lighthouse-nethermind                api: 18550/tcp -> 127.0.0.1:53553                      RUNNING
06eb0f5fc744   mev-flood                                        <none>                                                 RUNNING
5faf6d9d9700   mev-relay-api                                    api: 9062/tcp -> 127.0.0.1:53534                       RUNNING
c4d8ec444c00   mev-relay-housekeeper                            <none>                                                 RUNNING
94cb648dc96a   mev-relay-postgres                               postgresql: 5432/tcp -> postgresql://127.0.0.1:53521   RUNNING
d971a6018b92   mev-relay-redis                                  redis: 6379/tcp -> redis://127.0.0.1:53518             RUNNING
7c0af6fead4d   mev-relay-website                                api: 9060/tcp -> http://127.0.0.1:53541                RUNNING
6beb933b471b   preconf-taiko-driver-0                           driver-port: 1235/tcp -> 127.0.0.1:53715               RUNNING
3a26e6f6419f   preconf-taiko-driver-1                           driver-port: 1235/tcp -> 127.0.0.1:53761               RUNNING
63f455aedabb   preconf-taiko-geth-0                             authrpc: 8551/tcp -> 127.0.0.1:53703                   RUNNING
                                                                discovery: 30306/tcp -> 127.0.0.1:53704
                                                                discovery-udp: 30306/udp -> 127.0.0.1:53845
                                                                http: 8545/tcp -> 127.0.0.1:53701
                                                                metrics: 6060/tcp -> 127.0.0.1:53700
                                                                ws: 8546/tcp -> 127.0.0.1:53702
14175da37e59   preconf-taiko-geth-1                             authrpc: 8551/tcp -> 127.0.0.1:53736                   RUNNING
                                                                discovery: 30306/tcp -> 127.0.0.1:53737
                                                                discovery-udp: 30306/udp -> 127.0.0.1:57116
                                                                http: 8545/tcp -> 127.0.0.1:53734
                                                                metrics: 6060/tcp -> 127.0.0.1:53738
                                                                ws: 8546/tcp -> 127.0.0.1:53735
b643341d10d7   preconf-taiko-proposer-0                         proposer-port: 1234/tcp -> 127.0.0.1:53716             RUNNING
59fc29032b67   preconf-taiko-proposer-1                         proposer-port: 1234/tcp -> 127.0.0.1:53764             RUNNING
0e2b2c60fc96   taiko-blockscout                                 http: 4000/tcp -> http://127.0.0.1:35003               RUNNING
d20832becc9f   taiko-blockscout-postgres                        postgresql: 5432/tcp -> postgresql://127.0.0.1:53765   RUNNING
b3268ed61d7a   taiko-blockscout-verif                           http: 8050/tcp -> http://127.0.0.1:35002               RUNNING
c6c1fc6220ff   taiko-preconf-avs-1                              <none>                                                 RUNNING
4381b673bcc8   taiko-preconf-avs-1-register                     <none>                                                 RUNNING
34c4beab7fac   taiko-preconf-avs-1-validator-1                  <none>                                                 RUNNING
321e2e2e2639   taiko-preconf-avs-1-validator-2                  <none>                                                 RUNNING
7f4cdb69d7db   taiko-preconf-avs-2                              <none>                                                 RUNNING
22f425668394   taiko-preconf-avs-2-register                     <none>                                                 RUNNING
72b667b742e5   taiko-preconf-avs-2-validator-1                  <none>                                                 RUNNING
a7948540b4e1   taiko-preconf-avs-2-validator-2                  <none>                                                 RUNNING
0b1548e1de3b   taiko-preconf-bootnode                           <none>                                                 RUNNING
8424f9426882   taiko-transfer                                   <none>                                                 STOPPED
a8d3ee541d3a   taiko-tx-spammer                                 <none>                                                 RUNNING
f5d63d8e5bec   taiko-tx-transfer                                <none>                                                 RUNNING
d0ddb24a6069   validator-key-generation-cl-validator-keystore   <none>                                                 RUNNING
439858199180   vc-1-nethermind-lighthouse-1                     metrics: 8080/tcp -> http://127.0.0.1:34000            RUNNING
6e15d1a32a42   vc-1-nethermind-lighthouse-2                     metrics: 8080/tcp -> http://127.0.0.1:34003            RUNNING
```

## Start/Restart taiko-preconf-devnet Enclave

**If you encounter an error during starting process, please retry once. If the error persists, please contact @Justin Chan.**

```jsx
kurtosis run --enclave taiko-preconf-devnet github.com/NethermindEth/preconfirm-devnet-package --args-file network_params.yaml
```

## Inspect taiko-preconf-devnet Enclave

```jsx
kurtosis enclave inspect taiko-preconf-devnet
```

## Inspect a certain service inside taiko-preconf-devnet Enclave

***taiko-preconf-avs-1 as an example***

```jsx
kurtosis service inspect taiko-preconf-devnet taiko-preconf-avs-1
```

## Check logs of service inside taiko-preconf-devnet Enclave

***taiko-preconf-avs-1 as an example, you can add more services name to view them all***

```jsx
kurtosis service logs taiko-preconf-devnet taiko-preconf-avs-1
```

## Stop a certain service inside taiko-preconf-devnet Enclave

```jsx
kurtosis service stop taiko-preconf-devnet taiko-preconf-avs-1
```

## Start a certain service inside taiko-preconf-devnet Enclave

```jsx
kurtosis service start taiko-preconf-devnet taiko-preconf-avs-1
```

## Remove taiko-preconf-devnet Enclave

**Please make sure this is done every time you want to restart the setup.**

```jsx
kurtosis enclave rm taiko-preconf-devnet --force
kurtosis clean -a
```

## Pull latest images for taiko-preconf-devnet Enclave

**Since kurtosis package doesn’t pull the latest images by default, if changes were made to images, we need to do it manually:**

```jsx
docker pull nethswitchboard/avs-node:e2e
docker pull nethswitchboard/avs-deploy:e2e
docker pull nethswitchboard/taiko-spammer:e2e
docker pull nethswitchboard/taiko-client:e2e
docker pull nethswitchboard/taiko-transfer:e2e
docker pull nethswitchboard/taiko-deploy:e2e
docker pull nethswitchboard/taiko-geth:e2e
docker pull nethswitchboard/ethereum-genesis-generator:e2e
docker pull nethswitchboard/bootnodep2p:e2e
```

1. L1 Genesis Generator
    1. `docker pull nethswitchboard/ethereum-genesis-generator:e2e`
2. L2 Taiko
    1. `docker pull nethswitchboard/taiko-geth:e2e`
    2. `docker pull nethswitchboard/taiko-client:e2e`
3. Taiko Contract Deployment
    1. `docker pull nethswitchboard/taiko-deploy:e2e`
4. AVS Contract Deployment
    1. `docker pull nethswitchboard/avs-deploy:e2e`
5. AVS Node
    1. `docker pull nethswitchboard/avs-node:e2e`
6. P2P Bootnode
    1. `docker pull nethswitchboard/bootnodep2p:e2e`

## Transaction Spammer

**Adjust `$TX_COUNT`  or `$TX_AMOUNT`  to your desired value.**

```jsx
kurtosis service shell taiko-preconf-devnet taiko-tx-spammer

python tx_spammer.py --count $TX_COUNT --amount $TX_AMOUNT --rpc $RPC_URL --delay $DELAY
```

## Transaction Transfer

**To fund spammer.**

```jsx
kurtosis service start taiko-preconf-devnet taiko-tx-transfer
```

**or (adjust `$TX_COUNT`  or `$TX_AMOUNT`  to your desired value)**

```jsx
kurtosis service shell taiko-preconf-devnet taiko-tx-transfer

python tx_spammer.py --count $TX_COUNT --amount $TX_AMOUNT --rpc $RPC_URL --delay $DELAY
```

# Network Info

## Validators

```jsx
vc-1-nethermind-lighthouse-1:

"0xaaf6c1251e73fb600624937760fef218aace5b253bf068ed45398aeb29d821e4d2899343ddcbbe37cb3f6cf500dff26c": {"public_key": "0xaaf6c1251e73fb600624937760fef218aace5b253bf068ed45398aeb29d821e4d2899343ddcbbe37cb3f6cf500dff26c", "private_key": "0dce41fa73ae9f6bdfd51df4d422d75eee174553dba5fd450c4437e4ed3fc903", "index": 0},

"0x8aa5bbee21e98c7b9e7a4c8ea45aa99f89e22992fa4fc2d73869d77da4cc8a05b25b61931ff521986677dd7f7159e8e6": {"public_key": "0x8aa5bbee21e98c7b9e7a4c8ea45aa99f89e22992fa4fc2d73869d77da4cc8a05b25b61931ff521986677dd7f7159e8e6", "private_key": "3219c83a76e82682c3e706902ca85777e703a06c9f0a82a5dfa6164f527c1ea6", "index": 1},

"0x996323af7e545fb6363ace53f1538c7ddc3eb0d985b2479da3ee4ace10cbc393b518bf02d1a2ddb2f5bdf09b473933ea": {"public_key": "0x996323af7e545fb6363ace53f1538c7ddc3eb0d985b2479da3ee4ace10cbc393b518bf02d1a2ddb2f5bdf09b473933ea", "private_key": "215768a626159445ba0d8a1afab729c5724e75aa020a480580cbf86dd2ae4d47", "index": 2},

"0xa1584dfe1573df8ec88c7b74d76726b4821bfe84bf886dd3c0e3f74c2ea18aa62ca44c871fb1c63971fccf6937e6501f": {"public_key": "0xa1584dfe1573df8ec88c7b74d76726b4821bfe84bf886dd3c0e3f74c2ea18aa62ca44c871fb1c63971fccf6937e6501f", "private_key": "10c3db5c5bdca44958bc765e040a5cae3439551cfb4651df442cbe499b12ee69", "index": 3},

vc-1-nethermind-lighthouse-2:

"0xac69ae9e6c385a368df71d11ac68f45f05e005306df3c2bf98ed3577708256bd97f8c09d3f72115444077a9bb711d8d1": {"public_key": "0xac69ae9e6c385a368df71d11ac68f45f05e005306df3c2bf98ed3577708256bd97f8c09d3f72115444077a9bb711d8d1", "private_key": "5d6534de54d1e4112f45da73f11d265361669bf1f96816f111e67e4665a4c2ad", "index": 4},

"0xad9222dec71ff8ee6bc0426ffe7b5e66f96738225db281dd20027a1556d089fdebd040abfbc2041d6c1a0d8fdcfce183": {"public_key": "0xad9222dec71ff8ee6bc0426ffe7b5e66f96738225db281dd20027a1556d089fdebd040abfbc2041d6c1a0d8fdcfce183", "private_key": "2799191f62a8c55708b2deab69a995d4be56e3fa736318533341ca5476df3087", "index": 5},

"0xa54fe5c26059ed60b4f0b66ef7b0bf167580504525f83c169507dc812816df41b1da6128341c23977300dffd32a32f41": {"public_key": "0xa54fe5c26059ed60b4f0b66ef7b0bf167580504525f83c169507dc812816df41b1da6128341c23977300dffd32a32f41", "private_key": "41f692b9306a699ce01ba5b13fd04776ef5898e0ab09f06e37ba22abe43e403e", "index": 5},

"0x87231421a08ed28e7d357e2b37a26a458155c8d822d829344bd1029e5d175b5edfaa78f16f784f724a2caef124944c4f": {"public_key": "0x87231421a08ed28e7d357e2b37a26a458155c8d822d829344bd1029e5d175b5edfaa78f16f784f724a2caef124944c4f", "private_key": "1c511df0a39ec614499b08cf284d2d1d1aec3c231809c1c5688a4daab09f7752", "index": 7},

```

## Block Explorer

### L1

```jsx
blockscout:
http: 4000/tcp -> http://127.0.0.1:35001
```

### L2

```jsx
taiko-blockscout:
http: 4000/tcp -> http://127.0.0.1:35003
```

## AVS Nodes

```jsx
taiko-preconf-avs-1:
"AVS_NODE_ECDSA_PRIVATE_KEY": "39725efee3fb28614de3bacaffe4cc4bd8c436257e2c8bb887c4b5c4be45e76d"
"VALIDATOR_BLS_PRIVATEKEY": "3219c83a76e82682c3e706902ca85777e703a06c9f0a82a5dfa6164f527c1ea6"
"VALIDATOR_INDEX": 1

taiko-preconf-avs-2:
"AVS_NODE_ECDSA_PRIVATE_KEY": "53321db7c1e331d93a11a41d16f004d7ff63972ec8ec7c25db329728ceeb1710"
"VALIDATOR_BLS_PRIVATEKEY": "215768a626159445ba0d8a1afab729c5724e75aa020a480580cbf86dd2ae4d47"
"VALIDATOR_INDEX": 2
```

## Transaction Spammer

```jsx
"PRIVATE_KEY": "ab63b23eb7941c1251757e24b3d2350d2bc05c3c388d06f8fe6feafefb1e8c70"
"RECIPIENT_ADDRESS": "0x802dCbE1B1A97554B4F50DB5119E37E8e7336417"
```

## Transaction Transfer

```jsx
"PRIVATE_KEY": "370e47f3c39cf4d03cb87cb71a268776421cdc22c39aa81f1e5ba19df19202f1"
"RECIPIENT_ADDRESS": "0xf93Ee4Cf8c6c40b329b0c0626F28333c132CF241"
```

## Pre-funded Accounts

```jsx
# m/44'/60'/0'/0/0
new_prefunded_account(
    "0x8943545177806ED17B9F23F0a21ee5948eCaa776",
    "bcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
),
# m/44'/60'/0'/0/1
new_prefunded_account(
    "0xE25583099BA105D9ec0A67f5Ae86D90e50036425",
    "39725efee3fb28614de3bacaffe4cc4bd8c436257e2c8bb887c4b5c4be45e76d",
),
# m/44'/60'/0'/0/2
new_prefunded_account(
    "0x614561D2d143621E126e87831AEF287678B442b8",
    "53321db7c1e331d93a11a41d16f004d7ff63972ec8ec7c25db329728ceeb1710",
),
# m/44'/60'/0'/0/3
new_prefunded_account(
    "0xf93Ee4Cf8c6c40b329b0c0626F28333c132CF241",
    "ab63b23eb7941c1251757e24b3d2350d2bc05c3c388d06f8fe6feafefb1e8c70",
),
# m/44'/60'/0'/0/4
new_prefunded_account(
    "0x802dCbE1B1A97554B4F50DB5119E37E8e7336417",
    "5d2344259f42259f82d2c140aa66102ba89b57b4883ee441a8b312622bd42491",
),
# m/44'/60'/0'/0/5
new_prefunded_account(
    "0xAe95d8DA9244C37CaC0a3e16BA966a8e852Bb6D6",
    "27515f805127bebad2fb9b183508bdacb8c763da16f54e0678b16e8f28ef3fff",
),
# m/44'/60'/0'/0/6
new_prefunded_account(
    "0x2c57d1CFC6d5f8E4182a56b4cf75421472eBAEa4",
    "7ff1a4c1d57e5e784d327c4c7651e952350bc271f156afb3d00d20f5ef924856",
),
# m/44'/60'/0'/0/7
new_prefunded_account(
    "0x741bFE4802cE1C4b5b00F9Df2F5f179A1C89171A",
    "3a91003acaf4c21b3953d94fa4a6db694fa69e5242b2e37be05dd82761058899",
),
# m/44'/60'/0'/0/8
new_prefunded_account(
    "0xc3913d4D8bAb4914328651C2EAE817C8b78E1f4c",
    "bb1d0f125b4fb2bb173c318cdead45468474ca71474e2247776b2b4c0fa2d3f5",
),
# m/44'/60'/0'/0/9
new_prefunded_account(
    "0x65D08a056c17Ae13370565B04cF77D2AfA1cB9FA",
    "850643a0224065ecce3882673c21f56bcf6eef86274cc21cadff15930b59fc8c",
),
# m/44'/60'/0'/0/10
new_prefunded_account(
    "0x3e95dFbBaF6B348396E6674C7871546dCC568e56",
    "94eb3102993b41ec55c241060f47daa0f6372e2e3ad7e91612ae36c364042e44",
),
# m/44'/60'/0'/0/11
new_prefunded_account(
    "0x5918b2e647464d4743601a865753e64C8059Dc4F",
    "daf15504c22a352648a71ef2926334fe040ac1d5005019e09f6c979808024dc7",
),
# m/44'/60'/0'/0/12
new_prefunded_account(
    "0x589A698b7b7dA0Bec545177D3963A2741105C7C9",
    "eaba42282ad33c8ef2524f07277c03a776d98ae19f581990ce75becb7cfa1c23",
),
# m/44'/60'/0'/0/13
new_prefunded_account(
    "0x4d1CB4eB7969f8806E2CaAc0cbbB71f88C8ec413",
    "3fd98b5187bf6526734efaa644ffbb4e3670d66f5d0268ce0323ec09124bff61",
),
# m/44'/60'/0'/0/14
new_prefunded_account(
    "0xF5504cE2BcC52614F121aff9b93b2001d92715CA",
    "5288e2f440c7f0cb61a9be8afdeb4295f786383f96f5e35eb0c94ef103996b64",
),
# m/44'/60'/0'/0/15
new_prefunded_account(
    "0xF61E98E7D47aB884C244E39E031978E33162ff4b",
    "f296c7802555da2a5a662be70e078cbd38b44f96f8615ae529da41122ce8db05",
),
# m/44'/60'/0'/0/16
new_prefunded_account(
    "0xf1424826861ffbbD25405F5145B5E50d0F1bFc90",
    "bf3beef3bd999ba9f2451e06936f0423cd62b815c9233dd3bc90f7e02a1e8673",
),
# m/44'/60'/0'/0/17
new_prefunded_account(
    "0xfDCe42116f541fc8f7b0776e2B30832bD5621C85",
    "6ecadc396415970e91293726c3f5775225440ea0844ae5616135fd10d66b5954",
),
# m/44'/60'/0'/0/18
new_prefunded_account(
    "0xD9211042f35968820A3407ac3d80C725f8F75c14",
    "a492823c3e193d6c595f37a18e3c06650cf4c74558cc818b16130b293716106f",
),
# m/44'/60'/0'/0/19
new_prefunded_account(
    "0xD8F3183DEF51A987222D845be228e0Bbb932C222",
    "c5114526e042343c6d1899cad05e1c00ba588314de9b96929914ee0df18d46b2",
),
# m/44'/60'/0'/0/20
new_prefunded_account(
    "0xafF0CA253b97e54440965855cec0A8a2E2399896",
    "4b9f63ecf84210c5366c66d68fa1f5da1fa4f634fad6dfc86178e4d79ff9e59",
),
```

## MEV Builder

**MEV Builder is using the first pre-funded account as transaction signing key.**

```jsx
"BUILDER_TX_SIGNING_KEY=0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31"
```

## Contracts Addresses

**Currently contracts are all deployed using the first pre-funded account.**

```jsx
**Taiko**
shared_address_manager: 0x17435ccE3d1B4fA2e5f8A08eD921D57C6762A180
taiko_token: 0x422A3492e218383753D8006C7Bfa97815B44373F
signal_service: 0x8F0342A7060e76dfc7F6e9dEbfAD9b9eC919952c
rollup_address_manager: 0x9fCF7D13d10dEdF17d0f24C62f0cf4ED462f65b7
sequencer_registry: 0x72bCbB3f339aF622c28a26488Eed9097a2977404
taiko: 0x086f77C5686dfe3F2f8FE487C5f8d357952C8556
tier_sgx: 0x38435Ac0E0e9Bd8737c476F8F39a24b0735e00dc
guardian_prover_minority: 0xE19dddcaF5dCb2Ec0Fe52229e3133B99396f22e2
guardian_prover: 0x9ECB6f04D47FA2599449AaA523bF84476f7aD80f
sequencer_registry (second instance): 0x3c0e871bB7337D5e6A18FDD73c4D9e7567961Ad3

**Eigenlayer MVP**
AVS Directory: 0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B
Delegation Manager: 0xeB804d271b58d9405CD94e294504E56d55B6E35c
Strategy Manager: 0xaDe68b4b6410aDB1578896dcFba75283477b6b01
Slasher: 0x86A0679C7987B5BA9600affA994B78D0660088ff

**AVS**
Proxy admin: 0xc6F76D133052002abdBAda02ba35dB8b7414FcAa
Preconf Registry: 0x9D2ea2038CF6009F1Bc57E32818204726DfA63Cd
Preconf Service Manager: 0x1912A7496314854fB890B1B88C0f1Ced653C1830
Preconf Task Manager: 0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1
```

## Contracts Env

### Taiko

```jsx
"PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
"PROPOSER": "0x0000000000000000000000000000000000000000",
"TAIKO_TOKEN": "0x0000000000000000000000000000000000000000",
"PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
"GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
"TAIKO_L2_ADDRESS": "0x1670000000000000000000000000000000010001",
"L2_SIGNAL_SERVICE": "0x1670000000000000000000000000000000000005",
"CONTRACT_OWNER": contract_owner.address,
"PROVER_SET_ADMIN": contract_owner.address,
"TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
"TAIKO_TOKEN_NAME": "Taiko Token",
"TAIKO_TOKEN_SYMBOL": "TKO",
"SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
"L2_GENESIS_HASH": "0x7983c69e31da54b8d244d8fef4714ee7a8ed25d873ebef204a56f082a73c9f1e",
"PAUSE_TAIKO_L1": "false",
"PAUSE_BRIDGE": "true",
"NUM_MIN_MAJORITY_GUARDIANS": "7",
"NUM_MIN_MINORITY_GUARDIANS": "2",
"TIER_PROVIDER": "devnet",
"FORK_URL": el_rpc_url,
```

### Eigenlayer MVP

```jsx
"PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
"FORK_URL": el_rpc_url,
```

### AVS

```jsx
"PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
"FORK_URL": el_rpc_url,
"BEACON_GENESIS_TIMESTAMP": beacon_genesis_timestamp,
"BEACON_BLOCK_ROOT_CONTRACT": "0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02",
"SLASHER": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
"AVS_DIRECTORY": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
"TAIKO_L1": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
"TAIKO_TOKEN": "0x422A3492e218383753D8006C7Bfa97815B44373F",
```

### Add to Sequencer

```jsx
"PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
"FORK_URL": el_rpc_url,
"PROXY_ADDRESS": "0x3c0e871bB7337D5e6A18FDD73c4D9e7567961Ad3",
"ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
"ENABLED": "true",
```

# Core Rollup Stack

## Nethermind EL

Repo:

Image: `nethermindeth/nethermind:taiko-b8f32a5`

Command:

```jsx
- --config=none
- --datadir=/nethermind/data
- --Init.ChainSpecPath=/chainspec.json
- --Init.GenesisHash=0x1f5554042aa50dc0712936ae234d8803b80b84251f85d074756a2f391896e109
- --Init.DiscoveryEnabled=false
- --Metrics.Enabled=true
- --Metrics.ExposePort=8018
- --Network.Bootnodes=${BOOT_NODES}
- --JsonRpc.Enabled=true
- --JsonRpc.EnabledModules=[debug,eth,net,web3,txpool,rpc,subscribe,trace,personal,proof,parity,health]
- --JsonRpc.Host=0.0.0.0
- --JsonRpc.Port=8547
- --JsonRpc.WebSocketsPort=8548
- --JsonRpc.JwtSecretFile=/tmp/jwt/jwtsecret
- --JsonRpc.EngineHost=0.0.0.0
- --JsonRpc.EnginePort=8552
- --Network.DiscoveryPort=30313
- --HealthChecks.Enabled=true
- --log=${NETHERMIND_OP_LOG_LEVEL}
```

## Taiko Client

Repo: [https://github.com/taikoxyz/taiko-mono](https://github.com/taikoxyz/taiko-mono)

Image: `us-docker.pkg.dev/evmchain/images/taiko-client:taiko-client-v0.38.0`

### Taiko Driver

Doc: [https://docs.taiko.xyz/guides/node-operators/run-a-testnet-taiko-node-from-source/#start-taiko-geth](https://docs.taiko.xyz/guides/node-operators/run-a-testnet-taiko-node-from-source/#start-taiko-geth)

Command:

```jsx
- taiko-client
- driver
- --l1.ws=${L1_ENDPOINT_WS}
- --l2.ws=ws://execution-taiko-l2-client:8548
- --l1.beacon=${L1_BEACON_HTTP}
- --l2.auth=http://execution-taiko-l2-client:8552
- --taikoL1=${TAIKO_L1_ADDRESS}
- --taikoL2=${TAIKO_L2_ADDRESS}
- --jwtSecret=/tmp/jwt/jwtsecret
- --p2p.sync
- --p2p.checkPointSyncUrl=${P2P_SYNC_URL}
```

### Taiko Prover

Doc: [https://docs.taiko.xyz/guides/node-operators/enable-a-prover/](https://docs.taiko.xyz/guides/node-operators/enable-a-prover/) and [https://docs.taiko.xyz/guides/node-operators/deploy-a-proverset/](https://docs.taiko.xyz/guides/node-operators/deploy-a-proverset/)

Command:

```jsx
- taiko-client
- prover
- --l1.ws=${L1_ENDPOINT_WS}
- --l2.ws=ws://execution-taiko-l2-client:8548
- --l2.http=http://execution-taiko-l2-client:8547
- --taikoL1=${TAIKO_L1_ADDRESS}
- --taikoL2=${TAIKO_L2_ADDRESS}
- --taikoToken=${TAIKO_TOKEN_L1_ADDRESS}
- --l1.proverPrivKey=${L1_PROVER_PRIVATE_KEY}
- --prover.capacity=${PROVER_CAPACITY}
- --raiko.host=${SGX_RAIKO_HOST}
# conditioned
# - --proverSet ${PROVER_SET}
# - --prover.allowance ${TOKEN_ALLOWANCE}
# - --prover.minEthBalance ${MIN_ETH_BALANCE}
# - --prover.minTaikoTokenBalance ${MIN_TAIKO_BALANCE}
# - --prover.proveUnassignedBlocks
# - --tx.feeLimitMultiplier ${TX_FEE_LIMIT_MULTIPLIER}
# - --tx.feeLimitThreshold ${TX_FEE_LIMIT_THRESHOLD}
# - --tx.gasLimit ${TX_GAS_LIMIT}
# - --tx.minBaseFee ${TX_MIN_BASEFEE}
# - --tx.minTipCap ${TX_MIN_TIP_CAP}
# - --tx.notInMempoolTimeout ${TX_NOT_IN_MEMPOOL}
# - --tx.numConfirmations ${TX_NUM_CONFIRMATIONS}
# - --tx.receiptQueryInterval ${TX_RECEIPT_QUERY}
# - --tx.resubmissionTimeout ${TX_RESUBMISSION}
# - --tx.safeAbortNonceTooLowCount ${TX_SAFE_ABORT_NONCE_TOO_LOW}
# - --tx.sendTimeout ${TX_SEND_TIMEOUT}
```

### Taiko Proposer

Doc: [https://docs.taiko.xyz/guides/node-operators/enable-a-proposer/](https://docs.taiko.xyz/guides/node-operators/enable-a-proposer/)

Command:

```jsx
- taiko-client
- proposer
- --l1.ws=${L1_ENDPOINT_WS}
- --l2.http=http://execution-taiko-l2-client:8547
- --l2.auth=http://execution-taiko-l2-client:8552
- --taikoL1=${TAIKO_L1_ADDRESS}
- --taikoL2=${TAIKO_L2_ADDRESS}
- --taikoToken=${TAIKO_TOKEN_L1_ADDRESS}
- --jwtSecret=/tmp/jwt/jwtsecret
- --l1.proposerPrivKey=${L1_PROPOSER_PRIVATE_KEY}
- --l2.suggestedFeeRecipient=${L2_SUGGESTED_FEE_RECIPIENT}
# conditioned
# - --epoch.minTip ${EPOCH_MIN_TIP}
# - --proverSet ${PROVER_SET}
# - --txPool.localsOnly
# - --txPool.locals ${TXPOOL_LOCALS}
# - --l1.blobAllowed
# - --tx.feeLimitMultiplier ${TX_FEE_LIMIT_MULTIPLIER}
# - --tx.feeLimitThreshold ${TX_FEE_LIMIT_THRESHOLD}
# - --tx.gasLimit ${TX_GAS_LIMIT}
# - --tx.minBaseFee ${TX_MIN_BASEFEE}
# - --tx.minTipCap ${TX_MIN_TIP_CAP}
# - --tx.notInMempoolTimeout ${TX_NOT_IN_MEMPOOL}
# - --tx.numConfirmations ${TX_NUM_CONFIRMATIONS}
# - --tx.receiptQueryInterval ${TX_RECEIPT_QUERY}
# - --tx.resubmissionTimeout ${TX_RESUBMISSION}
# - --tx.safeAbortNonceTooLowCount ${TX_SAFE_ABORT_NONCE_TOO_LOW}
# - --tx.sendTimeout ${TX_SEND_TIMEOUT}
```

## Hekla (Taiko testnet on Holesky)

### Docker Compose

```jsx
services:
  nethermind_execution_l2:
    image: nethermindeth/nethermind:taiko-dbb9588
    container_name: execution-taiko-l2-client
    restart: unless-stopped
    pull_policy: always
    stop_grace_period: 3m
    tty: true
    volumes:
      - ./execution-data-taiko:/nethermind/data
      - ./jwtsecret:/tmp/jwt/jwtsecret
      - ./chainspec.json:/chainspec.json
    networks:
      - surge
    ports:
      - 30313:30313/tcp
      - 30313:30313/udp
      - 8018:8018
      - 8547:8547
      - 8548:8548
      - 8552:8552
    command:
      - --config=none
      - --datadir=/nethermind/data
      - --Init.ChainSpecPath=/chainspec.json
      - --Init.GenesisHash=0x1f5554042aa50dc0712936ae234d8803b80b84251f85d074756a2f391896e109
      - --Init.DiscoveryEnabled=false
      - --Metrics.Enabled=true
      - --Metrics.ExposePort=8018
      - --Network.Bootnodes=${BOOT_NODES}
      - --JsonRpc.Enabled=true
      - --JsonRpc.EnabledModules=[debug,eth,net,web3,txpool,rpc,subscribe,trace,personal,proof,parity,health]
      - --JsonRpc.Host=0.0.0.0
      - --JsonRpc.Port=8547
      - --JsonRpc.WebSocketsPort=8548
      - --JsonRpc.JwtSecretFile=/tmp/jwt/jwtsecret
      - --JsonRpc.EngineHost=0.0.0.0
      - --JsonRpc.EnginePort=8552
      - --Network.DiscoveryPort=30313
      - --HealthChecks.Enabled=true
      - --log=${NETHERMIND_OP_LOG_LEVEL}
    profiles:
      - nethermind_execution_l2
      - prover
      - proposer

  taiko_client_driver:
    image: us-docker.pkg.dev/evmchain/images/taiko-client:taiko-client-v0.38.0
    container_name: consensus-op-l2-client
    restart: unless-stopped
    pull_policy: always
    depends_on:
      - nethermind_execution_l2
    volumes:
      - ./execution-data-taiko:/data/taiko-geth
      - ./jwtsecret:/tmp/jwt/jwtsecret
    networks:
      - surge
    entrypoint:
      - taiko-client
    command:
      - driver
      - --l1.ws=${L1_ENDPOINT_WS}
      - --l2.ws=ws://execution-taiko-l2-client:8548
      - --l1.beacon=${L1_BEACON_HTTP}
      - --l2.auth=http://execution-taiko-l2-client:8552
      - --taikoL1=${TAIKO_L1_ADDRESS}
      - --taikoL2=${TAIKO_L2_ADDRESS}
      - --jwtSecret=/tmp/jwt/jwtsecret
      - --p2p.sync
      - --p2p.checkPointSyncUrl=${P2P_SYNC_URL}
    profiles:
      - nethermind_execution_l2
      - prover
      - proposer

  taiko_client_prover_relayer:
    image: us-docker.pkg.dev/evmchain/images/taiko-client:taiko-client-v0.38.0
    restart: unless-stopped
    pull_policy: always
    depends_on:
      - nethermind_execution_l2
      - taiko_client_driver
    networks:
      - surge
    ports:
      - "${PORT_PROVER_SERVER}:9876"
    entrypoint:
      - taiko-client
    command:
      - prover
      - --l1.ws=${L1_ENDPOINT_WS}
      - --l2.ws=ws://execution-taiko-l2-client:8548
      - --l2.http=http://execution-taiko-l2-client:8547
      - --taikoL1=${TAIKO_L1_ADDRESS}
      - --taikoL2=${TAIKO_L2_ADDRESS}
      - --taikoToken=${TAIKO_TOKEN_L1_ADDRESS}
      - --l1.proverPrivKey=${L1_PROVER_PRIVATE_KEY}
      - --prover.capacity=${PROVER_CAPACITY}
      - --raiko.host=${SGX_RAIKO_HOST}
      # conditioned
      # - --proverSet ${PROVER_SET}
      # - --prover.allowance ${TOKEN_ALLOWANCE}
      # - --prover.minEthBalance ${MIN_ETH_BALANCE}
      # - --prover.minTaikoTokenBalance ${MIN_TAIKO_BALANCE}
      # - --prover.proveUnassignedBlocks
      # - --tx.feeLimitMultiplier ${TX_FEE_LIMIT_MULTIPLIER}
      # - --tx.feeLimitThreshold ${TX_FEE_LIMIT_THRESHOLD}
      # - --tx.gasLimit ${TX_GAS_LIMIT}
      # - --tx.minBaseFee ${TX_MIN_BASEFEE}
      # - --tx.minTipCap ${TX_MIN_TIP_CAP}
      # - --tx.notInMempoolTimeout ${TX_NOT_IN_MEMPOOL}
      # - --tx.numConfirmations ${TX_NUM_CONFIRMATIONS}
      # - --tx.receiptQueryInterval ${TX_RECEIPT_QUERY}
      # - --tx.resubmissionTimeout ${TX_RESUBMISSION}
      # - --tx.safeAbortNonceTooLowCount ${TX_SAFE_ABORT_NONCE_TOO_LOW}
      # - --tx.sendTimeout ${TX_SEND_TIMEOUT}
    profiles:
      - prover

  taiko_client_proposer:
    image: us-docker.pkg.dev/evmchain/images/taiko-client:taiko-client-v0.38.0
    restart: unless-stopped
    pull_policy: always
    depends_on:
      - nethermind_execution_l2
      - taiko_client_driver
    volumes:
      - ./execution-data-taiko:/data/taiko-geth
      - ./jwtsecret:/tmp/jwt/jwtsecret
    networks:
      - surge
    entrypoint:
      - taiko-client
    command:
      - proposer
      - --l1.ws=${L1_ENDPOINT_WS}
      - --l2.http=http://execution-taiko-l2-client:8547
      - --l2.auth=http://execution-taiko-l2-client:8552
      - --taikoL1=${TAIKO_L1_ADDRESS}
      - --taikoL2=${TAIKO_L2_ADDRESS}
      - --taikoToken=${TAIKO_TOKEN_L1_ADDRESS}
      - --jwtSecret=/tmp/jwt/jwtsecret
      - --l1.proposerPrivKey=${L1_PROPOSER_PRIVATE_KEY}
      - --l2.suggestedFeeRecipient=${L2_SUGGESTED_FEE_RECIPIENT}
      # conditioned
      # - --epoch.minTip ${EPOCH_MIN_TIP}
      # - --proverSet ${PROVER_SET}
      # - --txPool.localsOnly
      # - --txPool.locals ${TXPOOL_LOCALS}
      # - --l1.blobAllowed
      # - --tx.feeLimitMultiplier ${TX_FEE_LIMIT_MULTIPLIER}
      # - --tx.feeLimitThreshold ${TX_FEE_LIMIT_THRESHOLD}
      # - --tx.gasLimit ${TX_GAS_LIMIT}
      # - --tx.minBaseFee ${TX_MIN_BASEFEE}
      # - --tx.minTipCap ${TX_MIN_TIP_CAP}
      # - --tx.notInMempoolTimeout ${TX_NOT_IN_MEMPOOL}
      # - --tx.numConfirmations ${TX_NUM_CONFIRMATIONS}
      # - --tx.receiptQueryInterval ${TX_RECEIPT_QUERY}
      # - --tx.resubmissionTimeout ${TX_RESUBMISSION}
      # - --tx.safeAbortNonceTooLowCount ${TX_SAFE_ABORT_NONCE_TOO_LOW}
      # - --tx.sendTimeout ${TX_SEND_TIMEOUT}
    profiles:
      - proposer

  # prometheus:
  #   image: prom/prometheus:latest
  #   restart: unless-stopped
  #   ports:
  #     - ${PORT_PROMETHEUS}:9090
  #   depends_on:
  #     - nethermind_execution_l2
  #     - taiko_client_driver
  #   volumes:
  #     - ./docker/prometheus/l2:/etc/prometheus
  #     - prometheus_data:/prometheus
  #   command:
  #     - --log.level=debug
  #     - --config.file=/etc/prometheus/prometheus.yml
  #   profiles:
  #     - nethermind_execution_l2
  #     - prover
  #     - proposer

  # grafana:
  #   image: grafana/grafana:latest
  #   restart: unless-stopped
  #   ports:
  #     - ${PORT_GRAFANA}:3000
  #   depends_on:
  #     - nethermind_execution_l2
  #     - taiko_client_driver
  #     - prometheus
  #   environment:
  #     - GF_PATHS_CONFIG=/etc/grafana/custom/settings.ini
  #     - GF_PATHS_PROVISIONING=/etc/grafana/custom/provisioning
  #     - GF_LOG_LEVEL=WARN
  #   volumes:
  #     - ./docker/grafana/custom/settings.ini:/etc/grafana/custom/settings.ini
  #     - ./docker/grafana/custom/l2/provisioning/:/etc/grafana/custom/provisioning/
  #     - grafana_data:/var/lib/grafana
  #   profiles:
  #     - nethermind_execution_l2
  #     - prover
  #     - proposer

volumes:
  prometheus_data:
  grafana_data:

networks:
  surge:
    name: surge-network
```

### Env Vars

```jsx
############################### DEFAULT #####################################
# Chain ID
CHAIN_ID=167009

# Exposed ports
PORT_PROVER_SERVER=9876
PORT_PROMETHEUS=9091
PORT_GRAFANA=3001

# Comma separated L2 execution engine bootnode URLs for P2P discovery bootstrap
BOOT_NODES=enode://1733a899719c64edc8ad6818598b6b9aa41889297a7ee7b9cbf3e610d4df2e207b0e04fd40060a36f020116ab5ad451201e448fc224cd38b0a0d5fcbb1d2c812@34.126.109.163:30303,enode://3c7e00eff6a98f5d49084db988b9bee9cab3338ee809d88e41318dc7ea7fb67ab8e8a923e4a9f193fecd7698ef92c0977e07ac850e10777bdd11cc25045d63bf@35.198.236.33:30303,enode://eb5079aae185d5d8afa01bfd2d349da5b476609aced2b57c90142556cf0ee4a152bcdd724627a7de97adfc2a68af5742a8f58781366e6a857d4bde98de6fe986@34.66.210.65:30303,enode://2294f526cbb7faa778192289c252307420532191438ce821d3c50232e019a797bda8c8f8541de0847e953bb03096123856935e32294de9814d15d120131499ba@34.72.186.213:30303

# Taiko protocol contract addresses
TAIKO_L1_ADDRESS=0x79C9109b764609df928d16fC4a91e9081F7e87DB
TAIKO_TOKEN_L1_ADDRESS=0x6490E12d480549D333499236fF2Ba6676C296011
TAIKO_L2_ADDRESS=0x1670090000000000000000000000000000010001

# P2P
DISABLE_P2P_SYNC=false
P2P_SYNC_URL=https://rpc.hekla.taiko.xyz

# Nethermind log level
NETHERMIND_OP_LOG_LEVEL=debug

############################### REQUIRED #####################################
# L1 Holesky RPC endpoints (you will need an RPC provider such as BlockPi, or run a full Holesky node yourself).
# If you are using a local Holesky L1 node, you can refer to it as "http://host.docker.internal:8545" and "ws://host.docker.internal:8546", which refer to the default ports in the .env for an eth-docker L1 node.
# However, you may need to add this host to docker-compose.yml. If that does not work, you can try the private local ip address (e.g. http://192.168.1.15:8545). You can find that with `ip addr show` or a similar command.
# In addition, you can use your public ip address followed by the specific ports for http and ws (e.g. http://82.168.1.15:8545). You can find that with `hostname -I | awk '{print $1}'`.
L1_ENDPOINT_WS=ws://195.154.100.52:8546
# HTTP RPC endpoint of a L1 beacon node. Everything behind the top-level domain is ignored. Make sure you don't need to work with subdirectories. The path will always be /eth/v1...
# If you are using a local Holesky L1 node, you can refer to it as "http://host.docker.internal:5052", which refer to the default REST port in the .env for an eth-docker L1 node.
# Or follow the recommendations for http RPC endoint using the default REST port "5052", (e.g. http://82.168.1.15:5052).
L1_BEACON_HTTP=http://195.154.100.52:4000

############################### OPTIONAL #####################################
# If you want to be a prover who generates and submits zero knowledge proofs of proposed L2 blocks, you need to change
# `ENABLE_PROVER` to true and set `L1_PROVER_PRIVATE_KEY`.
ENABLE_PROVER=true
# SGX Raiko service endpoint, required if not running a guardian prover.
SGX_RAIKO_HOST=
# How many provers you want to run concurrently.
PROVER_CAPACITY=1
# A L1 account private key (with a balance of TTKOh deposited on TaikoL1) which will be used to sign the bond for proving the block.
# WARNING: only use a test account, pasting your private key in plain text here is not secure.
L1_PROVER_PRIVATE_KEY=
# Amount to approve TaikoL1 contracts for TaikoToken usage. i.e 250 TTKOh = 250
TOKEN_ALLOWANCE=
# Minimum ETH balance (in ETH) a prover wants to keep.
MIN_ETH_BALANCE=
# Minimum Taiko token balance (in ether) a prover wants to keep. i.e 250 TTKOh = 250
MIN_TAIKO_BALANCE=
# Whether to prove unassigned blocks or not (blocks that have expired their proof window
# without the original prover submitting a proof.).
PROVE_UNASSIGNED_BLOCKS=false

# If you want to be a proposer who proposes L2 execution engine's transactions in mempool to Taiko L1 protocol
# contract (be a "mining L2 node"), you need to change `ENABLE_PROPOSER` to true, then fill `L1_PROPOSER_PRIVATE_KEY`.
ENABLE_PROPOSER=true
# A L1 account (with balance) private key who will send TaikoL1.proposeBlock transactions.
L1_PROPOSER_PRIVATE_KEY=
# Address of the proposed block's suggested L2 fee recipient.
L2_SUGGESTED_FEE_RECIPIENT=
# Comma-delineated list (no spaces) of prover endpoints proposer should query when attempting to propose a block
# If you keep this default value you must also enable a prover by setting ENABLE_PROVER=true.
# Whether to send EIP-4844 blob transactions when proposing blocks.
BLOB_ALLOWED=true
# Minimum tip (in GWei) for a transaction to propose.
EPOCH_MIN_TIP=
# ProverSet Address: We highly recommend you consult the deploy a proverset guide and use separate EOAs for prover and proposer to prevent nonce issues.
PROVER_SET=

# Comma-delimited local tx pool addresses you want to prioritize, useful to set your proposer to only propose blocks with your prover's transactions.
TXPOOL_LOCALS=

# Transaction Manager Flags (Leave blank if using default values.) These only affect Prover and Proposer.

# The multiplier applied to fee suggestions to put a hard limit on fee increases
TX_FEE_LIMIT_MULTIPLIER=
# The minimum threshold (in GWei) at which fee bumping starts to be capped. Allows arbitrary fee bumps below this threshold.
TX_FEE_LIMIT_THRESHOLD=
# Gas limit will be used for transactions (0 means using gas estimation)
TX_GAS_LIMIT=
# Enforces a minimum base fee (in GWei) to assume when determining tx fees. 1 GWei by default
TX_MIN_BASEFEE=
# Enforces a minimum tip cap (in GWei) to use when determining tx fees. 1 GWei by default.
TX_MIN_TIP_CAP=
# Timeout for aborting a tx send if the tx does not make it to the mempool.
TX_NOT_IN_MEMPOOL_TIMEOUT=
# Number of confirmations which we will wait after sending a transaction
TX_NUM_CONFIRMATIONS=
# Frequency to poll for receipts
TX_RECEIPT_QUERY_INTERVAL=
# Duration we will wait before resubmitting a transaction to L1
TX_RESUBMISSION=
# Number of ErrNonceTooLow observations required to give up on a tx at a particular nonce without receiving confirmation
TX_SAFE_ABORT_NONCE_TOO_LOW=
# Timeout for sending transactions. If 0 it is disabled.
TX_SEND_TIMEOUT=
```

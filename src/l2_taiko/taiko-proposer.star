PROPOSER_PORT_NUM = 1234

def launch(
    plan,
    data_dirpath,
    jwtsecret_path,
    el_context,
    cl_context,
    geth,
    prefunded_accounts,
    index,
    contracts_addresses,
    taiko_client_image,
):
    service = plan.add_service(
        name = "preconf-taiko-proposer-{0}".format(index),
        config = ServiceConfig(
            image = taiko_client_image,
            files = {
                data_dirpath: "taiko_genesis_{0}".format(index),
            },
            env_vars = {
                "SGX_RAIKO_HOST": "",
                "TAIKO_L1_ADDRESS": contracts_addresses.taiko_l1,
                "TAIKO_L2_ADDRESS": contracts_addresses.taiko_l2,
                "TX_RECEIPT_QUERY": "",
                "PORT_L2_EXECUTION_ENGINE_P2P": "30306",
                "TX_FEE_LIMIT_THRESHOLD": "",
                "PORT_L2_EXECUTION_ENGINE_HTTP": "8547",
                "MIN_ETH_BALANCE": "",
                "BLOB_ALLOWED": "true",
                "PROVER_CAPACITY": "1",
                "TX_MIN_TIP_CAP": "",
                "PROVER_SET": "",
                "PORT_PROMETHEUS": "9091",
                "P2P_SYNC_URL": "https://rpc.mainnet.taiko.xyz",
                "TAIKO_TOKEN_L1_ADDRESS": contracts_addresses.taiko_token,
                "MIN_TAIKO_BALANCE": "",
                "PROVE_UNASSIGNED_BLOCKS": "false",
                "PROVER_ENDPOINTS": "http://taiko_client_prover_relayer:9876",
                "L2_SUGGESTED_FEE_RECIPIENT": contracts_addresses.l2_suggested_fee_recipient,
                "ENABLE_PROVER": "false",
                "TX_FEE_LIMIT_MULTIPLIER": "",
                "L1_PROPOSER_PRIVATE_KEY": "0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
                "DISABLE_P2P_SYNC": "false",
                "TX_SAFE_ABORT_NONCE_TOO_LOW": "",
                "TXPOOL_LOCALS": "",
                "TX_NUM_CONFIRMATIONS": "",
                "ENABLE_PROPOSER": "true",
                "L1_PROVER_PRIVATE_KEY": "",
                "COMPOSE_PROFILES": "l2_execution_engine",
                "TX_SEND_TIMEOUT": "",
                "TOKEN_ALLOWANCE": "",
                "TX_GAS_LIMIT": "3000000",
                "EPOCH_MIN_TIP": "",
                "CHAIN_ID": "167000",
                "PORT_PROVER_SERVER": "9876",
                "PORT_L2_EXECUTION_ENGINE_METRICS": "6060",
                "PORT_GRAFANA": "3001",
                "TX_RESUBMISSION": "",
                "TX_MIN_BASEFEE": "",
                "TX_NOT_IN_MEMPOOL": "",
                "PORT_L2_EXECUTION_ENGINE_WS": "8548",
                # "BOOT_NODES": "enode://7a8955b27eda2ddf361b59983fce9c558b18ad60d996ac106629f7f913247ef13bc842c7cf6ec6f87096a3ea8048b04873c40d3d873c0276d38e222bddd72e88@43.153.44.186:30303,enode://704a50da7e727aa10c45714beb44ece04ca1280ad63bb46bb238a01bf55c19c9702b469fb12c63824fa90f5051f7091b1c5069df1ec9a0ba1e943978c09d270f@49.51.202.127:30303,enode://f52e4e212a15cc4f68df27282e616d51d7823596c83c8c8e3b3416d7ab531cefc7b8a493d01964e1918315e6b0c7a4806634aeabb9013642a9159a53f4ebc094@43.153.16.47:30303,enode://57f4b29cd8b59dc8db74be51eedc6425df2a6265fad680c843be113232bbe632933541678783c2a5759d65eac2e2241c45a34e1c36254bccfe7f72e52707e561@104.197.107.1:30303,enode://87a68eef46cc1fe862becef1185ac969dfbcc050d9304f6be21599bfdcb45a0eb9235d3742776bc4528ac3ab631eba6816e9b47f6ee7a78cc5fcaeb10cd32574@35.232.246.122:30303",
                # "PORT_PROVER_SERVER": "9876",
                # "DISABLE_P2P_SYNC": "false",
                "L1_ENDPOINT_HTTP": el_context.rpc_http_url,
                "L1_ENDPOINT_WS": el_context.ws_url,
                "L1_BEACON_HTTP": cl_context.beacon_http_url,
                # "ENABLE_PROVER": "false",
                # "SGX_RAIKO_HOST": "",
                # "PROVER_CAPACITY": "1",
                # "L1_PROVER_PRIVATE_KEY": "",
                # "TOKEN_ALLOWANCE": "",
                # "MIN_ETH_BALANCE": "",
                # "MIN_TAIKO_BALANCE": "",
                # "PROVE_UNASSIGNED_BLOCKS": "false",
                # "ENABLE_PROPOSER": "true",
                # "PROVER_ENDPOINTS": "http://taiko_client_prover_relayer:9876",
                # "TXPOOL_LOCALS": "",
                # "EPOCH_MIN_TIP": "",
                # "PROVER_SET": "",
            },
            ports = {
                "proposer-port": PortSpec(
                    number=1234, transport_protocol="TCP"
                )
            },
            entrypoint = ["/bin/sh", "-c"],
            cmd = [
                "taiko-client proposer --l1.ws={0} ".format(el_context.ws_url) +
                "--l2.http={0} ".format(geth.rpc_http_url) +
                "--l2.auth={0} ".format(geth.auth_url) +
                "--taikoL1={0} ".format(contracts_addresses.taiko_l1) +
                "--taikoL2={0} ".format(contracts_addresses.taiko_l2) +
                "--jwtSecret={0} ".format(jwtsecret_path) +
                "--taikoToken={0} ".format(contracts_addresses.taiko_token) +
                "--l1.proposerPrivKey={0} ".format(prefunded_accounts[0].private_key) +
                "--l2.suggestedFeeRecipient={0} ".format(contracts_addresses.l2_suggested_fee_recipient) +
                # "--tierFee.optimistic=1 " +
                # "--tierFee.sgx=1 " +
                "--l1.blobAllowed " +
                "--tx.gasLimit=3000000 " +
                "--verbosity=4"
            ],
        ),
    )

    proposer_url = "http://{0}:{1}".format(service.ip_address, PROPOSER_PORT_NUM)

    return struct(
        client_name="taiko-proposer",
        ip_addr=service.ip_address,
        proposer_port_num=PROPOSER_PORT_NUM,
        proposer_url=proposer_url,
        service_name=service.name,
    )

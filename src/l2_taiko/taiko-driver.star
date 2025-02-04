DRIVER_PORT_NUM = 1235

def launch(
    plan,
    data_dirpath,
    jwtsecret_path,
    el_context,
    cl_context,
    geth,
    index,
):
    service = plan.add_service(
        name = "preconf-taiko-driver-{0}".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/taiko-client:e2e",
            files = {
                data_dirpath: "taiko_genesis_{0}".format(index),
            },
            env_vars = {
                "DISABLE_P2P_SYNC": "false",
                "CHAIN_ID": "167000",
                "PORT_L2_EXECUTION_ENGINE_P2P": "30306",
                "TXPOOL_LOCALS": "",
                "TX_RESUBMISSION": "",
                "TX_NUM_CONFIRMATIONS": "",
                "MIN_ETH_BALANCE": "",
                "ENABLE_PROPOSER": "true",
                "BLOB_ALLOWED": "true",
                "TX_RECEIPT_QUERY": "",
                # "BOOT_NODES": "enode://7a8955b27eda2ddf361b59983fce9c558b18ad60d996ac106629f7f913247ef13bc842c7cf6ec6f87096a3ea8048b04873c40d3d873c0276d38e222bddd72e88@43.153.44.186:30303,enode://704a50da7e727aa10c45714beb44ece04ca1280ad63bb46bb238a01bf55c19c9702b469fb12c63824fa90f5051f7091b1c5069df1ec9a0ba1e943978c09d270f@49.51.202.127:30303,enode://f52e4e212a15cc4f68df27282e616d51d7823596c83c8c8e3b3416d7ab531cefc7b8a493d01964e1918315e6b0c7a4806634aeabb9013642a9159a53f4ebc094@43.153.16.47:30303,enode://57f4b29cd8b59dc8db74be51eedc6425df2a6265fad680c843be113232bbe632933541678783c2a5759d65eac2e2241c45a34e1c36254bccfe7f72e52707e561@104.197.107.1:30303,enode://87a68eef46cc1fe862becef1185ac969dfbcc050d9304f6be21599bfdcb45a0eb9235d3742776bc4528ac3ab631eba6816e9b47f6ee7a78cc5fcaeb10cd32574@35.232.246.122:30303",
                "L1_ENDPOINT_HTTP": el_context.rpc_http_url,
                "L1_ENDPOINT_WS": el_context.ws_url,
                "L1_BEACON_HTTP": cl_context.beacon_http_url,
                "TX_MIN_TIP_CAP": "",
                "TX_FEE_LIMIT_THRESHOLD": "",
                "P2P_SYNC_URL": "https://rpc.mainnet.taiko.xyz",
                "TAIKO_L1_ADDRESS": "0xbFaC9e95F250952630Eef4ef62E602d0D37844fe",
                "PORT_PROVER_SERVER": "9876",
                "TX_MIN_BASEFEE": "",
                "PORT_PROMETHEUS": "9091",
                "TX_GAS_LIMIT": "3000000",
                "TX_SEND_TIMEOUT": "",
                "PORT_L2_EXECUTION_ENGINE_WS": "8548",
                "PROVER_ENDPOINTS": "http://taiko_client_prover_relayer:9876",
                "TAIKO_L2_ADDRESS": "0x1670000000000000000000000000000000010001",
                "L2_SUGGESTED_FEE_RECIPIENT": "0x8e81D13339eE01Bb2080EBf9796c5F2e5621f7E1",
                "PROVER_SET": "",
                "MIN_TAIKO_BALANCE": "",
                "L1_PROPOSER_PRIVATE_KEY": "0xbcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
                "TX_NOT_IN_MEMPOOL": "",
                "PROVER_CAPACITY": "1",
                "PROVE_UNASSIGNED_BLOCKS": "false",
                "TX_SAFE_ABORT_NONCE_TOO_LOW": "",
                "L1_PROVER_PRIVATE_KEY": "",
                "ENABLE_PROVER": "false",
                "TX_FEE_LIMIT_MULTIPLIER": "",
                "EPOCH_MIN_TIP": "",
                "COMPOSE_PROFILES": "l2_execution_engine",
                "PORT_L2_EXECUTION_ENGINE_METRICS": "6060",
                "SGX_RAIKO_HOST": "",
                "TAIKO_TOKEN_L1_ADDRESS": "0xC2d8B5248F7A6439E667eAAB6148eC68abCC516B",
                "PORT_GRAFANA": "3001",
                "PORT_L2_EXECUTION_ENGINE_HTTP": "8547",
                "TOKEN_ALLOWANCE": "",
            },
            ports = {
                "driver-port": PortSpec(
                    number=1235, transport_protocol="TCP"
                )
            },
            entrypoint = ["/bin/sh", "-c"],
            cmd = [
                "taiko-client driver --l1.ws={0} ".format(el_context.ws_url) +
                "--l2.ws={0} ".format(geth.ws_url) +
                "--l1.beacon={0} ".format(cl_context.beacon_http_url) +
                "--l2.auth={0} ".format(geth.auth_url) +
                "--taikoL1=0xbFaC9e95F250952630Eef4ef62E602d0D37844fe " +
                "--taikoL2=0x1670000000000000000000000000000000010001 " +
                "--jwtSecret={0} ".format(jwtsecret_path) +
                "--verbosity=4"
            ],
        ),
    )

    driver_url = "http://{0}:{1}".format(service.ip_address, DRIVER_PORT_NUM)

    return struct(
        client_name="taiko-driver",
        ip_addr=service.ip_address,
        driver_port_num=DRIVER_PORT_NUM,
        driver_url=driver_url,
        service_name=service.name,
    )

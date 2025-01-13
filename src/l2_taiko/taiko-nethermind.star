el_admin_node_info = import_module("../el/el_admin_node_info.star")

RPC_PORT_NUM = 8547
WS_PORT_NUM = 8548
DISCOVERY_PORT_NUM = 30303
ENGINE_RPC_PORT_NUM = 8552
METRICS_PORT_NUM = 8018

GENESIS_HASH = "0xb0d3df0b42c7f41100b85fef8454dd29c4d6d6f7d1eda963b3839a0ebaa168cd"
# ENABLED_MODULES = "debug,eth,net,web3,txpool,rpc,subscribe,trace,personal,proof,parity,health"
LOG_LEVEL = "debug"
# BOOT_NODES = "enode://2f7ee605f84362671e7d7c6d47b69a3358b0d87e9ba4648befcae8b19453275ed19059db347c459384c1a3e5486419233c06bf6c4c6f489d81ace6f301a2a446@43.153.55.134:30303,enode://c067356146268d2855ad356c1ce36ba9f78c1633a72f9b7f686679c2ffe04bab6d24e48ef6eefb0e01aa00dff5024f7f94bc583da90b6027f40be4129bbbc5fd@43.153.90.191:30303,enode://acc2bdb6416feddff9734bee1e6de91e684e9df5aeb1d36698cc78b920600aed36a2871e4ad0cf4521afcdc2cde8e2cd410a57038767c356d4ce6c69b9107a5a@170.106.109.12:30303,enode://eb5079aae185d5d8afa01bfd2d349da5b476609aced2b57c90142556cf0ee4a152bcdd724627a7de97adfc2a68af5742a8f58781366e6a857d4bde98de6fe986@34.66.210.65:30303,enode://2294f526cbb7faa778192289c252307420532191438ce821d3c50232e019a797bda8c8f8541de0847e953bb03096123856935e32294de9814d15d120131499ba@34.72.186.213:30303"

# The min/max CPU/memory that the execution node can use
EXECUTION_MIN_CPU = 100
EXECUTION_MIN_MEMORY = 512
EXECUTION_MAX_CPU = 1000
EXECUTION_MAX_MEMORY = 2048

def launch(
    plan,
    data_dirpath,
    enode,
    index,
):
    service = plan.add_service(
        name = "preconf-taiko-nethermind-{0}".format(index),
        config = ServiceConfig(
            image = "nethermindeth/nethermind:surge-47feb43",
            files = {
                "/data/taiko-geth": "taiko_files",
                "/tmp/jwt": "l2_jwt_files",
            },
            ports = {
                "metrics": PortSpec(
                    number=8018, transport_protocol="TCP"
                ),
                "http": PortSpec(
                    number=8547, transport_protocol="TCP"
                ),
                "ws": PortSpec(
                    number=8548, transport_protocol="TCP"
                ),
                "tcp-discovery": PortSpec(
                    number=30303, transport_protocol="TCP"
                ),
                "udp-discovery": PortSpec(
                    number=30303, transport_protocol="UDP"
                ),
                "authrpc": PortSpec(
                    number=8552, transport_protocol="TCP"
                ),
            },
            cmd = [
                "--config=none",
                "--datadir=/data/taiko-geth",
                "--Init.ChainSpecPath=/data/taiko-geth/chainspec.json",
                "--Init.GenesisHash={0}".format(GENESIS_HASH),
                "--Init.DiscoveryEnabled=false",
                "--Metrics.Enabled=true",
                "--Metrics.ExposePort={0}".format(METRICS_PORT_NUM),
                # "--Network.Bootnodes={0}".format(BOOT_NODES),
                "--JsonRpc.Enabled=true",
                "--JsonRpc.EnabledModules=[admin,debug,eth,net,web3,txpool,rpc,subscribe,trace,personal,proof,parity,health]",
                "--JsonRpc.Host=0.0.0.0",
                "--JsonRpc.Port={0}".format(RPC_PORT_NUM),
                "--JsonRpc.WebSocketsPort={0}".format(WS_PORT_NUM),
                "--JsonRpc.JwtSecretFile=/tmp/jwt/jwtsecret",
                "--JsonRpc.EngineHost=0.0.0.0",
                "--JsonRpc.EnginePort={0}".format(ENGINE_RPC_PORT_NUM),
                "--Network.DiscoveryPort={0}".format(DISCOVERY_PORT_NUM),
                "--Network.P2PPort={0}".format(DISCOVERY_PORT_NUM),
                "--HealthChecks.Enabled=true",
                "--log={0}".format(LOG_LEVEL),
            ],
            min_cpu = EXECUTION_MIN_CPU,
            max_cpu = EXECUTION_MAX_CPU,
            min_memory = EXECUTION_MIN_MEMORY,
            max_memory = EXECUTION_MAX_MEMORY,
        ),
    )

    enode = el_admin_node_info.get_enode_for_node(
        plan, service.name, "http"
    )

    enode_shell = plan.run_sh(
        run = "echo -n '" + enode + "' | sed 's/127.0.0.1/" + service.ip_address + "/'",
        name = "nethermind-enode",
        description = "Replace enode with actual IP",
    )

    http_url = "http://{0}:{1}".format(service.ip_address, RPC_PORT_NUM)
    ws_url = "ws://{0}:{1}".format(service.ip_address, WS_PORT_NUM)
    auth_url = "http://{0}:{1}".format(service.ip_address, ENGINE_RPC_PORT_NUM)

    # plan.store_service_files(
    #     service_name=service.name,
    #     src=data_dirpath,
    #     name="taiko_genesis_{0}".format(index),
    #     description="Copying taiko genesis files to the execution node",
    # )

    return struct(
        client_name="taiko-nethermind",
        ip_addr=service.ip_address,
        rpc_port_num=RPC_PORT_NUM,
        ws_port_num=WS_PORT_NUM,
        engine_rpc_port_num=ENGINE_RPC_PORT_NUM,
        rpc_http_url=http_url,
        ws_url=ws_url,
        auth_url=auth_url,
        enode=enode_shell.output,
        # enr=enr,
        service_name=service.name,
    )

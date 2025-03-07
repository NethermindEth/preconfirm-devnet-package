el_admin_node_info = import_module("../el/el_admin_node_info.star")

RPC_PORT_NUM = 8545
WS_PORT_NUM = 8546
DISCOVERY_PORT_NUM = 30306
ENGINE_RPC_PORT_NUM = 8551
METRICS_PORT_NUM = 6060

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
    taiko_geth_image,
):
    service = plan.add_service(
        name = "preconf-taiko-geth-{0}".format(index),
        config = ServiceConfig(
            image = taiko_geth_image,
            files = {
                data_dirpath: "taiko_genesis",
            },
            ports = {
                "metrics": PortSpec(
                    number=6060, transport_protocol="TCP"
                ),
                "http": PortSpec(
                    number=8545, transport_protocol="TCP"
                ),
                "ws": PortSpec(
                    number=8546, transport_protocol="TCP"
                ),
                "discovery": PortSpec(
                    number=30306, transport_protocol="TCP"
                ),
                "discovery-udp": PortSpec(
                    number=30306, transport_protocol="UDP"
                ),
                "authrpc": PortSpec(
                    number=8551, transport_protocol="TCP"
                ),
            },
            cmd = [
                "--taiko",
                "--networkid=167000",
                "--gcmode=archive",
                "--datadir={0}".format(data_dirpath),
                "--bootnodes={0}".format(enode),
                "--metrics",
                "--metrics.expensive",
                "--metrics.addr=0.0.0.0",
                "--authrpc.addr=0.0.0.0",
                "--authrpc.vhosts=*",
                "--http",
                "--http.api=admin,debug,eth,net,web3,txpool,taiko",
                "--http.addr=0.0.0.0",
                "--http.vhosts=*",
                "--ws",
                "--ws.api=debug,eth,net,web3,txpool,taiko",
                "--ws.addr=0.0.0.0",
                "--ws.origins=*",
                "--gpo.ignoreprice=100000000",
                "--port=30306",
                "--discovery.port=30306",
                "--verbosity=4",
            ],
            min_cpu = EXECUTION_MIN_CPU,
            max_cpu = EXECUTION_MAX_CPU,
            min_memory = EXECUTION_MIN_MEMORY,
            max_memory = EXECUTION_MAX_MEMORY,
        ),
    )

    enode, enr = el_admin_node_info.get_enode_enr_for_node(
        plan, service.name, "http"
    )

    enode_shell = plan.run_sh(
        run = "echo -n '" + enode + "' | sed 's/127.0.0.1/" + service.ip_address + "/'",
        name = "geth-enode",
        description = "Replace enode with actual IP",
    )

    http_url = "http://{0}:{1}".format(service.ip_address, RPC_PORT_NUM)
    ws_url = "ws://{0}:{1}".format(service.ip_address, WS_PORT_NUM)
    auth_url = "http://{0}:{1}".format(service.ip_address, ENGINE_RPC_PORT_NUM)

    plan.store_service_files(
        service_name=service.name,
        src=data_dirpath,
        name="taiko_genesis_{0}".format(index),
        description="Copying taiko genesis files to the execution node",
    )

    return struct(
        client_name="taiko-geth",
        ip_addr=service.ip_address,
        rpc_port_num=RPC_PORT_NUM,
        ws_port_num=WS_PORT_NUM,
        engine_rpc_port_num=ENGINE_RPC_PORT_NUM,
        rpc_http_url=http_url,
        ws_url=ws_url,
        auth_url=auth_url,
        enode=enode_shell.output,
        enr=enr,
        service_name=service.name,
    )

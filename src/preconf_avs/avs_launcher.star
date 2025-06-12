prometheus = import_module("../prometheus/prometheus_launcher.star")

SERVICE_NAME = "node-avs-metrics"
METRICS_PORT_NUMBER = 9898
METRICS_PATH = "/metrics"

def launch(
    plan,
    image,
    l1_chain_id,
    el_context,
    cl_context,
    taiko_stack,
    taiko_protocol_image,
    # mev_boost_context,
    prefunded_accounts,
    first_validator_bls_private_key,
    first_validator_index,
    # second_validator_bls_private_key,
    # second_validator_index,
    index,
    taiko_stack_index,
    contracts_addresses,
    simulate_not_submitting_at_the_end_of_epoch,
):
    # mev_boost_url = "http://{0}:{1}".format(
    #     mev_boost_context.private_ip_address, mev_boost_context.port
    # )

    contract_owner = prefunded_accounts[10]
    RPC_URL_COMMAND = "--rpc-url {0}".format(el_context.rpc_http_url)
    PRIVATE_KEY_OWNER_COMMAND = "--private-key {0}".format(contract_owner.private_key)
    ADDRESS_OPERATOR = prefunded_accounts[index].address
    PRIVATE_KEY_OPERATOR = "0x{0}".format(prefunded_accounts[index].private_key)
    PRIVATE_KEY_OPERATOR_COMMAND = "--private-key {0}".format(PRIVATE_KEY_OPERATOR)

    plan.run_sh(
        name="add-operator",
        run="cast send {0} 'addOperator(address)' {1} {2} {3}".format(contracts_addresses.preconf_whitelist, ADDRESS_OPERATOR, PRIVATE_KEY_OWNER_COMMAND, RPC_URL_COMMAND),
        image=taiko_protocol_image,
        wait=None,
        description="Adding operator to taiko",
    )

    plan.run_sh(
        name="transfer-Taiko-token",
        run="cast send {0} 'transfer(address,uint256)' {1} 1000000000000000000000000 {2} {3}".format(contracts_addresses.taiko_token, ADDRESS_OPERATOR, PRIVATE_KEY_OWNER_COMMAND, RPC_URL_COMMAND),
        image=taiko_protocol_image,
        wait=None,
        description="Transfer taiko token",
    )

    plan.run_sh(
        name="approve-Taiko-token",
        run="cast send {0} 'approve(address,uint256)' {1} 1000000000000000000000000 {2} {3}".format(contracts_addresses.taiko_token, contracts_addresses.taiko_l1, PRIVATE_KEY_OPERATOR_COMMAND, RPC_URL_COMMAND),
        image=taiko_protocol_image,
        wait=None,
        description="Approve taiko token",
    )

    plan.run_sh(
        name="bond-Taiko-token",
        run="cast send {0} 'depositBond(uint256)' 1000000000000000000000000 {1} {2}".format(contracts_addresses.taiko_l1, PRIVATE_KEY_OPERATOR_COMMAND, RPC_URL_COMMAND),
        image=taiko_protocol_image,
        wait=None,
        description="Deposit bond",
    )

    # Common environment variables
    base_env_vars = {
        "TAIKO_INBOX_ADDRESS": contracts_addresses.taiko_l1,
        "TAIKO_ANCHOR_ADDRESS": contracts_addresses.taiko_l2,
        "PRECONF_WHITELIST_ADDRESS": contracts_addresses.preconf_whitelist,
        "PRECONF_ROUTER_ADDRESS": contracts_addresses.preconf_router,
        "TAIKO_WRAPPER_ADDRESS": contracts_addresses.taiko_wrapper,
        "TAIKO_CHAIN_ID": "167001",
        "L1_CHAIN_ID": l1_chain_id,
        "VALIDATOR_BLS_PRIVATEKEY": first_validator_bls_private_key,
        "VALIDATOR_INDEX": str(first_validator_index),
        # "MEV_BOOST_URL": mev_boost_url,
        "L1_WS_RPC_URL": el_context.ws_url,
        "L1_BEACON_URL": cl_context.beacon_http_url,
        "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info,p2p_network=info,libp2p_gossipsub=info,discv5=info,netlink_proto=info",
        "P2P_ADDRESS": "avs_ip_placeholder",
        "ENABLE_PRECONFIRMATION": "true",
        "TAIKO_GETH_WS_RPC_URL": taiko_stack.ws_url,
        "TAIKO_GETH_AUTH_RPC_URL": taiko_stack.auth_url,
        "TAIKO_DRIVER_URL": taiko_stack.driver_url,
        "MAX_BLOCKS_PER_BATCH": "4",
        "JWT_SECRET_FILE_PATH":"/data/taiko-geth/geth/jwtsecret",
        "SIMULATE_NOT_SUBMITTING_AT_THE_END_OF_EPOCH": simulate_not_submitting_at_the_end_of_epoch,
    }

    # For each service, we'll create env_vars by combining base_env_vars with service-specific vars
    def create_service_env_vars(additional_vars):
        env_vars = dict(base_env_vars)
        env_vars.update(additional_vars)
        return env_vars

    avs_node = plan.add_service(
        name = "taiko-preconf-avs-{0}".format(taiko_stack_index),
        config = ServiceConfig(
            files = {
                "/data/taiko-geth".format(taiko_stack_index): "taiko_genesis_{0}".format(taiko_stack_index),
            },
            image = image,
            private_ip_address_placeholder = "avs_ip_placeholder",
            env_vars=create_service_env_vars({
                "AVS_NODE_ECDSA_PRIVATE_KEY": PRIVATE_KEY_OPERATOR,
            }),
            ports = {
                "metrics-port": PortSpec(
                    number=9898, transport_protocol="TCP", wait=None
                ),
            },
        ),
        description = "Start AVS",
    )

    return prometheus.new_metrics_job(
        job_name="{0}-{1}".format(SERVICE_NAME,taiko_stack_index),
        endpoint="{0}:{1}".format(
            avs_node.ip_address, METRICS_PORT_NUMBER
        ),
        metrics_path=METRICS_PATH,
        labels={
            "service": "{0}-{1}".format(SERVICE_NAME,taiko_stack_index),
        },
    )


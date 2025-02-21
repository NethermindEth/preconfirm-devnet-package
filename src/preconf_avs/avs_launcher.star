def launch(
    plan,
    image,
    chain_id,
    el_context,
    cl_context,
    p2pbootnode_context,
    taiko_stack,
    mev_boost_context,
    prefunded_accounts,
    first_validator_bls_private_key,
    first_validator_index,
    # second_validator_bls_private_key,
    # second_validator_index,
    index,
    contracts_addresses,
):
    mev_boost_url = "http://{0}:{1}".format(
        mev_boost_context.private_ip_address, mev_boost_context.port
    )

    # Common environment variables
    base_env_vars = {
        "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": contracts_addresses.preconf_task_manager,
        "AVS_DIRECTORY_CONTRACT_ADDRESS": contracts_addresses.avs_directory,
        "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": contracts_addresses.service_manager,
        "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": contracts_addresses.preconf_registry,
        "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": contracts_addresses.strategy_manager,
        "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": contracts_addresses.slasher,
        "TAIKO_L1_ADDRESS": contracts_addresses.taiko_l1,
        "TAIKO_CHAIN_ID": "167000",
        "L1_CHAIN_ID": chain_id,
        "VALIDATOR_BLS_PRIVATEKEY": first_validator_bls_private_key,
        "VALIDATOR_INDEX": str(first_validator_index),
        "TAIKO_GETH_URL": taiko_stack.proposer_url,
        "TAIKO_DRIVER_URL": taiko_stack.driver_url,
        "MEV_BOOST_URL": mev_boost_url,
        "L1_WS_RPC_URL": el_context.ws_url,
        "L1_BEACON_URL": cl_context.beacon_http_url,
        "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info,p2p_network=info,libp2p_gossipsub=info,discv5=info,netlink_proto=info",
        "P2P_ADDRESS": "avs_ip_placeholder",
        "P2P_BOOTNODE_ENR": str(p2pbootnode_context.bootnode_enr),
        "JWT_SECRET_FILE_PATH":"/data/taiko-geth/geth/jwtsecret",
    }

    # For each service, we'll create env_vars by combining base_env_vars with service-specific vars
    def create_service_env_vars(additional_vars):
        env_vars = dict(base_env_vars)
        env_vars.update(additional_vars)
        return env_vars

    plan.add_service(
        name = "taiko-preconf-avs-{0}-register".format(index),
        config = ServiceConfig(
            image = image,
            private_ip_address_placeholder = "avs_ip_placeholder",
            entrypoint = ["sleep"],
            cmd = ["infinity"],
            env_vars = create_service_env_vars({
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "ENABLE_P2P": "false",
            }),
        ),
        description = "Start AVS container for registering",
    )

    plan.exec(
        service_name = "taiko-preconf-avs-{0}-register".format(index),
        description = "Register validator to AVS",
        recipe = ExecRecipe(
            command = [
                "taiko_preconf_avs_node",
                "--register",
            ],
        ),
    )

    plan.add_service(
        name = "taiko-preconf-avs-{0}-validator".format(index),
        config = ServiceConfig(
            image = image,
            private_ip_address_placeholder = "avs_ip_placeholder",
            entrypoint = ["sleep"],
            cmd = ["infinity"],
            env_vars=create_service_env_vars({
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "ENABLE_P2P": "false",
            }),
        ),
        description = "Start AVS container for adding validator",
    )

    plan.exec(
        service_name = "taiko-preconf-avs-{0}-validator".format(index),
        description = "Add validator to AVS",
        recipe = ExecRecipe(
            command = [
                "taiko_preconf_avs_node",
                "--add-validator",
            ],
        ),
    )

    plan.add_service(
        name = "taiko-preconf-avs-{0}".format(index),
        config = ServiceConfig(
            files = {
                "/data/taiko-geth".format(index): "taiko_genesis_{0}".format(index),
            },
            image = image,
            private_ip_address_placeholder = "avs_ip_placeholder",
            env_vars=create_service_env_vars({
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "ENABLE_P2P": "true",
            }),
        ),
        description = "Start AVS",
    )

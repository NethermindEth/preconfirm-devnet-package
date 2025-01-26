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
):
    # Centralized contract addresses
    contract_addresses = {
        "AVS_PRECONF_TASK_MANAGER": "0x55F28E20b194f31D473D901342a3c04932129bDC",
        "AVS_DIRECTORY": "0xe21c9cfea094aAbE99C96D56281a00876F97258a",
        "AVS_SERVICE_MANAGER": "0x9BDD6f66532C9355178B715F2383761045e6095f",
        "AVS_PRECONF_REGISTRY": "0xf2bD68421A73821368eEefaCB420FFdFa0237c86",
        "EIGEN_LAYER_STRATEGY_MANAGER": "0xDeeea509217cACA34A4f42ae76B046F263b06494",
        "EIGEN_LAYER_SLASHER": "0x545Bf1989eb37DE660600D9F1b7eFEBcb8199561",
        "TAIKO_L1": "0x57E5d642648F54973e504f10D21Ea06360151cAf",
    }

    mev_boost_url = "http://{0}:{1}".format(
        mev_boost_context.private_ip_address, mev_boost_context.port
    )

    # Common environment variables
    base_env_vars = {
        "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": contract_addresses["AVS_PRECONF_TASK_MANAGER"],
        "AVS_DIRECTORY_CONTRACT_ADDRESS": contract_addresses["AVS_DIRECTORY"],
        "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": contract_addresses["AVS_SERVICE_MANAGER"],
        "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": contract_addresses["AVS_PRECONF_REGISTRY"],
        "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": contract_addresses["EIGEN_LAYER_STRATEGY_MANAGER"],
        "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": contract_addresses["EIGEN_LAYER_SLASHER"],
        "TAIKO_L1_ADDRESS": contract_addresses["TAIKO_L1"],
        "TAIKO_CHAIN_ID": "167000",
        "L1_CHAIN_ID": chain_id,
        "VALIDATOR_BLS_PRIVATEKEY": first_validator_bls_private_key,
        "VALIDATOR_INDEX": str(first_validator_index),
        "TAIKO_PROPOSER_URL": taiko_stack.proposer_url,
        "TAIKO_DRIVER_URL": taiko_stack.driver_url,
        "MEV_BOOST_URL": mev_boost_url,
        "L1_WS_RPC_URL": el_context.ws_url,
        "L1_BEACON_URL": cl_context.beacon_http_url,
        "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info,p2p_network=info,libp2p_gossipsub=info,discv5=info,netlink_proto=info",
        "P2P_ADDRESS": "avs_ip_placeholder",
        "P2P_BOOTNODE_ENR": str(p2pbootnode_context.bootnode_enr),
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
            image = image,
            private_ip_address_placeholder = "avs_ip_placeholder",
            env_vars=create_service_env_vars({
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "ENABLE_P2P": "true",
            }),
        ),
        description = "Start AVS",
    )

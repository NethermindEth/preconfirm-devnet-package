def launch(
    plan,
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
    mev_boost_url = "http://{0}:{1}".format(
        mev_boost_context.private_ip_address, mev_boost_context.port
    )

    plan.add_service(
        name = "taiko-preconf-avs-{0}-register".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/avs-node:e2e",
            private_ip_address_placeholder = "avs_ip_placeholder",
            entrypoint = [
                "/bin/bash",
            ],
            cmd = [
                "-c",
                "sleep infinity",
            ],
            env_vars={
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
                "AVS_DIRECTORY_CONTRACT_ADDRESS": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
                "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": "0x1912A7496314854fB890B1B88C0f1Ced653C1830",
                "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": "0x9D2ea2038CF6009F1Bc57E32818204726DfA63Cd",
                "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": "0xaDe68b4b6410aDB1578896dcFba75283477b6b01",
                "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
                "VALIDATOR_BLS_PRIVATEKEY": first_validator_bls_private_key,
                "TAIKO_CHAIN_ID": "167000",
                "L1_CHAIN_ID": chain_id,
                "TAIKO_L1_ADDRESS": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
                "VALIDATOR_INDEX": str(first_validator_index),
                "TAIKO_PROPOSER_URL": taiko_stack.proposer_url,
                "TAIKO_DRIVER_URL": taiko_stack.driver_url,
                "MEV_BOOST_URL": mev_boost_url,
                "L1_WS_RPC_URL": el_context.ws_url,
                "L1_BEACON_URL": cl_context.beacon_http_url,
                "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info,p2p_network=info,libp2p_gossipsub=info,discv5=info,netlink_proto=info",
                # P2P
                "P2P_ADDRESS": "avs_ip_placeholder",
                "ENABLE_P2P": "true",
                "P2P_BOOTNODE_ENR": str(p2pbootnode_context.bootnode_enr),
            },
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
        name = "taiko-preconf-avs-{0}-validator-1".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/avs-node:e2e",
            private_ip_address_placeholder = "avs_ip_placeholder",
            entrypoint = [
                "/bin/bash",
            ],
            cmd = [
                "-c",
                "sleep infinity",
            ],
            env_vars={
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
                "AVS_DIRECTORY_CONTRACT_ADDRESS": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
                "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": "0x1912A7496314854fB890B1B88C0f1Ced653C1830",
                "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": "0x9D2ea2038CF6009F1Bc57E32818204726DfA63Cd",
                "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": "0xaDe68b4b6410aDB1578896dcFba75283477b6b01",
                "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
                "VALIDATOR_BLS_PRIVATEKEY": first_validator_bls_private_key,
                "TAIKO_CHAIN_ID": "167000",
                "L1_CHAIN_ID": chain_id,
                "TAIKO_L1_ADDRESS": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
                "VALIDATOR_INDEX": str(first_validator_index),
                "TAIKO_PROPOSER_URL": taiko_stack.proposer_url,
                "TAIKO_DRIVER_URL": taiko_stack.driver_url,
                "MEV_BOOST_URL": mev_boost_url,
                "L1_WS_RPC_URL": el_context.ws_url,
                "L1_BEACON_URL": cl_context.beacon_http_url,
                "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info,p2p_network=info,libp2p_gossipsub=info,discv5=info,netlink_proto=info",
                # P2P
                "P2P_ADDRESS": "avs_ip_placeholder",
                "ENABLE_P2P": "true",
                "P2P_BOOTNODE_ENR": str(p2pbootnode_context.bootnode_enr),
            },
        ),
        description = "Start AVS container for adding validator",
    )

    plan.exec(
        service_name = "taiko-preconf-avs-{0}-validator-1".format(index),
        description = "Add validator to AVS",
        recipe = ExecRecipe(
            command = [
                "taiko_preconf_avs_node",
                "--add-validator",
            ],
        ),
    )

    # plan.add_service(
    #     name = "taiko-preconf-avs-{0}-validator-2".format(index),
    #     config = ServiceConfig(
    #         image = "nethswitchboard/avs-node:e2e",
    #         private_ip_address_placeholder = "avs_ip_placeholder",
    #         entrypoint = [
    #             "/bin/bash",
    #         ],
    #         cmd = [
    #             "-c",
    #             "sleep infinity",
    #         ],
    #         env_vars={
    #             "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
    #             "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
    #             "AVS_DIRECTORY_CONTRACT_ADDRESS": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
    #             "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": "0x1912A7496314854fB890B1B88C0f1Ced653C1830",
    #             "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": "0x9D2ea2038CF6009F1Bc57E32818204726DfA63Cd",
    #             "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": "0xaDe68b4b6410aDB1578896dcFba75283477b6b01",
    #             "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
    #             "VALIDATOR_BLS_PRIVATEKEY": second_validator_bls_private_key,
    #             "TAIKO_CHAIN_ID": "167000",
    #             "L1_CHAIN_ID": chain_id,
    #             "TAIKO_L1_ADDRESS": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
    #             "VALIDATOR_INDEX": str(second_validator_index),
    #             "TAIKO_PROPOSER_URL": taiko_stack.proposer_url,
    #             "TAIKO_DRIVER_URL": taiko_stack.driver_url,
    #             "MEV_BOOST_URL": mev_boost_url,
    #             "L1_WS_RPC_URL": el_context.ws_url,
    #             "L1_BEACON_URL": cl_context.beacon_http_url,
    #             "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info,p2p_network=info,libp2p_gossipsub=info,discv5=info,netlink_proto=info",
    #             # P2P
    #             "P2P_ADDRESS": "avs_ip_placeholder",
    #             "ENABLE_P2P": "true",
    #             "P2P_BOOTNODE_ENR": str(p2pbootnode_context.bootnode_enr),
    #         },
    #     ),
    #     description = "Start AVS container for adding validator",
    # )

    # plan.exec(
    #     service_name = "taiko-preconf-avs-{0}-validator-2".format(index),
    #     description = "Add validator to AVS",
    #     recipe = ExecRecipe(
    #         command = [
    #             "taiko_preconf_avs_node",
    #             "--add-validator",
    #         ],
    #     ),
    # )

    plan.add_service(
        name = "taiko-preconf-avs-{0}".format(index),
        config = ServiceConfig(
            image = "nethswitchboard/avs-node:e2e",
            private_ip_address_placeholder = "avs_ip_placeholder",
            env_vars={
                "AVS_NODE_ECDSA_PRIVATE_KEY": "0x{0}".format(prefunded_accounts[index].private_key),
                "AVS_PRECONF_TASK_MANAGER_CONTRACT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
                "AVS_DIRECTORY_CONTRACT_ADDRESS": "0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B",
                "AVS_SERVICE_MANAGER_CONTRACT_ADDRESS": "0x1912A7496314854fB890B1B88C0f1Ced653C1830",
                "AVS_PRECONF_REGISTRY_CONTRACT_ADDRESS": "0x9D2ea2038CF6009F1Bc57E32818204726DfA63Cd",
                "EIGEN_LAYER_STRATEGY_MANAGER_CONTRACT_ADDRESS": "0xaDe68b4b6410aDB1578896dcFba75283477b6b01",
                "EIGEN_LAYER_SLASHER_CONTRACT_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
                "VALIDATOR_BLS_PRIVATEKEY": first_validator_bls_private_key,
                "TAIKO_CHAIN_ID": "167000",
                "L1_CHAIN_ID": chain_id,
                "TAIKO_L1_ADDRESS": "0x086f77C5686dfe3F2f8FE487C5f8d357952C8556",
                "VALIDATOR_INDEX": str(first_validator_index),
                "TAIKO_PROPOSER_URL": taiko_stack.proposer_url,
                "TAIKO_DRIVER_URL": taiko_stack.driver_url,
                "MEV_BOOST_URL": mev_boost_url,
                "L1_WS_RPC_URL": el_context.ws_url,
                "L1_BEACON_URL": cl_context.beacon_http_url,
                "RUST_LOG": "debug,reqwest=info,hyper=info,alloy_transport=info,alloy_rpc_client=info,p2p_network=info,libp2p_gossipsub=info,discv5=info,netlink_proto=info",
                # P2P
                "P2P_ADDRESS": "avs_ip_placeholder",
                "ENABLE_P2P": "true",
                "P2P_BOOTNODE_ENR": str(p2pbootnode_context.bootnode_enr),
            },
        ),
        description = "Start AVS",
    )

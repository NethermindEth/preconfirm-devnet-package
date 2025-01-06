SOLIDITY_SCRIPT_PATH = "./script/layer1/DeployProtocolOnL1.s.sol:DeployProtocolOnL1"

def deploy(
    plan,
    taiko_params,
    prefunded_account,
    el_rpc_url,
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(prefunded_account.private_key)

    ENV_VARS = {
        "PROPOSER": "0x0000000000000000000000000000000000000000",
        "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
        "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
        "TAIKO_L2_ADDRESS": "0x{0}0000000000000000000000000000000001".format(taiko_params.taiko_protocol_l2_network_id),
        "L2_SIGNAL_SERVICE": "0x{0}0000000000000000000000000000000005".format(taiko_params.taiko_protocol_l2_network_id),
        "CONTRACT_OWNER": prefunded_account.address,
        "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
        "PAUSE_TAIKO_L1": "false",
        "PAUSE_BRIDGE": "false",
        "NUM_MIN_MAJORITY_GUARDIANS": "7",
        "NUM_MIN_MINORITY_GUARDIANS": "2",
        "TIER_PROVIDER": "composite",
        "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
        # "L2_CHAINID": taiko_params.taiko_protocol_l2_network_id,
        "L2_GENESIS_HASH": taiko_params.taiko_protocol_l2_genesis_hash,
        # "OWNER_MULTISIG": "0x{0}0000000000000000000000000000000001".format(taiko_params.taiko_protocol_l2_network_id),
        # "OWNER_MULTISIG_SIGNERS": "0x{0}0000000000000000000000000000000002,0x{0}0000000000000000000000000000000003,0x{0}0000000000000000000000000000000004".format(taiko_params.taiko_protocol_l2_network_id),
        # "ATTESTATION_CONTRACT_OWNER": prefunded_account.address,
        # "RISC0_VERIFIER_OWNER": prefunded_account.address,
        "FOUNDRY_PROFILE": taiko_params.taiko_protocol_foundry_profile,
        "FORGE_FLAGS": "--broadcast --ffi -vv --block-gas-limit 200000000",
    }

    plan.run_sh(
        run = "forge script {0} {1} {2} $FORGE_FLAGS".format(SOLIDITY_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        name = "taiko-on-l1",
        # Protocol Image
        image = taiko_params.taiko_protocol_image,
        env_vars = ENV_VARS,
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_on_l1_deployment")],
        wait = None,
        description = "Deploying taiko on l1",
    )

    plan.add_service(
        name = "taiko-on-l1-result",
        config = ServiceConfig(
            image = "badouralix/curl-jq",
            files = {
                "/test": "taiko_on_l1_deployment",
            },
        ),
    )

    result = plan.exec(
        service_name = "taiko-on-l1-result",
        recipe = ExecRecipe(
            command = ["/bin/sh", "-c", "cat /test/deploy_l1.json"],
            extract = {
                "PemCertChainLib": "fromjson | .PemCertChainLib",
                "automata_dcap_attestation": "fromjson | .automata_dcap_attestation",
                "bridge": "fromjson | .bridge",
                "erc1155_vault": "fromjson | .erc1155_vault",
                "erc20_vault": "fromjson | .erc20_vault",
                "erc721_vault": "fromjson | .erc721_vault",
                "rollup_address_manager": "fromjson | .rollup_address_manager",
                "shared_address_manager": "fromjson | .shared_address_manager",
                "signal_service": "fromjson | .signal_service",
                "taiko": "fromjson | .taiko",
                "tier_sgx": "fromjson | .tier_sgx",
                "tier_zkvm_risc0": "fromjson | .tier_zkvm_risc0",
                "tier_zkvm_sp1": "fromjson | .tier_zkvm_sp1",
                "tier_two_of_three": "fromjson | .tier_two_of_three",
            }
        ),
    )

    return struct(
        pem_cert_chain_lib = result["extract.PemCertChainLib"],
        automata_dcap_attestation = result["extract.automata_dcap_attestation"],
        bridge = result["extract.bridge"],
        erc1155_vault = result["extract.erc1155_vault"],
        erc20_vault = result["extract.erc20_vault"],
        erc721_vault = result["extract.erc721_vault"],
        rollup_address_manager = result["extract.rollup_address_manager"],
        shared_address_manager = result["extract.shared_address_manager"],
        signal_service = result["extract.signal_service"],
        taiko = result["extract.taiko"],
        tier_sgx = result["extract.tier_sgx"],
        tier_zkvm_risc0 = result["extract.tier_zkvm_risc0"],
        tier_zkvm_sp1 = result["extract.tier_zkvm_sp1"],
        tier_two_of_three = result["extract.tier_two_of_three"],
    )

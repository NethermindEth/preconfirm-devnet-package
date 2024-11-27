SOLIDITY_SCRIPT_PATH = "./script/layer1/DeployProtocolOnL1.s.sol"

def deploy(
    plan,
    taiko_params,
    prefunded_account,
    el_rpc_url,
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(prefunded_account.private_key)

    ENV_VARS = {
        "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
        "CONTRACT_OWNER": prefunded_account.address,
        "PROPOSER": "0x0000000000000000000000000000000000000000",
        "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
        "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
        "TAIKO_L2_ADDRESS": "0x{0}0000000000000000000000000000010001".format(taiko_params.taiko_protocol_l2_network_id),
        "L2_SIGNAL_SERVICE": "0x{0}0000000000000000000000000000000005".format(taiko_params.taiko_protocol_l2_network_id),
        "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
        "L2_GENESIS_HASH": taiko_params.taiko_protocol_l2_genesis_hash,
        "PAUSE_TAIKO_L1": "false",
        "PAUSE_BRIDGE": "false",
        "NUM_MIN_MAJORITY_GUARDIANS": "7",
        "NUM_MIN_MINORITY_GUARDIANS": "2",
        "TIER_PROVIDER": "devnet_sgx",
        "FOUNDRY_PROFILE": taiko_params.taiko_protocol_foundry_profile,
        "FORGE_FLAGS": "--broadcast --ffi -vv --block-gas-limit 100000000",
    }

    deployment_result = plan.run_sh(
        run = "forge script {0} {1} {2} $FORGE_FLAGS".format(SOLIDITY_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        name = "taiko-on-l1",
        # Protocol Image
        image = taiko_params.taiko_protocol_image,
        env_vars = ENV_VARS,
        wait = None,
        description = "Deploying taiko on l1",
    )

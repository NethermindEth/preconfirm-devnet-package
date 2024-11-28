SOLIDITY_SCRIPT_PATH = "./script/layer1/DeploySurgeOnL1.s.sol:DeploySurgeOnL1"

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
        "L2_CHAINID": taiko_params.taiko_protocol_l2_network_id,
        "L2_GENESIS_HASH": taiko_params.taiko_protocol_l2_genesis_hash,
        "OWNER_MULTISIG": "0x{0}0000000000000000000000000000000001".format(taiko_params.taiko_protocol_l2_network_id),
        "OWNER_MULTISIG_SIGNERS": "0x{0}0000000000000000000000000000000002,0x{0}0000000000000000000000000000000003,0x{0}0000000000000000000000000000000004".format(taiko_params.taiko_protocol_l2_network_id),
        "ATTESTATION_CONTRACT_OWNER": prefunded_account.address,
        "RISC0_VERIFIER_OWNER": prefunded_account.address,
        "FOUNDRY_PROFILE": taiko_params.taiko_protocol_foundry_profile,
        "FORGE_FLAGS": "--broadcast --ffi -vv --block-gas-limit 200000000",
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

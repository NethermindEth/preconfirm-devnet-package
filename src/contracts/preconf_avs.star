AVS_SCRIPT_PATH = "./scripts/deployment/DeployAVS.s.sol:DeployAVS"

def deploy(
    plan,
    el_rpc_url,
    beacon_genesis_timestamp,
    contract_owner,
    avs_protocol_image,
    contracts_addresses,
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    plan.run_sh(
        name="deploy-avs-contract",
        description="Deploying preconf avs contract",
        run="forge script {0} {1} {2} $FORGE_FLAGS $EVM_VERSION_FLAG".format(AVS_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND)",
        image=avs_protocol_image,
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "BEACON_GENESIS_TIMESTAMP": beacon_genesis_timestamp,
            "BEACON_BLOCK_ROOT_CONTRACT": "0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02",
            "SLASHER": contracts_addresses.slasher,
            "AVS_DIRECTORY": contracts_addresses.avs_directory,
            "TAIKO_L1": contracts_addresses.taiko_l1,
            "TAIKO_TOKEN": contracts_addresses.taiko_token,
            "FORGE_FLAGS": "--broadcast --skip-simulation",
            "EVM_VERSION_FLAG": ""
        },
        wait=None,
        store = [StoreSpec(src = "app/scripts/deployment/deploy_avs.json", name = "avs_deployment")],
    )

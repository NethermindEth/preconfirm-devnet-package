TAIKO_SCRIPT_PATH = "./script/layer1/based/DeployProtocolOnL1.s.sol:DeployProtocolOnL1"
TOKEN_SCRIPT_PATH = "./script/layer1/based/DeployTaikoToken.s.sol:DeployTaikoToken"

def deploy(
    plan,
    genesis_timestamp,
    el_rpc_url,
    contract_owner,
    taiko_protocol_image,
    taiko_deploy_alethia_image,
    contracts_addresses,
    network_id,
    seconds_per_slot,
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    plan.print("Contract genesis_timestamp {0}".format(genesis_timestamp))

    env_vars = {
            "DEVNET_CHAIN_ID": network_id,
            "DEVNET_BEACON_GENESIS": genesis_timestamp,
            "DEVNET_SECONDS_IN_SLOT": seconds_per_slot,
            "DEVNET_OP_CHANGE_DELAY": "0",
            "DEVNET_RANDOMNESS_DELAY": "0",
            "FOUNDRY_PROFILE": "layer1",
            "L2_CHAIN_ID":"167001",
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "OLD_FORK_TAIKO_INBOX": "0x0000000000000000000000000000000000000000",
            "TAIKO_TOKEN": "0x0000000000000000000000000000000000000000",
            "TAIKO_ANCHOR_ADDRESS": contracts_addresses.taiko_l2,
            "L2_SIGNAL_SERVICE": "0x1670010000000000000000000000000000000005",
            "CONTRACT_OWNER": contract_owner.address,
            "PROVER_SET_ADMIN": contract_owner.address,
            "TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
            "TAIKO_TOKEN_NAME": "Taiko Token",
            "TAIKO_TOKEN_SYMBOL": "TAIKO",
            "SHARED_RESOLVER": "0x0000000000000000000000000000000000000000",
            "L2_GENESIS_HASH": "0x752b8b8a9b6b06e28f6f1daf061d259c6b8a896b6c3b1fb5e50216f8093833bb",
            "PAUSE_BRIDGE": "true",
            "DEPLOY_PRECONF_CONTRACTS": "true",
            "PRECONF_INBOX": "false",
            "PRECONF_ROUTER": "false",
            "INCLUSION_WINDOW": "24",
            "INCLUSION_FEE_IN_GWEI": "100",
            "DUMMY_VERIFIERS": "true",
            "PROPOSER_ADDRESS": contract_owner.address,
            "SECURITY_COUNCIL": contract_owner.address,
            "FORK_URL": el_rpc_url,
            "FORGE_FLAGS": "--broadcast --ffi -vvv --block-gas-limit 200000000",
        }

    alethia_deployment = plan.run_sh(
        name="deploy-taiko-contract-alethia",
        run="./setup.sh && forge script {0} {1} {2} $FORGE_FLAGS".format(TAIKO_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=taiko_deploy_alethia_image,
        env_vars=env_vars,
        wait=None,
        description="Deploying taiko alethia smart contracts",
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_alethia_on_l1_deployment")],
    )

    plan.run_sh(
        name="deploy-taiko-contract",
        run="./setup.sh && forge script {0} {1} {2} $FORGE_FLAGS".format(TAIKO_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=taiko_protocol_image,
        env_vars=env_vars,
        wait=None,
        description="Deploying taiko shasta smart contracts",
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_on_l1_deployment")]
    )


    # """
    # plan.run_sh(
    #     name="deploy-taiko-token",
    #     run="forge script {0} {1} {2} $FORGE_FLAGS".format(TOKEN_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
    #     image=taiko_protocol_image,
    #     env_vars={
    #         "FOUNDRY_PROFILE": "layer1",
    #         "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
    #         "TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
    #         "TAIKO_TOKEN_NAME": "Taiko Token",
    #         "TAIKO_TOKEN_SYMBOL": "TAIKO",
    #         "FORK_URL": el_rpc_url,
    #         "SECURITY_COUNCIL": contract_owner.address,
    #         "FORGE_FLAGS": "--broadcast --skip-simulation --ffi -vvvv --block-gas-limit 200000000",
    #     },
    #     wait=None,
    #     description="Deploying taiko token contract",
    #     store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_token_deployment")],
    # )
    # """

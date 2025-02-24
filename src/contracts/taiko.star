TAIKO_SCRIPT_PATH = "./script/layer1/preconf/DeployProtocolOnL1.s.sol:DeployProtocolOnL1"
TOKEN_SCRIPT_PATH = "./script/layer1/based/DeployTaikoToken.s.sol:DeployTaikoToken"

def deploy(
    plan,
    el_rpc_url,
    contract_owner,
    taiko_protocol_image,
    contracts_addresses
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    plan.run_sh(
        name="deploy-taiko-contract",
        run="forge script {0} {1} {2} $FORGE_FLAGS".format(TAIKO_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=taiko_protocol_image,
        env_vars={
            "FOUNDRY_PROFILE": "layer1",
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "OLD_FORK_TAIKO_INBOX": "0x0000000000000000000000000000000000000000",
            "TAIKO_ANCHOR_ADDRESS": contracts_addresses.taiko_l2,
            "L2_SIGNAL_SERVICE": "0x0167000000000000000000000000000000000005",
            "CONTRACT_OWNER": contract_owner.address,
            "PROVER_SET_ADMIN": contract_owner.address,
            "TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
            "TAIKO_TOKEN_NAME": "Taiko Token",
            "TAIKO_TOKEN_SYMBOL": "TAIKO",
            "SHARED_RESOLVER": "0x0000000000000000000000000000000000000000",
            "L2_GENESIS_HASH": "0x6ba76c827e4778193e36e7cfe30136899847b3b334f71b152f0b3118d56a4201",
            "PAUSE_BRIDGE": "true",
            "DEPLOY_PRECONF_CONTRACTS": "true",
            "INCLUSION_WINDOW": "24",
            "INCLUSION_FEE_IN_GWEI": "100",
            "TAIKO_TOKEN": "0x0000000000000000000000000000000000000000",
            "FORK_URL": el_rpc_url,
            "FORGE_FLAGS": "--broadcast --ffi -vvvv --block-gas-limit 200000000",
        },
        wait=None,
        description="Deploying taiko smart contract",
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_on_l1_deployment")],
    )

    plan.run_sh(
        name="deploy-taiko-token",
        run="forge script {0} {1} {2} $FORGE_FLAGS".format(TOKEN_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=taiko_protocol_image,
        env_vars={
            "FOUNDRY_PROFILE": "layer1",
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
            "TAIKO_TOKEN_NAME": "Taiko Token",
            "TAIKO_TOKEN_SYMBOL": "TAIKO",
            "FORK_URL": el_rpc_url,
            "SECURITY_COUNCIL": contract_owner.address,
            "FORGE_FLAGS": "--broadcast --skip-simulation --ffi -vvvv --block-gas-limit 200000000",
        },
        wait=None,
        description="Deploying taiko token contract",
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_token_deployment")],
    )
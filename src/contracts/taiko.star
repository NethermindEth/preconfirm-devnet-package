TAIKO_SCRIPT_PATH = "./script/layer1/DeployProtocolOnL1.s.sol:DeployProtocolOnL1"
TOKEN_SCRIPT_PATH = "./script/layer1/DeployTaikoToken.s.sol:DeployTaikoToken"

def deploy(
    plan,
    el_rpc_url,
    contract_owner,
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    plan.run_sh(
        name="deploy-taiko-contract",
        run="forge script {0} {1} {2} $FORGE_FLAGS".format(TAIKO_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        # image="nethswitchboard/taiko-deploy:e2e",
        image="nethsurge/test-protocol",
        env_vars={
            "FOUNDRY_PROFILE": "layer1",
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "PROPOSER": "0x0000000000000000000000000000000000000000",
            "TAIKO_TOKEN": "0x0000000000000000000000000000000000000000",
            "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
            "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
            "TAIKO_L2_ADDRESS": "0x1670000000000000000000000000000000010001",
            "L2_SIGNAL_SERVICE": "0x1670000000000000000000000000000000000005",
            "CONTRACT_OWNER": contract_owner.address,
            "PROVER_SET_ADMIN": contract_owner.address,
            "TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
            "TAIKO_TOKEN_NAME": "Taiko Token",
            "TAIKO_TOKEN_SYMBOL": "TAIKO",
            "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
            # "L2_GENESIS_HASH": "0x7983c69e31da54b8d244d8fef4714ee7a8ed25d873ebef204a56f082a73c9f1e",
            "L2_GENESIS_HASH": "0x7d621e96344cc0c1b32a6a53246ef76a46a046b009ee5d44b02ed69d4dabd4fb",
            "PAUSE_TAIKO_L1": "false",
            "PAUSE_BRIDGE": "true",
            "NUM_MIN_MAJORITY_GUARDIANS": "7",
            "NUM_MIN_MINORITY_GUARDIANS": "2",
            "TIER_ROUTER": "devnet",
            "FORK_URL": el_rpc_url,
            "SECURITY_COUNCIL": contract_owner.address,
            "FORGE_FLAGS": "--broadcast --ffi -vvvv --block-gas-limit 200000000",
        },
        wait=None,
        description="Deploying taiko smart contract",
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_on_l1_deployment")],
    )

    plan.run_sh(
        name="deploy-taiko-token",
        run="forge script {0} {1} {2} $FORGE_FLAGS".format(TOKEN_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        # image="nethswitchboard/taiko-deploy:e2e",
        image="nethsurge/test-protocol",
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
        description="Deploying taiko smart contract",
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_token_deployment")],
    )
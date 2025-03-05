TAIKO_SCRIPT_PATH = "./script/layer1/based/DeployProtocolOnL1.s.sol:DeployProtocolOnL1"
TOKEN_SCRIPT_PATH = "./script/layer1/based/DeployTaikoToken.s.sol:DeployTaikoToken"

def deploy(
    plan,
    genesis_timestamp,
    el_rpc_url,
    contract_owner,
    taiko_protocol_image,
    contracts_addresses
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    plan.print("Contract genesis_timestamp {0}".format(genesis_timestamp))

    plan.run_sh(
        name="deploy-taiko-contract",
        run="forge script {0} {1} {2} $FORGE_FLAGS".format(TAIKO_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=taiko_protocol_image,
        env_vars={
            "FOUNDRY_PROFILE": "layer1",
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
            "L2_GENESIS_HASH": "0x5b3ef9175dea8096ab43040166c3aa5417b8a7af3af4d3441945e30e08463d3d",
            "PAUSE_BRIDGE": "true",
            "DEPLOY_PRECONF_CONTRACTS": "true",
            "PRECONF_INBOX": "false",
            "INCLUSION_WINDOW": "24",
            "INCLUSION_FEE_IN_GWEI": "100",
            "FORK_URL": el_rpc_url,
            "GENESIS_TIMESTAMP": genesis_timestamp,
            "FORGE_FLAGS": "--broadcast --ffi -vvv --block-gas-limit 200000000",
        },
        wait=None,
        description="Deploying taiko smart contracts",
        store = [StoreSpec(src = "app/deployments/deploy_l1.json", name = "taiko_on_l1_deployment")],
    )

    RPC_URL_COMMAND = "--rpc-url {0}".format(el_rpc_url)

    plan.run_sh(
        name="add-operator",
        run="cast send 0x00CfaC4fF61D52771eF27d07c5b6f1263C2994A1 'addOperator(address)' {0} {1} {2}".format(contract_owner.address, PRIVATE_KEY_COMMAND, RPC_URL_COMMAND),
        image=taiko_protocol_image,
        wait=None,
        description="Adding operator to taiko",
    )

    plan.run_sh(
        name="approve",
        run="cast send 0x422A3492e218383753D8006C7Bfa97815B44373F 'approve(address,uint256)' 0x7E2E7DD2Aead92e2e6d05707F21D4C36004f8A2B 1000000000000000000000000 {1} {2}".format( PRIVATE_KEY_COMMAND, RPC_URL_COMMAND),
        image=taiko_protocol_image,
        wait=None,
        description="Approve taiko token",
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

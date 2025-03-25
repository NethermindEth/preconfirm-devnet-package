EIGENLAYER_MVP_SCRIPT = "DeployEigenlayerMVP.s.sol"
EIGENLAYER_MVP_SCRIPT_PATH = "./scripts/deployment/{0}:DeployEigenlayerMVP".format(EIGENLAYER_MVP_SCRIPT)
EIGENLAYER_MVP_SCRIPT_RESULT_PATH = "broadcast/{0}/3151908/run-latest.json".format(EIGENLAYER_MVP_SCRIPT)

def deploy(
    plan,
    el_rpc_url,
    contract_owner,
    avs_protocol_image,
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    eigenlayer_mvp = plan.run_sh(
        name="deploy-eigenlayer-contract",
        description="Deploying eigenlayer mvp contract",
        run="forge script {0} {1} {2} $FORGE_FLAGS $EVM_VERSION_FLAG".format(EIGENLAYER_MVP_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=avs_protocol_image,
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "FORGE_FLAGS": "--broadcast --skip-simulation",
            "EVM_VERSION_FLAG": ""
        },
        wait=None,
        store = [StoreSpec(src = "app/{0}".format(EIGENLAYER_MVP_SCRIPT_RESULT_PATH), name = "eigenlayer_mvp_deployment")],
    )

    plan.add_service(
        name = "eigenlayer-mvp-result",
        config = ServiceConfig(
            image = "badouralix/curl-jq",
            files = {
                "/result": "eigenlayer_mvp_deployment",
            },
        ),
    )

    result = plan.exec(
        service_name = "eigenlayer-mvp-result",
        recipe = ExecRecipe(
            command = [
                "/bin/sh", 
                "-c",
                "cat /result/run-latest.json | jq '[.transactions[] | select(.contractName) | {key: .contractName, value: .contractAddress}] | from_entries'",
            ],
            extract = {
                "ProxyAdmin": "fromjson.ProxyAdmin",
                "AVSDirectory": "fromjson.AVSDirectory",
                "DelegationManager": "fromjson.DelegationManager",
                "StrategyManager": "fromjson.StrategyManager",
                "Slasher": "fromjson.Slasher",
            }
        ),
    )
    
    return struct(
        proxy_admin = result["extract.ProxyAdmin"],
        avs_directory = result["extract.AVSDirectory"],
        delegation_manager = result["extract.DelegationManager"],
        strategy_manager = result["extract.StrategyManager"],
        slasher = result["extract.Slasher"],
    )

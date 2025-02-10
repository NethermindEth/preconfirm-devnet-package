TOKEN_SCRIPT = "DeployTaikoToken.s.sol"
TOKEN_SCRIPT_PATH = "./script/layer1/{0}:DeployTaikoToken".format(TOKEN_SCRIPT)
TOKEN_SCRIPT_RESULT_PATH = "broadcast/{0}/3151908/run-latest.json".format(TOKEN_SCRIPT)

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
            "FORGE_FLAGS": "--broadcast --skip-simulation --ffi -vvv --block-gas-limit 200000000",
        },
        wait=None,
        description="Deploying taiko token contract",
        store = [StoreSpec(src = "app/{0}".format(TOKEN_SCRIPT_RESULT_PATH), name = "taiko_token_deployment")],
    )


    plan.add_service(
        name = "taiko-token-result",
        config = ServiceConfig(
            image = "badouralix/curl-jq",
            files = {
                "/result": "taiko_token_deployment",
            },
        ),
    )

    result = plan.exec(
        service_name = "taiko-token-result",
        recipe = ExecRecipe(
            command = [
                "/bin/sh", 
                "-c", 
                "cat /result/run-latest.json | jq '[.transactions[] | select(.contractName) | {key: .contractName, value: .contractAddress}] | from_entries'",
            ],
            extract = {
                "TaikoToken": "fromjson.TaikoToken",
                "ERC1967Proxy": "fromjson.ERC1967Proxy",
            }
        ),
    )
    
    return struct(
        taiko_token = result["extract.TaikoToken"],
        erc1967_proxy = result["extract.ERC1967Proxy"],
    )

AVS_SCRIPT = "DeployAVS.s.sol"
AVS_SCRIPT_PATH = "./scripts/deployment/{0}:DeployAVS".format(AVS_SCRIPT)

def deploy(
    plan,
    el_rpc_url,
    final_genesis_timestamp,
    contract_owner,
    avs_protocol_image,
    contracts_addresses,
):

    # Get beacon genesis timestamp for avs contracts
    beacon_genesis_timestamp = plan.run_python(
        description="Getting final beacon genesis timestamp",
        run="""
import sys
new = int(sys.argv[1]) + 20
print(new, end="")
            """,
        args=[str(final_genesis_timestamp)],
        store=[StoreSpec(src="/tmp", name="beacon-genesis-timestamp")],
    )

    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    plan.run_sh(
        name="deploy-avs-contract",
        description="Deploying preconf avs contract",
        run="forge script {0} {1} {2} $FORGE_FLAGS $EVM_VERSION_FLAG".format(AVS_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=avs_protocol_image,
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "BEACON_GENESIS_TIMESTAMP": beacon_genesis_timestamp.output,
            "BEACON_BLOCK_ROOT_CONTRACT": "0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02",
            "SLASHER": contracts_addresses.slasher,
            "AVS_DIRECTORY": contracts_addresses.avs_directory,
            "TAIKO_L1": contracts_addresses.taiko_l1,
            "TAIKO_TOKEN": contracts_addresses.taiko_token,
            "FORGE_FLAGS": "--broadcast --skip-simulation",
            "EVM_VERSION_FLAG": ""
        },
        wait=None,
        store = [StoreSpec(src = "app/broadcast/{0}/3151908/run-latest.json".format(AVS_SCRIPT), name = "avs_deployment")],
    )

    plan.add_service(
        name = "avs-result",
        config = ServiceConfig(
            image = "badouralix/curl-jq",
            files = {
                "/result": "avs_deployment",
            },
        ),
    )

    result = plan.exec(
        service_name = "avs-result",
        recipe = ExecRecipe(
            command = [
                "/bin/sh", 
                "-c",
                "cat /result/run-latest.json | jq '[.transactions[] | select(.contractName) | {key: .contractName, value: .contractAddress}] | from_entries'",
            ],
            extract = {
                "ProxyAdmin": "fromjson.ProxyAdmin",
                "TransparentUpgradeableProxy": "fromjson.TransparentUpgradeableProxy",
                "PreconfRegistry": "fromjson.PreconfRegistry",
                "PreconfServiceManager": "fromjson.PreconfServiceManager",
                "PreconfTaskManager": "fromjson.PreconfTaskManager",
            }
        ),
    )
    
    return struct(
        proxy_admin = result["extract.ProxyAdmin"],
        transparent_upgradeable_proxy = result["extract.TransparentUpgradeableProxy"],
        preconf_registry = result["extract.PreconfRegistry"],
        preconf_service_manager = result["extract.PreconfServiceManager"],
        preconf_task_manager = result["extract.PreconfTaskManager"],
    )

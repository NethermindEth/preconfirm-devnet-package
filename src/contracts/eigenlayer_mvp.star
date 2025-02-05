EIGENLAYER_MVP_SCRIPT_PATH = "./scripts/deployment/DeployEigenlayerMVP.s.sol:DeployEigenlayerMVP"

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
        run="forge script {0} {1} {2} $FORGE_FLAGS $EVM_VERSION_FLAG".format(AVS_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND)",
        image=avs_protocol_image,
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "FORGE_FLAGS": "--broadcast --skip-simulation",
            "EVM_VERSION_FLAG": ""
        },
        wait=None,
        store = [StoreSpec(src = "app/scripts/deployment/deploy_eigenlayer_mvp.json", name = "eigenlayer_mvp_deployment")],
    )

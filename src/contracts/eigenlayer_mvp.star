def deploy(
    plan,
    el_rpc_url,
    contract_owner,
):
    eigenlayer_mvp = plan.run_sh(
        name="deploy-eigenlayer-contract",
        description="Deploying eigenlayer mvp contract",
        run="script/layer1/preconf/deployment/deploy_eigenlayer_mvp.sh",
        image="nethswitchboard/taiko-protocol-dev:latest",
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
        },
        wait=None,
        # store=[
        #     "/tmp/eigenlayer-mvp-output.txt"
        # ],
    )

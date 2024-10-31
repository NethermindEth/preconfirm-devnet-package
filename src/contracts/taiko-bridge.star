def deploy(
    plan,
    el_rpc_url,
    prefunded_account,
):
    taiko = plan.run_sh(
        name="deploy-taiko-bridge",
        run="script/layer1/deploy_bridge.sh",
        image="nethsurge/taiko-contract:taiko-bridge",
        env_vars={
            "FOUNDRY_PROFILE": "layer1",
            "DOMAIN": "167000",
            "ADDRESS": "0x1670000000000000000000000000000000000001",
            "NAME": "0x6272696467650000000000000000000000000000000000000000000000000000",
            "PROXY_ADDRESS": "0x0643D39D47CF0ea95Dbea69Bf11a7F8C4Bc34968",
            "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
            "FORK_URL": el_rpc_url,
        },
        wait=None,
        description="Deploying taiko bridgesmart contract",
    )

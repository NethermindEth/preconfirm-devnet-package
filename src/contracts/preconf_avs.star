def deploy(
    plan,
    el_rpc_url,
    beacon_genesis_timestamp,
    contract_owner,
):
    preconf_avs = plan.run_sh(
        name="deploy-preconf-avs-contract",
        description="Deploying preconf avs contract",
        run="scripts/deployment/deploy_avs.sh",
        image="nethswitchboard/avs-deploy:e2e",
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "BEACON_GENESIS_TIMESTAMP": beacon_genesis_timestamp,
            "BEACON_BLOCK_ROOT_CONTRACT": "0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02",
            "SLASHER": "0xDeeea509217cACA34A4f42ae76B046F263b06494",
            "AVS_DIRECTORY": "0xa3027Ac27EF8Ec6C3F2863Deb1D4e84a433F69Fc",
            "TAIKO_L1": "0x57E5d642648F54973e504f10D21Ea06360151cAf",
            "TAIKO_TOKEN": "0x72ae2643518179cF01bcA3278a37ceAD408DE8b2",
        },
        wait=None,
        # store=[
        #     "/tmp/avs-output.txt"
        # ],
    )

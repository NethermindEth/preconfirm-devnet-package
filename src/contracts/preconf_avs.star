def deploy(
    plan,
    el_rpc_url,
    beacon_genesis_timestamp,
    contract_owner,
    avs_protocol_image,
):
    preconf_avs = plan.run_sh(
        name="deploy-preconf-avs-contract",
        description="Deploying preconf avs contract",
        run="scripts/deployment/deploy_avs.sh",
        image=avs_protocol_image,
        env_vars = {
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "BEACON_GENESIS_TIMESTAMP": beacon_genesis_timestamp,
            "BEACON_BLOCK_ROOT_CONTRACT": "0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02",
            "SLASHER": "0x545Bf1989eb37DE660600D9F1b7eFEBcb8199561",
            "AVS_DIRECTORY": "0xe21c9cfea094aAbE99C96D56281a00876F97258a",
            "TAIKO_L1": "0xbFaC9e95F250952630Eef4ef62E602d0D37844fe",
            "TAIKO_TOKEN": "0xC2d8B5248F7A6439E667eAAB6148eC68abCC516B",
        },
        wait=None,
        # store=[
        #     "/tmp/avs-output.txt"
        # ],
    )

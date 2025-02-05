def deploy(
    plan,
    el_rpc_url,
    beacon_genesis_timestamp,
    contract_owner,
    avs_protocol_image,
    contracts_addresses,
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
            "SLASHER": contracts_addresses.slasher,
            "AVS_DIRECTORY": contracts_addresses.avs_directory,
            "TAIKO_L1": contracts_addresses.taiko_l1,
            "TAIKO_TOKEN": contracts_addresses.taiko_token,
        },
        wait=None,
        # store=[
        #     "/tmp/avs-output.txt"
        # ],
    )

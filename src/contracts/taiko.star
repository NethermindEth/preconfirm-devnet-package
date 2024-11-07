def deploy(
    plan,
    el_rpc_url,
    prefunded_account,
):
    taiko = plan.run_sh(
        name="deploy-taiko-contract",
        # run="script/layer1/deploy_protocol_on_l1.sh > /tmp/taiko-output.txt",
        run="script/layer1/deploy_protocol_on_l1.sh",
        image="nethsurge/taiko-contract:min-tiers",
        env_vars={
            "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
            "CONTRACT_OWNER": prefunded_account.address,
            "FORK_URL": el_rpc_url,
            "PROPOSER": "0x0000000000000000000000000000000000000000",
            "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
            "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
            "TAIKO_L2_ADDRESS": "0x1670000000000000000000000000000000010001",
            "L2_SIGNAL_SERVICE": "0x1670000000000000000000000000000000000005",
            "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
            "L2_GENESIS_HASH": "0xef9dd40d2e7b3f0d7ae4bd75ba24273245286f451e5c4f65736aca649a6ea76f",
            "PAUSE_TAIKO_L1": "false",
            "PAUSE_BRIDGE": "false",
            "NUM_MIN_MAJORITY_GUARDIANS": "7",
            "NUM_MIN_MINORITY_GUARDIANS": "2",
            "TIER_PROVIDER": "devnet_sgx",
            "FOUNDRY_PROFILE": "layer1",
        },
        wait=None,
        description="Deploying taiko smart contract",
        # store=[
        #     "/tmp/taiko-output.txt"
        # ],
    )

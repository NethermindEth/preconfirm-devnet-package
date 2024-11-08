def deploy(
    plan,
    el_rpc_url,
    prefunded_account,
):
    taiko = plan.run_sh(
        name="deploy-taiko-contract",
        # run="script/layer1/deploy_protocol_on_l1.sh > /tmp/taiko-output.txt",
        run="script/layer1/deploy_protocol_on_l1.sh",
        image="nethsurge/taiko-contract:chain-763374",
        env_vars={
            "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
            "CONTRACT_OWNER": prefunded_account.address,
            "FORK_URL": el_rpc_url,
            "PROPOSER": "0x0000000000000000000000000000000000000000",
            "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
            "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
            "TAIKO_L2_ADDRESS": "0x7633740000000000000000000000000000010001",
            "L2_SIGNAL_SERVICE": "0x7633740000000000000000000000000000000005",
            "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
            "L2_GENESIS_HASH": "0xbeced3738f1246571cccabc82a1e6cbd9ed9d5f7ed2b6c7ded28f9722317bd9e",
            "PAUSE_TAIKO_L1": "false",
            "PAUSE_BRIDGE": "false",
            "NUM_MIN_MAJORITY_GUARDIANS": "7",
            "NUM_MIN_MINORITY_GUARDIANS": "2",
            "TIER_PROVIDER": "devnet",
            "FOUNDRY_PROFILE": "layer1",
        },
        wait=None,
        description="Deploying taiko smart contract",
        # store=[
        #     "/tmp/taiko-output.txt"
        # ],
    )

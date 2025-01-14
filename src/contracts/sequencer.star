def deploy(
    plan,
    el_rpc_url,
    contract_owner,
):
    sequencer = plan.run_sh(
        name="deploy-add-to-sequencer",
        run="script/add_to_sequencer.sh",
        image="nethsurge/test-protocol",
        env_vars={
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "FORK_URL": el_rpc_url,
            "PROXY_ADDRESS": "0x454A310f46C8d9403ba6F6c514aD3fDE1ad97a5E",
            "ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
            "ENABLED": "true",
        },
        wait=None,
        description="Deploying add to sequencer",
        # store=[
        #     "/tmp/sequencer-output.txt"
        # ],
    )

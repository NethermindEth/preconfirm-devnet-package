def deploy(
    plan,
    el_rpc_url,
    prefunded_account,
):
    taiko = plan.run_sh(
        name="deploy-taiko-sgx-contract",
        run="script/layer1/config_sgx_tcb.sh",
        image="nethsurge/taiko-contract:sgx-tcb",
        env_vars={
            "SGX_VERIFIER_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
            "ATTESTATION_ADDRESS": "0xdFb2fAc1519eDA2b3ee1Edf578ee0509DC8633f7",
            "PEM_CERTCHAIN_ADDRESS": "0x86B28E406738f2928bE33D111A0B821BBC5610A2",
            "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
            "FORK_URL": el_rpc_url,
        },
        wait=None,
        description="Deploying taiko sgx contract",
    )

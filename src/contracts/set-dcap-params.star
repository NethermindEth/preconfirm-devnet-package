SOLIDITY_SCRIPT_PATH = "./script/layer1/SetDcapParams.s.sol:SetDcapParams"

TASK_ENABLE = "[1,1,1,1,1,1]"

QEID_PATH = "/script/automata-attestation/assets/qe_identity"

TCB_INFO_PATH = "/script/automata-attestation/assets/tcb"

def deploy(
    plan,
    taiko_params,
    prefunded_account,
    el_rpc_url,
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(prefunded_account.private_key)

    ENV_VARS = {
        "TASK_ENABLE": TASK_ENABLE,
        "MR_ENCLAVE": taiko_params.taiko_protocol_mr_enclave,
        "MR_SIGNER": taiko_params.taiko_protocol_mr_signer,
        "QEID_PATH": QEID_PATH,
        "TCB_INFO_PATH": TCB_INFO_PATH,
        "V3_QUOTE_BYTES": taiko_params.taiko_protocol_v3_quote_bytes,
        "SGX_VERIFIER_ADDRESS": "0x86A0679C7987B5BA9600affA994B78D0660088ff",
        "ATTESTATION_ADDRESS": "0xdFb2fAc1519eDA2b3ee1Edf578ee0509DC8633f7",
        "PEM_CERTCHAIN_ADDRESS": "0x86B28E406738f2928bE33D111A0B821BBC5610A2",
        "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
        "FORK_URL": el_rpc_url,
        "FORGE_FLAGS": "--broadcast --evm-version cancun --ffi -vvvv --block-gas-limit 100000000 --legacy",
    }

    deployment_result = plan.run_sh(
        run = "forge script {0} {1} {2} $FORGE_FLAGS".format(SOLIDITY_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),

        name = "set-dcap-params",

        image = taiko_params.taiko_protocol_image,
        env_vars = ENV_VARS,
        wait = None,
        description = "Deploying taiko SGX set dcap params",
    )

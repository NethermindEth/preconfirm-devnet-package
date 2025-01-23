SOLIDITY_SCRIPT_PATH = "./script/layer1/SetDcapParams.s.sol:SetDcapParams"

TASK_ENABLE = "[1,1,1,1,1,1]"

QEID_PATH = "/test/qe_identity"

TCB_INFO_PATH = "/test/tcb"

# Fetch collateral info from intel
FMSPC="00906ED50000"

TCB_FILE="test/tcb"

QE_IDENTITY_FILE="test/qe_identity"

TCB_LINK="https://api.trustedservices.intel.com/sgx/certification/v3/tcb?fmspc=${FMSPC}"

QE_IDENTITY_LINK="https://api.trustedservices.intel.com/sgx/certification/v3/qe/identity"

def deploy(
    plan,
    taiko_params,
    prefunded_account,
    el_rpc_url,
    deployment_result,
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
        "SGX_VERIFIER_ADDRESS": deployment_result.tier_sgx,
        "ATTESTATION_ADDRESS": deployment_result.automata_dcap_attestation,
        "PEM_CERTCHAIN_ADDRESS": deployment_result.pem_cert_chain_lib,
        "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
        "FORK_URL": el_rpc_url,
        "FORGE_FLAGS": "--broadcast --evm-version cancun --ffi -vvvv --block-gas-limit 100000000 --legacy",
        # Intel collateral info
        "FMSPC": FMSPC,
        "TCB_FILE": TCB_FILE,
        "QE_IDENTITY_FILE": QE_IDENTITY_FILE,
    }

    deployment_result = plan.run_sh(
        run = "curl -X GET {0} > {1} && curl -X GET {2} > {3} && jq '.tcbInfo.fmspc |= ascii_downcase' {1} > temp.json && mv temp.json {1} && forge script {4} {5} {6} $FORGE_FLAGS".format(TCB_LINK, TCB_FILE, QE_IDENTITY_LINK, QE_IDENTITY_FILE, SOLIDITY_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),

        name = "set-dcap-params",

        image = taiko_params.taiko_protocol_image,
        env_vars = ENV_VARS,
        wait = None,
        description = "Deploying taiko SGX set dcap params",
    )

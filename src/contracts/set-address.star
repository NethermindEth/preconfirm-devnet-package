SOLIDITY_SCRIPT_PATH = "./script/shared/SetAddress.s.sol"

def deploy(
    plan,
    taiko_params,
    prefunded_account,
    el_rpc_url,
):
    L1_SHARED_ADDRESS_MANAGER_ADDRESS = "0x0643D39D47CF0ea95Dbea69Bf11a7F8C4Bc34968"

    L2_BRIDGE_ADDRESS = "0x{0}0000000000000000000000000000000001".format(taiko_params.taiko_protocol_l2_network_id)

    L2_SIGNAL_SERVICE_ADDRESS = "0x{0}0000000000000000000000000000000005".format(taiko_params.taiko_protocol_l2_network_id)

    BRIDGE_32_BYTES = "0x6272696467650000000000000000000000000000000000000000000000000000"

    SIGNAL_SERVICE_32_BYTES = "0x7369676e616c5f73657276696365000000000000000000000000000000000000"

    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(prefunded_account.private_key)

    BRIDGE_ENV_VARS = {
        "FOUNDRY_PROFILE": taiko_params.taiko_protocol_foundry_profile,
        "DOMAIN": taiko_params.taiko_protocol_l2_network_id,
        # L2 Bridge Address
        "ADDRESS": L2_BRIDGE_ADDRESS,
        # Bridge 32 bytes
        "NAME": BRIDGE_32_BYTES,
        # L1 Shared Address Manager Address
        "PROXY_ADDRESS": L1_SHARED_ADDRESS_MANAGER_ADDRESS,
        "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
    }

    SIGNAL_SERVICE_ENV_VARS = {
        "FOUNDRY_PROFILE": taiko_params.taiko_protocol_foundry_profile,
        "DOMAIN": taiko_params.taiko_protocol_l2_network_id,
        # L2 Signal Service Address
        "ADDRESS": L2_SIGNAL_SERVICE_ADDRESS,
        # Bridge 32 bytes
        "NAME": SIGNAL_SERVICE_32_BYTES,
        # L1 Shared Address Manager Address
        "PROXY_ADDRESS": L1_SHARED_ADDRESS_MANAGER_ADDRESS,
        "PRIVATE_KEY": "0x{0}".format(prefunded_account.private_key),
    }

    bridge_deployment_result = plan.run_sh(
        run = "forge script {0} {1} {2} $FORGE_FLAGS".format(SOLIDITY_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        name = "bridge-set-address",
        image = taiko_params.taiko_protocol_image,
        env_vars = BRIDGE_ENV_VARS,
        wait = None,
        description = "Deploying taiko bridge set address",
    )

    signal_service_deployment_result = plan.run_sh(
        run = "forge script {0} {1} {2} $FORGE_FLAGS".format(SOLIDITY_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        name = "bridge-set-address",
        image = taiko_params.taiko_protocol_image,
        env_vars = SIGNAL_SERVICE_ENV_VARS,
        wait = None,
        description = "Deploying taiko signal service set address",
    )

taiko_on_l1_deployer = import_module("./taiko_on_l1.star")
taiko_token_deployer = import_module("./taiko_token.star")
eigenlayer_mvp_deployer = import_module("./eigenlayer_mvp.star")
avs_deployer = import_module("./deploy_avs.star")

def deploy(
    plan,
    final_genesis_timestamp,
    el_context,
    prefunded_accounts,
    network_id,
    taiko_protocol_image,
    avs_protocol_image,
    contracts_addresses,
):
    # Get el rpc url
    el_rpc_url = el_context.rpc_http_url

    # Get first prefunded account
    first_prefunded_account = prefunded_accounts[0]

    # Deploy taiko on l1 contracts
    taiko_on_l1_result = taiko_on_l1_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
        taiko_protocol_image,
        contracts_addresses,
    )

    # Deploy taiko token contracts
    taiko_token_result = taiko_token_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
        taiko_protocol_image,
        contracts_addresses,
    )

    # Deploy eigenlayer mvp contracts
    eigenlayer_mvp_result = eigenlayer_mvp_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
        avs_protocol_image,
    )

    # Deploy avs contracts
    avs_result = avs_deployer.deploy(
        plan,
        el_rpc_url,
        final_genesis_timestamp,
        first_prefunded_account,
        avs_protocol_image,
        contracts_addresses,
    )

    # Transfer taiko tokens
    transfer_result = plan.add_service(
        name = "taiko-transfer",
        description = "Transferring taiko tokens",
        config = ServiceConfig(
            image = "nethswitchboard/taiko-transfer:e2e",
            cmd = [
                "python",
                "transfer.py",
            ],
            env_vars = {
                "SENDER_PRIVATE_KEY": first_prefunded_account.private_key,
                "RECIPIENT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
                "TOKEN_AMOUNT": "1000000",
                "ERC20_ADDRESS": "0x4Af231e5E624038Cd40FC4fd5b86B39d13E1429e",
                "RPC_URL": el_rpc_url,
                "CHAIN_ID": network_id,
            },
        ),
    )

    return struct(
        taiko_on_l1_result = taiko_on_l1_result,
        taiko_token_result = taiko_token_result,
        eigenlayer_mvp_result = eigenlayer_mvp_result,
        avs_result = avs_result,
    )

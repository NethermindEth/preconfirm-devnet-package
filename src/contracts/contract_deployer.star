taiko_contract_deployer = import_module("./taiko.star")
eigenlayer_contract_deployer = import_module("./eigenlayer_mvp.star")
avs_contract_deployer = import_module("./preconf_avs.star")

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

    # Deploy taiko contracts
    taiko_contract_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
        taiko_protocol_image,
        contracts_addresses,
    )

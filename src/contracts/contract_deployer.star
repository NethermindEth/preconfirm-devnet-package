taiko_contract_deployer = import_module("./taiko.star")
# eigenlayer_contract_deployer = import_module("./eigenlayer_mvp.star")

def deploy(
    plan,
    genesis_timestamp,
    el_context,
    prefunded_accounts,
    network_id,
    taiko_protocol_image,
    taiko_deploy_alethia_image,
    contracts_addresses,
    seconds_per_slot,
):
    # Get el rpc url
    el_rpc_url = el_context.rpc_http_url

    # Get first prefunded account
    first_prefunded_account = prefunded_accounts[0]

    # Deploy taiko contracts
    taiko_contract_deployer.deploy(
        plan,
        genesis_timestamp,
        el_rpc_url,
        first_prefunded_account,
        taiko_protocol_image,
        taiko_deploy_alethia_image,
        contracts_addresses,
        network_id,
        seconds_per_slot,
    )

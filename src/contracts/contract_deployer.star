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

    # Deploy eigenlayer mvp contracts
    eigenlayer_contract_deployer.deploy(
        plan,
        el_rpc_url,
        first_prefunded_account,
        avs_protocol_image,
    )

    # Get beacon genesis timestamp for avs contracts
    beacon_genesis_timestamp = plan.run_python(
        description="Getting final beacon genesis timestamp",
        run="""
import sys
new = int(sys.argv[1]) + 20
print(new, end="")
            """,
        args=[str(final_genesis_timestamp)],
        store=[StoreSpec(src="/tmp", name="beacon-genesis-timestamp")],
    )

    # Deploy avs contracts
    avs_contract_deployer.deploy(
        plan,
        el_rpc_url,
        beacon_genesis_timestamp.output,
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

# Surge on L1
surge_on_l1 = import_module("./surge-on-l1.star")

# Taiko on L1
taiko_on_l1 = import_module("./taiko-on-l1.star")

# Taiko SetDcapParams
set_dcap_params = import_module("./set-dcap-params.star")

# Taiko SetAddress
set_address = import_module("./set-address.star")

# eigenlayer_contract_deployer = import_module("./eigenlayer_mvp.star")
# avs_contract_deployer = import_module("./preconf_avs.star")
# sequencer_contract_deployer = import_module("./sequencer.star")

def deploy(
    plan,
    taiko_params,
    prefunded_accounts,
    final_genesis_timestamp,
    el_rpc_url,
):
    # Deposit some eths to contract owner
    # plan.add_service(
    #     name="taiko-deposit-eths",
    #     description="Depositing some eths to contract owner",
    #     config=ServiceConfig(
    #         image="nethsurge/token-transfer:latest",
    #         env_vars={
    #             "RPC_URL": el_rpc_url,
    #             "SENDER_PRIVATE_KEY": prefunded_accounts[4].private_key,
    #             "RECEIVER_ADDRESS": "0x8B52EEEC5de56a97d27376f79DCA50a25539907A",
    #             "AMOUNT_IN_ETHER": "1000000",
    #         },
    #         cmd=[
    #             "python",
    #             "token_transfer.py",
    #         ],
    #     ),
    # )

    # Deploy Taiko on L1
    # result = taiko_on_l1.deploy(
    #     plan,
    #     taiko_params,
    #     prefunded_accounts[0],
    #     el_rpc_url,
    # )

    # Deploy Taiko on L1
    result = surge_on_l1.deploy(
        plan,
        taiko_params,
        prefunded_accounts[0],
        el_rpc_url,
    )

    # Deploy Taiko SGX SetDcapParams
    set_dcap_params.deploy(
        plan,
        taiko_params,
        prefunded_accounts[0],
        el_rpc_url,
        result,
    )

    # Deploy Taiko SetAddress (Handled by surge on l1 now)
    # set_address.deploy(
    #     plan,
    #     taiko_params,
    #     prefunded_accounts[0],
    #     el_rpc_url,
    #     result,
    # )

    # Deploy eigenlayer mvp contracts
    # eigenlayer_contract_deployer.deploy(
    #     plan,
    #     el_rpc_url,
    #     first_prefunded_account,
    # )

    # Get beacon genesis timestamp for avs contracts
#     beacon_genesis_timestamp = plan.run_python(
#         description="Getting final beacon genesis timestamp",
#         run="""
# import sys
# new = int(sys.argv[1]) + 20
# print(new, end="")
#             """,
#         args=[str(final_genesis_timestamp)],
#         store=[StoreSpec(src="/tmp", name="beacon-genesis-timestamp")],
#     )

    # Deploy avs contracts
    # avs_contract_deployer.deploy(
    #     plan,
    #     el_rpc_url,
    #     beacon_genesis_timestamp.output,
    #     first_prefunded_account,
    # )

    # Deploy add to sequencer contracts
    # sequencer_contract_deployer.deploy(
    #     plan,
    #     el_rpc_url,
    #     first_prefunded_account,
    # )

    # Transfer taiko tokens
    # transfer_result = plan.add_service(
    #     name = "taiko-transfer",
    #     description = "Transferring taiko tokens",
    #     config = ServiceConfig(
    #         image = "nethswitchboard/taiko-transfer:e2e",
    #         cmd = [
    #             "python",
    #             "transfer.py",
    #         ],
    #         env_vars = {
    #             "SENDER_PRIVATE_KEY": first_prefunded_account.private_key,
    #             "RECIPIENT_ADDRESS": "0x6064f756f7F3dc8280C1CfA01cE41a37B5f16df1",
    #             "TOKEN_AMOUNT": "1000000",
    #             "ERC20_ADDRESS": "0x422A3492e218383753D8006C7Bfa97815B44373F",
    #             "RPC_URL": el_rpc_url,
    #             "CHAIN_ID": network_id,
    #         },
    #     ),
    # )

    # Deposit proposer and prover keys
    plan.add_service(
        name="taiko-deposit-bonds",
        description="Depositing proposer and prover keys",
        config=ServiceConfig(
            image="nethsurge/deposit-bonds:latest",
            env_vars={
                "L1_PROPOSER_PRIVATE_KEY": prefunded_accounts[2].private_key,
                "L1_PROVER_PRIVATE_KEY": prefunded_accounts[3].private_key,
                "TAIKO_L1_CONTRACT_ADDRESS": result.taiko,
            },
            cmd=[
                "python",
                "deposit_bonds.py",
                "--amount", "100",
                "--rpc", el_rpc_url,
            ],
        ),
    )

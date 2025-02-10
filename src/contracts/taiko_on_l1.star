TAIKO_SCRIPT = "DeployProtocolOnL1.s.sol"
TAIKO_SCRIPT_PATH = "./script/layer1/{0}:DeployProtocolOnL1".format(TAIKO_SCRIPT)
TAIKO_SCRIPT_RESULT_PATH = "broadcast/{0}/3151908/run-latest.json".format(TAIKO_SCRIPT)

def deploy(
    plan,
    el_rpc_url,
    contract_owner,
    taiko_protocol_image,
    contracts_addresses
):
    FORK_URL_COMMAND = "--fork-url {0}".format(el_rpc_url)

    PRIVATE_KEY_COMMAND = "--private-key {0}".format(contract_owner.private_key)

    plan.run_sh(
        name="deploy-taiko-contract",
        run="forge script {0} {1} {2} $FORGE_FLAGS".format(TAIKO_SCRIPT_PATH, PRIVATE_KEY_COMMAND, FORK_URL_COMMAND),
        image=taiko_protocol_image,
        env_vars={
            "FOUNDRY_PROFILE": "layer1",
            "PRIVATE_KEY": "0x{0}".format(contract_owner.private_key),
            "PROPOSER": "0x0000000000000000000000000000000000000000",
            "TAIKO_TOKEN": "0x0000000000000000000000000000000000000000",
            "PROPOSER_ONE": "0x0000000000000000000000000000000000000000",
            "GUARDIAN_PROVERS": "0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007",
            "TAIKO_L2_ADDRESS": contracts_addresses.taiko_l2,
            "L2_SIGNAL_SERVICE": "0x1670000000000000000000000000000000000005",
            "CONTRACT_OWNER": contract_owner.address,
            "PROVER_SET_ADMIN": contract_owner.address,
            "TAIKO_TOKEN_PREMINT_RECIPIENT": contract_owner.address,
            "TAIKO_TOKEN_NAME": "Taiko Token",
            "TAIKO_TOKEN_SYMBOL": "TAIKO",
            "SHARED_ADDRESS_MANAGER": "0x0000000000000000000000000000000000000000",
            # "L2_GENESIS_HASH": "0x7983c69e31da54b8d244d8fef4714ee7a8ed25d873ebef204a56f082a73c9f1e",
            "L2_GENESIS_HASH": "0x7d621e96344cc0c1b32a6a53246ef76a46a046b009ee5d44b02ed69d4dabd4fb",
            "PAUSE_TAIKO_L1": "false",
            "PAUSE_BRIDGE": "true",
            "NUM_MIN_MAJORITY_GUARDIANS": "7",
            "NUM_MIN_MINORITY_GUARDIANS": "2",
            "TIER_ROUTER": "mainnet",
            "FORK_URL": el_rpc_url,
            "SECURITY_COUNCIL": contract_owner.address,
            "FORGE_FLAGS": "--broadcast --ffi -vvv --block-gas-limit 200000000",
        },
        wait=None,
        description="Deploying taiko smart contract",
        store = [StoreSpec(src = "app/{0}".format(TAIKO_SCRIPT_RESULT_PATH), name = "taiko_on_l1_deployment")],
    )

    plan.add_service(
        name = "taiko-on-l1-result",
        config = ServiceConfig(
            image = "badouralix/curl-jq",
            files = {
                "/result": "taiko_on_l1_deployment",
            }
        ),
    )

    result = plan.exec(
        service_name = "taiko-on-l1-result",
        recipe = ExecRecipe(
            command = [
                "/bin/sh", 
                "-c", 
                # Transform JSON structure using jq
                "cat /result/run-latest.json | jq '[.transactions[] | select(.contractName) | {key: .contractName, value: .contractAddress}] | from_entries'",
            ],
            extract = {
                "LibBonds": "fromjson.LibBonds",
                "LibData": "fromjson.LibData",
                "LibProving": "fromjson.LibProving",
                "LibUtils": "fromjson.LibUtils",
                "AddressManager": "fromjson.AddressManager",
                "ERC1967Proxy": "fromjson.ERC1967Proxy",
                "TaikoToken": "fromjson.TaikoToken",
                "MainnetSignalService": "fromjson.MainnetSignalService",
                "SignalService": "fromjson.SignalService",
                "MainnetBridge": "fromjson.MainnetBridge",
                "Bridge": "fromjson.Bridge",
                "MainnetERC20Vault": "fromjson.MainnetERC20Vault",
                "ERC20Vault": "fromjson.ERC20Vault",
                "MainnetERC721Vault": "fromjson.MainnetERC721Vault",
                "ERC721Vault": "fromjson.ERC721Vault",
                "MainnetERC1155Vault": "fromjson.MainnetERC1155Vault",
                "ERC1155Vault": "fromjson.ERC1155Vault",
                "BridgedERC20": "fromjson.BridgedERC20",
                "BridgedERC721": "fromjson.BridgedERC721",
                "BridgedERC1155": "fromjson.BridgedERC1155",
                "MainnetTaikoL1": "fromjson.MainnetTaikoL1",
                "TaikoL1": "fromjson.TaikoL1",
                "MainnetSgxVerifier": "fromjson.MainnetSgxVerifier",
                "SgxVerifier": "fromjson.SgxVerifier",
                "MainnetGuardianProver": "fromjson.MainnetGuardianProver",
                "GuardianProver": "fromjson.GuardianProver",
                "MainnetTierRouter": "fromjson.MainnetTierRouter",
                "P256Verifier": "fromjson.P256Verifier",
                "SigVerifyLib": "fromjson.SigVerifyLib",
                "PEMCertChainLib": "fromjson.PEMCertChainLib",
                "AutomataDcapV3Attestation": "fromjson.AutomataDcapV3Attestation",
                "ProverSet": "fromjson.ProverSet",
                "RiscZeroGroth16Verifier": "fromjson.RiscZeroGroth16Verifier",
                "Risc0Verifier": "fromjson.Risc0Verifier",
                "SP1Verifier": "fromjson.SP1Verifier",
                "FreeMintERC20": "fromjson.FreeMintERC20",
                "MayFailFreeMintERC20": "fromjson.MayFailFreeMintERC20",
            }
        ),
    )
    
    return struct(
        lib_bonds = result["extract.LibBonds"],
        lib_data = result["extract.LibData"],
        lib_proving = result["extract.LibProving"],
        lib_utils = result["extract.LibUtils"],
        address_manager = result["extract.AddressManager"],
        erc1967_proxy = result["extract.ERC1967Proxy"],
        taiko_token = result["extract.TaikoToken"],
        mainnet_signal_service = result["extract.MainnetSignalService"],
        signal_service = result["extract.SignalService"],
        mainnet_bridge = result["extract.MainnetBridge"],
        bridge = result["extract.Bridge"],
        mainnet_erc20_vault = result["extract.MainnetERC20Vault"],
        erc20_vault = result["extract.ERC20Vault"],
        mainnet_erc721_vault = result["extract.MainnetERC721Vault"],
        erc721_vault = result["extract.ERC721Vault"],
        mainnet_erc1155_vault = result["extract.MainnetERC1155Vault"],
        erc1155_vault = result["extract.ERC1155Vault"],
        bridged_erc20 = result["extract.BridgedERC20"],
        bridged_erc721 = result["extract.BridgedERC721"],
        bridged_erc1155 = result["extract.BridgedERC1155"],
        mainnet_taiko_l1 = result["extract.MainnetTaikoL1"],
        taiko_l1 = result["extract.TaikoL1"],
        mainnet_sgx_verifier = result["extract.MainnetSgxVerifier"],
        sgx_verifier = result["extract.SgxVerifier"],
        mainnet_guardian_prover = result["extract.MainnetGuardianProver"],
        guardian_prover = result["extract.GuardianProver"],
        mainnet_tier_router = result["extract.MainnetTierRouter"],
        p256_verifier = result["extract.P256Verifier"],
        sig_verify_lib = result["extract.SigVerifyLib"],
        pem_cert_chain_lib = result["extract.PEMCertChainLib"],
        automata_dcap_v3_attestation = result["extract.AutomataDcapV3Attestation"],
        prover_set = result["extract.ProverSet"],
        risc_zero_groth16_verifier = result["extract.RiscZeroGroth16Verifier"],
        risc0_verifier = result["extract.Risc0Verifier"],
        sp1_verifier = result["extract.SP1Verifier"],
        free_mint_erc20 = result["extract.FreeMintERC20"],
        may_fail_free_mint_erc20 = result["extract.MayFailFreeMintERC20"],
    )
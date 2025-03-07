input_parser = import_module("./src/package_io/input_parser.star")
constants = import_module("./src/package_io/constants.star")
participant_network = import_module("./src/participant_network.star")
shared_utils = import_module("./src/shared_utils/shared_utils.star")
static_files = import_module("./src/static_files/static_files.star")
genesis_constants = import_module(
    "./src/prelaunch_data_generator/genesis_constants/genesis_constants.star"
)

validator_ranges = import_module(
    "./src/prelaunch_data_generator/validator_keystores/validator_ranges_generator.star"
)

transaction_spammer = import_module(
    "./src/transaction_spammer/transaction_spammer.star"
)
blob_spammer = import_module("./src/blob_spammer/blob_spammer.star")
goomy_blob = import_module("./src/goomy_blob/goomy_blob.star")
el_forkmon = import_module("./src/el_forkmon/el_forkmon_launcher.star")
beacon_metrics_gazer = import_module(
    "./src/beacon_metrics_gazer/beacon_metrics_gazer_launcher.star"
)
dora = import_module("./src/dora/dora_launcher.star")
dugtrio = import_module("./src/dugtrio/dugtrio_launcher.star")
blutgang = import_module("./src/blutgang/blutgang_launcher.star")
blobscan = import_module("./src/blobscan/blobscan_launcher.star")
forky = import_module("./src/forky/forky_launcher.star")
tracoor = import_module("./src/tracoor/tracoor_launcher.star")
apache = import_module("./src/apache/apache_launcher.star")
full_beaconchain_explorer = import_module(
    "./src/full_beaconchain/full_beaconchain_launcher.star"
)
blockscout = import_module("./src/blockscout/blockscout_launcher.star")
prometheus = import_module("./src/prometheus/prometheus_launcher.star")
grafana = import_module("./src/grafana/grafana_launcher.star")
commit_boost_mev_boost = import_module(
    "./src/mev/commit-boost/mev_boost/mev_boost_launcher.star"
)
bolt_boost = import_module("./src/mev/bolt_boost/bolt_boost_launcher.star")
bolt_sidecar = import_module("./src/mev/bolt_sidecar/bolt_sidecar_launcher.star")
mev_rs_mev_boost = import_module("./src/mev/mev-rs/mev_boost/mev_boost_launcher.star")
mev_rs_mev_relay = import_module("./src/mev/mev-rs/mev_relay/mev_relay_launcher.star")
mev_rs_mev_builder = import_module(
    "./src/mev/mev-rs/mev_builder/mev_builder_launcher.star"
)
flashbots_mev_boost = import_module(
    "./src/mev/flashbots/mev_boost/mev_boost_launcher.star"
)
flashbots_mev_relay = import_module(
    "./src/mev/flashbots/mev_relay/mev_relay_launcher.star"
)
helix_relay = import_module("./src/mev/mev_relay/helix_launcher.star")
mock_mev = import_module("./src/mev/flashbots/mock_mev/mock_mev_launcher.star")
mev_flood = import_module("./src/mev/flashbots/mev_flood/mev_flood_launcher.star")
mev_custom_flood = import_module(
    "./src/mev/flashbots/mev_custom_flood/mev_custom_flood_launcher.star"
)
broadcaster = import_module("./src/broadcaster/broadcaster.star")
assertoor = import_module("./src/assertoor/assertoor_launcher.star")
get_prefunded_accounts = import_module(
    "./src/prefunded_accounts/get_prefunded_accounts.star"
)

# Preconf AVS
contract_deployer = import_module("./src/contracts/contract_deployer.star")
l2_taiko = import_module("./src/l2_taiko/taiko_launcher.star")
taiko_blockscout = import_module("./src/l2_taiko/blockscout_launcher.star")
preconf_avs = import_module("./src/preconf_avs/avs_launcher.star")
p2p_bootnode = import_module("./src/preconf_avs/p2pbootnode_launcher.star")

GRAFANA_USER = "admin"
GRAFANA_PASSWORD = "admin"
GRAFANA_DASHBOARD_PATH_URL = "/d/QdTOwy-nz/eth2-merge-kurtosis-module-dashboard?orgId=1"

FIRST_NODE_FINALIZATION_FACT = "cl-boot-finalization-fact"
HTTP_PORT_ID_FOR_FACT = "http"

MEV_BOOST_SHOULD_CHECK_RELAY = True
PATH_TO_PARSED_BEACON_STATE = "/genesis/output/parsedBeaconState.json"


def run(plan, args={}):
    """Launches an arbitrarily complex ethereum testnet based on the arguments provided

    Args:
        args: A YAML or JSON argument to configure the network; example https://github.com/ethpandaops/ethereum-package/blob/main/network_params.yaml
    """

    args_with_right_defaults = input_parser.input_parser(plan, args)

    num_participants = len(args_with_right_defaults.participants)
    network_params = args_with_right_defaults.network_params
    mev_params = args_with_right_defaults.mev_params
    taiko_params = args_with_right_defaults.taiko_params
    preconf_params = args_with_right_defaults.preconf_params
    contracts_addresses = args_with_right_defaults.contracts_addresses
    parallel_keystore_generation = args_with_right_defaults.parallel_keystore_generation
    persistent = args_with_right_defaults.persistent
    xatu_sentry_params = args_with_right_defaults.xatu_sentry_params
    global_tolerations = args_with_right_defaults.global_tolerations
    global_node_selectors = args_with_right_defaults.global_node_selectors
    keymanager_enabled = args_with_right_defaults.keymanager_enabled
    apache_port = args_with_right_defaults.apache_port

    prefunded_accounts = genesis_constants.PRE_FUNDED_ACCOUNTS
    if (
        network_params.preregistered_validator_keys_mnemonic
        != constants.DEFAULT_MNEMONIC
    ):
        prefunded_accounts = get_prefunded_accounts.get_accounts(
            plan, network_params.preregistered_validator_keys_mnemonic
        )

    grafana_datasource_config_template = read_file(
        static_files.GRAFANA_DATASOURCE_CONFIG_TEMPLATE_FILEPATH
    )
    grafana_dashboards_config_template = read_file(
        static_files.GRAFANA_DASHBOARD_PROVIDERS_CONFIG_TEMPLATE_FILEPATH
    )
    prometheus_additional_metrics_jobs = []
    raw_jwt_secret = read_file(static_files.JWT_PATH_FILEPATH)
    jwt_file = plan.upload_files(
        src=static_files.JWT_PATH_FILEPATH,
        name="jwt_file",
    )
    keymanager_file = plan.upload_files(
        src=static_files.KEYMANAGER_PATH_FILEPATH,
        name="keymanager_file",
    )

    plan.print("Read the prometheus, grafana templates")

    if args_with_right_defaults.mev_type == constants.MEV_RS_MEV_TYPE:
        plan.print("Generating mev-rs builder config file")
        mev_rs__builder_config_file = mev_rs_mev_builder.new_builder_config(
            plan,
            constants.MEV_RS_MEV_TYPE,
            network_params.network,
            constants.VALIDATING_REWARDS_ACCOUNT,
            network_params.preregistered_validator_keys_mnemonic,
            args_with_right_defaults.mev_params.mev_builder_extra_data,
            global_node_selectors,
        )

    plan.print(
        "Launching participant network with {0} participants and the following network params {1}".format(
            num_participants, network_params
        )
    )
    plan.print(prefunded_accounts)
    (
        all_participants,
        final_genesis_timestamp,
        genesis_validators_root,
        el_cl_data_files_artifact_uuid,
        network_id,
    ) = participant_network.launch_participant_network(
        plan,
        args_with_right_defaults.participants,
        network_params,
        args_with_right_defaults.global_log_level,
        jwt_file,
        keymanager_file,
        persistent,
        xatu_sentry_params,
        global_tolerations,
        global_node_selectors,
        keymanager_enabled,
        parallel_keystore_generation,
        args_with_right_defaults.checkpoint_sync_enabled,
        args_with_right_defaults.checkpoint_sync_url,
        args_with_right_defaults.port_publisher,
    )

    plan.print(
        "NODE JSON RPC URI: '{0}:{1}'".format(
            all_participants[0].el_context.ip_addr,
            all_participants[0].el_context.rpc_port_num,
        )
    )

    all_el_contexts = []
    all_cl_contexts = []
    all_vc_contexts = []
    all_ethereum_metrics_exporter_contexts = []
    all_xatu_sentry_contexts = []
    for participant in all_participants:
        all_el_contexts.append(participant.el_context)
        all_cl_contexts.append(participant.cl_context)
        all_vc_contexts.append(participant.vc_context)
        all_ethereum_metrics_exporter_contexts.append(
            participant.ethereum_metrics_exporter_context
        )
        all_xatu_sentry_contexts.append(participant.xatu_sentry_context)

    # Generate validator ranges
    validator_ranges_config_template = read_file(
        static_files.VALIDATOR_RANGES_CONFIG_TEMPLATE_FILEPATH
    )
    ranges = validator_ranges.generate_validator_ranges(
        plan,
        validator_ranges_config_template,
        all_participants,
        args_with_right_defaults.participants,
    )

    fuzz_target = "http://{0}:{1}".format(
        all_el_contexts[0].ip_addr,
        all_el_contexts[0].rpc_port_num,
    )

    # Deploy all smart contracts
    contract_deployer.deploy(
        plan,
        final_genesis_timestamp,
        all_el_contexts[0],
        prefunded_accounts,
        network_id,
        taiko_params.taiko_deploy_image,
        preconf_params.avs_deploy_image,
        contracts_addresses,
    )

    # Broadcaster forwards requests, sent to it, to all nodes in parallel
    if "broadcaster" in args_with_right_defaults.additional_services:
        args_with_right_defaults.additional_services.remove("broadcaster")
        broadcaster_service = broadcaster.launch_broadcaster(
            plan,
            all_el_contexts,
            global_node_selectors,
        )
        fuzz_target = "http://{0}:{1}".format(
            broadcaster_service.ip_address,
            broadcaster.PORT,
        )
    mev_endpoints = []
    mev_endpoint_names = []
    # passed external relays get priority
    # perhaps add mev_type External or remove this
    if (
        hasattr(participant, "builder_network_params")
        and participant.builder_network_params != None
    ):
        mev_endpoints = participant.builder_network_params.relay_end_points
        for idx, mev_endpoint in enumerate(mev_endpoints):
            mev_endpoint_names.append("relay-{0}".format(idx + 1))
    # otherwise dummy relays spinup if chosen
    elif (
        args_with_right_defaults.mev_type
        and args_with_right_defaults.mev_type == constants.MOCK_MEV_TYPE
    ):
        el_uri = "{0}:{1}".format(
            all_el_contexts[0].ip_addr,
            all_el_contexts[0].engine_rpc_port_num,
        )
        beacon_uri = "{0}".format(all_cl_contexts[0].beacon_http_url)[
            7:
        ]  # remove http://
        endpoint = mock_mev.launch_mock_mev(
            plan,
            el_uri,
            beacon_uri,
            raw_jwt_secret,
            args_with_right_defaults.global_log_level,
            global_node_selectors,
        )
        mev_endpoints.append(endpoint)
        mev_endpoint_names.append(constants.MOCK_MEV_TYPE)
    elif args_with_right_defaults.mev_type and (
        args_with_right_defaults.mev_type == constants.FLASHBOTS_MEV_TYPE
        or args_with_right_defaults.mev_type == constants.MEV_RS_MEV_TYPE
        or args_with_right_defaults.mev_type == constants.COMMIT_BOOST_MEV_TYPE
    ):
        builder_uri = "http://{0}:{1}".format(
            all_el_contexts[-1].ip_addr, all_el_contexts[-1].rpc_port_num
        )
        beacon_uri = all_cl_contexts[-1].beacon_http_url
        beacon_uris = ",".join(
            ["{0}".format(context.beacon_http_url) for context in all_cl_contexts]
        )

        first_cl_client = all_cl_contexts[0]
        first_client_beacon_name = first_cl_client.beacon_service_name
        contract_owner, normal_user = prefunded_accounts[6:8]
        mev_flood.launch_mev_flood(
            plan,
            mev_params.mev_flood_image,
            fuzz_target,
            contract_owner.private_key,
            normal_user.private_key,
            global_node_selectors,
        )
        epoch_recipe = GetHttpRequestRecipe(
            endpoint="/eth/v2/beacon/blocks/head",
            port_id=HTTP_PORT_ID_FOR_FACT,
            extract={"epoch": ".data.message.body.attestations[0].data.target.epoch"},
        )
        plan.wait(
            recipe=epoch_recipe,
            field="extract.epoch",
            assertion=">=",
            target_value=str(network_params.deneb_fork_epoch),
            timeout="20m",
            service_name=first_client_beacon_name,
        )

        # Get real genesis timestamp for helix
        bolt_genesis_timestamp = plan.run_python(
            description="Getting real genesis timestamp for helix",
            run="""
import sys
a = int(sys.argv[1])
b = int(sys.argv[2])
print(int(a+b), end="")
""",
            args=[str(final_genesis_timestamp),str(network_params.genesis_delay)],
        ).output
        # Run helix relay
        helix_endpoint = helix_relay.launch_helix_relay(
            plan,
            mev_params,
            network_params,
            beacon_uris,
            genesis_validators_root,
            builder_uri,
            network_params.seconds_per_slot,
            persistent,
            bolt_genesis_timestamp,
            global_node_selectors,
        )

        # Restart MEV builder
        plan.stop_service(
            name = all_el_contexts[-1].service_name,
            description = "Stopping builder service",
        )

        plan.start_service(
            name = all_el_contexts[-1].service_name,
            description = "Starting builder service",
        )

        mev_flood.spam_in_background(
            plan,
            fuzz_target,
            mev_params.mev_flood_extra_args,
            mev_params.mev_flood_seconds_per_bundle,
            contract_owner.private_key,
            normal_user.private_key,
        )
        mev_endpoints.append(helix_endpoint)
        mev_endpoint_names.append(args_with_right_defaults.mev_type)

    # spin up the mev boost contexts if some endpoints for relays have been passed
    all_mevboost_contexts = []
    if mev_endpoints:
        for index, participant in enumerate(all_participants):
            index_str = shared_utils.zfill_custom(
                index + 1, len(str(len(all_participants)))
            )
            plan.print(
                "args_with_right_defaults.participants[index].validator_count {0}".format(
                    args_with_right_defaults.participants[index].validator_count
                )
            )
            if args_with_right_defaults.participants[index].validator_count != 0:
             # Initialize the Bolt Sidecar configure if needed
                bolt_sidecar_config = None
                if mev_params.bolt_sidecar_image != None:
                    # NOTE: this is a stub missing the `"constraints_api_url"` entry
                    bolt_sidecar_config = {
                        "beacon_api_url": participant.cl_context.beacon_http_url,
                        "execution_api_url": "http://{0}:{1}".format(
                            participant.el_context.ip_addr,
                            participant.el_context.rpc_port_num,
                        ),
                        "engine_api_url": "http://{0}:{1}".format(
                            participant.el_context.ip_addr,
                            participant.el_context.engine_rpc_port_num
                        ),
                        "jwt_hex": raw_jwt_secret,
                        "metrics_port": bolt_sidecar.BOLT_SIDECAR_METRICS_PORT,
                        "validator_keystore_files_artifact_uuid": participant.cl_context.validator_keystore_files_artifact_uuid,
                        "participant_index": index,
                    }
                if (
                    args_with_right_defaults.mev_type == constants.FLASHBOTS_MEV_TYPE
                    or args_with_right_defaults.mev_type == constants.MOCK_MEV_TYPE
                ):
                    mev_boost_launcher = flashbots_mev_boost.new_mev_boost_launcher(
                        MEV_BOOST_SHOULD_CHECK_RELAY,
                        mev_endpoints,
                    )
                    mev_boost_service_name = "{0}-{1}-{2}-{3}".format(
                        input_parser.MEV_BOOST_SERVICE_NAME_PREFIX,
                        index_str,
                        participant.cl_type,
                        participant.el_type,
                    )
                    mev_boost_context = flashbots_mev_boost.launch(
                        plan,
                        mev_boost_launcher,
                        mev_boost_service_name,
                        network_id,
                        mev_params.mev_boost_image,
                        mev_params.mev_boost_args,
                        global_node_selectors,
                    )
                elif args_with_right_defaults.mev_type == constants.MEV_RS_MEV_TYPE:
                    plan.print("Launching mev-rs mev boost")
                    mev_boost_launcher = mev_rs_mev_boost.new_mev_boost_launcher(
                        MEV_BOOST_SHOULD_CHECK_RELAY,
                        mev_endpoints,
                    )
                    mev_boost_service_name = "{0}-{1}-{2}-{3}".format(
                        input_parser.MEV_BOOST_SERVICE_NAME_PREFIX,
                        index_str,
                        participant.cl_type,
                        participant.el_type,
                    )
                    mev_boost_context = mev_rs_mev_boost.launch(
                        plan,
                        mev_boost_launcher,
                        mev_boost_service_name,
                        network_params.network,
                        mev_params,
                        mev_endpoints,
                        el_cl_data_files_artifact_uuid,
                        global_node_selectors,
                    )
                elif (
                    args_with_right_defaults.mev_type == constants.COMMIT_BOOST_MEV_TYPE
                ):
                    plan.print("Launching bolt boost service")
                    mev_boost_launcher = commit_boost_mev_boost.new_mev_boost_launcher(
                        MEV_BOOST_SHOULD_CHECK_RELAY,
                        mev_endpoints,
                    )

                    bolt_boost_service_name = "{0}-{1}-{2}-{3}".format(
                        input_parser.MEV_BOOST_SERVICE_NAME_PREFIX,
                        index_str,
                        participant.cl_type,
                        participant.el_type,
                    )
                    relays_config = [{
                        "id": "helix_relay",
                        "url": helix_endpoint,
                    }]
                    if bolt_sidecar_config != None:
                        bolt_sidecar_config["constraints_api_url"] = "http://{0}:{1}".format(
                            bolt_boost_service_name, input_parser.MEV_BOOST_PORT
                        )
                    mev_boost_context = bolt_boost.launch(
                        plan,
                        bolt_boost_service_name,
                        mev_params.bolt_boost_image,
                        relays_config,
                        bolt_sidecar_config,
                        network_params,
                        bolt_genesis_timestamp,
                        global_node_selectors,
                    )
                else:
                    fail("Invalid MEV type")
                all_mevboost_contexts.append(mev_boost_context)

                if bolt_sidecar_config != None:
                    service_name = "{0}-{1}-{2}-{3}".format(
                        input_parser.BOLT_SIDECAR_SERVICE_NAME_PREFIX,
                        index_str,
                        participant.cl_type,
                        participant.el_type,
                    )
                    bolt_sidecar_config["service_name"] = service_name
                    bolt_sidecar_context = bolt_sidecar.launch_bolt_sidecar(
                        plan,
                        mev_params.bolt_sidecar_image,
                        bolt_sidecar_config,
                        network_params,
                        global_node_selectors,
                    )

    if len(args_with_right_defaults.additional_services) == 0:
        output = struct(
            all_participants=all_participants,
            pre_funded_accounts=prefunded_accounts,
            network_params=network_params,
            network_id=network_id,
            final_genesis_timestamp=final_genesis_timestamp,
            genesis_validators_root=genesis_validators_root,
        )

        return output

    launch_prometheus_grafana = False
    for index, additional_service in enumerate(
        args_with_right_defaults.additional_services
    ):
        if additional_service == "tx_spammer":
            plan.print("Launching transaction spammer")
            tx_spammer_params = args_with_right_defaults.tx_spammer_params
            transaction_spammer.launch_transaction_spammer(
                plan,
                prefunded_accounts,
                fuzz_target,
                tx_spammer_params,
                network_params.electra_fork_epoch,
                global_node_selectors,
            )
            plan.print("Successfully launched transaction spammer")
        elif additional_service == "blob_spammer":
            plan.print("Launching Blob spammer")
            blob_spammer.launch_blob_spammer(
                plan,
                prefunded_accounts,
                fuzz_target,
                all_cl_contexts[0],
                network_params.deneb_fork_epoch,
                network_params.seconds_per_slot,
                network_params.genesis_delay,
                global_node_selectors,
            )
            plan.print("Successfully launched blob spammer")
        elif additional_service == "goomy_blob":
            plan.print("Launching Goomy the blob spammer")
            goomy_blob_params = args_with_right_defaults.goomy_blob_params
            goomy_blob.launch_goomy_blob(
                plan,
                prefunded_accounts,
                all_el_contexts,
                all_cl_contexts[0],
                network_params.seconds_per_slot,
                goomy_blob_params,
                global_node_selectors,
            )
            plan.print("Successfully launched goomy the blob spammer")
        # We need a way to do time.sleep
        # TODO add code that waits for CL genesis
        elif additional_service == "el_forkmon":
            plan.print("Launching el forkmon")
            el_forkmon_config_template = read_file(
                static_files.EL_FORKMON_CONFIG_TEMPLATE_FILEPATH
            )
            el_forkmon.launch_el_forkmon(
                plan,
                el_forkmon_config_template,
                all_el_contexts,
                global_node_selectors,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched execution layer forkmon")
        elif additional_service == "beacon_metrics_gazer":
            plan.print("Launching beacon metrics gazer")
            beacon_metrics_gazer_prometheus_metrics_job = (
                beacon_metrics_gazer.launch_beacon_metrics_gazer(
                    plan,
                    all_cl_contexts,
                    network_params,
                    global_node_selectors,
                    args_with_right_defaults.port_publisher,
                    index,
                )
            )
            launch_prometheus_grafana = True
            prometheus_additional_metrics_jobs.append(
                beacon_metrics_gazer_prometheus_metrics_job
            )
            plan.print("Successfully launched beacon metrics gazer")
        elif additional_service == "blockscout":
            plan.print("Launching blockscout")
            blockscout_sc_verif_url = blockscout.launch_blockscout(
                plan,
                all_el_contexts,
                persistent,
                global_node_selectors,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched blockscout")
        elif additional_service == "dora":
            plan.print("Launching dora")
            dora_config_template = read_file(static_files.DORA_CONFIG_TEMPLATE_FILEPATH)
            dora_params = args_with_right_defaults.dora_params
            dora.launch_dora(
                plan,
                dora_config_template,
                all_participants,
                args_with_right_defaults.participants,
                network_params,
                dora_params,
                global_node_selectors,
                mev_endpoints,
                mev_endpoint_names,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched dora")
        elif additional_service == "dugtrio":
            plan.print("Launching dugtrio")
            dugtrio_config_template = read_file(
                static_files.DUGTRIO_CONFIG_TEMPLATE_FILEPATH
            )
            dugtrio.launch_dugtrio(
                plan,
                dugtrio_config_template,
                all_participants,
                args_with_right_defaults.participants,
                network_params,
                global_node_selectors,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched dugtrio")
        elif additional_service == "blutgang":
            plan.print("Launching blutgang")
            blutgang_config_template = read_file(
                static_files.BLUTGANG_CONFIG_TEMPLATE_FILEPATH
            )
            blutgang.launch_blutgang(
                plan,
                blutgang_config_template,
                all_participants,
                args_with_right_defaults.participants,
                network_params,
                global_node_selectors,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched blutgang")
        elif additional_service == "blobscan":
            plan.print("Launching blobscan")
            blobscan.launch_blobscan(
                plan,
                all_cl_contexts,
                all_el_contexts,
                network_id,
                network_params,
                persistent,
                global_node_selectors,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched blobscan")
        elif additional_service == "forky":
            plan.print("Launching forky")
            forky_config_template = read_file(
                static_files.FORKY_CONFIG_TEMPLATE_FILEPATH
            )
            forky.launch_forky(
                plan,
                forky_config_template,
                all_participants,
                args_with_right_defaults.participants,
                el_cl_data_files_artifact_uuid,
                network_params,
                global_node_selectors,
                final_genesis_timestamp,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched forky")
        elif additional_service == "tracoor":
            plan.print("Launching tracoor")
            tracoor_config_template = read_file(
                static_files.TRACOOR_CONFIG_TEMPLATE_FILEPATH
            )
            tracoor.launch_tracoor(
                plan,
                tracoor_config_template,
                all_participants,
                args_with_right_defaults.participants,
                el_cl_data_files_artifact_uuid,
                network_params,
                global_node_selectors,
                final_genesis_timestamp,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched tracoor")
        elif additional_service == "apache":
            plan.print("Launching apache")
            apache.launch_apache(
                plan,
                el_cl_data_files_artifact_uuid,
                apache_port,
                all_participants,
                args_with_right_defaults.participants,
                global_node_selectors,
            )
            plan.print("Successfully launched apache")
        elif additional_service == "full_beaconchain_explorer":
            plan.print("Launching full-beaconchain-explorer")
            full_beaconchain_explorer_config_template = read_file(
                static_files.FULL_BEACONCHAIN_CONFIG_TEMPLATE_FILEPATH
            )
            full_beaconchain_explorer.launch_full_beacon(
                plan,
                full_beaconchain_explorer_config_template,
                el_cl_data_files_artifact_uuid,
                all_cl_contexts,
                all_el_contexts,
                persistent,
                global_node_selectors,
                args_with_right_defaults.port_publisher,
                index,
            )
            plan.print("Successfully launched full-beaconchain-explorer")
        elif additional_service == "prometheus_grafana":
            # Allow prometheus to be launched last so is able to collect metrics from other services
            launch_prometheus_grafana = True
        elif additional_service == "assertoor":
            plan.print("Launching assertoor")
            assertoor_config_template = read_file(
                static_files.ASSERTOOR_CONFIG_TEMPLATE_FILEPATH
            )
            assertoor_params = args_with_right_defaults.assertoor_params
            assertoor.launch_assertoor(
                plan,
                assertoor_config_template,
                all_participants,
                args_with_right_defaults.participants,
                network_params,
                assertoor_params,
                global_node_selectors,
            )
            plan.print("Successfully launched assertoor")
        elif additional_service == "custom_flood":
            mev_custom_flood.spam_in_background(
                plan,
                prefunded_accounts[-1].private_key,
                prefunded_accounts[0].address,
                fuzz_target,
                args_with_right_defaults.custom_flood_params,
                global_node_selectors,
            )
        elif additional_service == "taiko_stack":
            plan.print("Launching taiko")

            plan.upload_files(
                src="./taiko-geth",
                name="taiko_genesis",
            )

            # Launch taiko stack 1
            taiko_stack_1 = l2_taiko.launch(
                plan,
                all_el_contexts[0],
                all_cl_contexts[0],
                prefunded_accounts,
                "",
                0,
                args_with_right_defaults.taiko_params.taiko_geth_image,
                args_with_right_defaults.taiko_params.taiko_client_image,
                contracts_addresses,
            )

            # Launch taiko stack 2
            taiko_stack_2 = l2_taiko.launch(
                plan,
                all_el_contexts[0],
                all_cl_contexts[0],
                prefunded_accounts,
                taiko_stack_1.enode,
                1,
                args_with_right_defaults.taiko_params.taiko_geth_image,
                args_with_right_defaults.taiko_params.taiko_client_image,
                contracts_addresses,
            )

            plan.print("Successfully launched 2 taiko stacks")

            # Launch blockscout for taiko L2
            taiko_blockscout.launch_blockscout(
                plan,
                taiko_stack_1,
                persistent,
                global_node_selectors,
                args_with_right_defaults.port_publisher,
                index,
            )

            plan.print("Successfully launched blockscout for taiko L2")

            # Launch taiko L2 tx transfer for first transaction
            plan.add_service(
                name = "taiko-tx-transfer",
                description = "Preparing to transfer Taiko ETH",
                config = ServiceConfig(
                    image = "nethswitchboard/taiko-spammer:e2e",
                    cmd = [
                        "sleep",
                        "infinity",
                    ],
                    env_vars = {
                        "PRIVATE_KEY": "bcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
                        "RECIPIENT_ADDRESS": "0xf93Ee4Cf8c6c40b329b0c0626F28333c132CF241",
                        "TX_COUNT": "1",
                        "TX_AMOUNT": "100",
                        "RPC_URL": taiko_stack_1.rpc_http_url,
                        "DELAY": "3",
                    },
                ),
            )

            # Launch taiko L2 tx spammer
            plan.add_service(
                name = "taiko-tx-spammer",
                description = "Launching Taiko L2 tx spammer",
                config = ServiceConfig(
                    image = "nethswitchboard/taiko-spammer:e2e",
                    cmd = [
                        "sleep",
                        "infinity",
                    ],
                    env_vars = {
                        "PRIVATE_KEY": "bcdf20249abf0ed6d944c0288fad489e33f66b3960d9e6229c1cd214ed3bbe31",
                        "RECIPIENT_ADDRESS": "0x802dCbE1B1A97554B4F50DB5119E37E8e7336417",
                        "TX_COUNT": "10",
                        "TX_AMOUNT": "0.005",
                        "RPC_URL": taiko_stack_1.rpc_http_url,
                        "DELAY": "3",
                    },
                ),
            )

            # plan.print(spammer_result)
        elif additional_service == "preconf_avs":
            plan.print("Launching preconfirmation AVS")

            # Launch P2P Bootnode
            p2pbootnode_context = p2p_bootnode.launch(
                plan,
            )
            # Launch Preconf AVS 1
            preconf_avs.launch(
                plan,
                preconf_params.preconf_avs_image,
                network_id,
                all_el_contexts[0],
                all_cl_contexts[0],
                p2pbootnode_context,
                taiko_stack_1,
                all_mevboost_contexts[0],
                prefunded_accounts,
                "3219c83a76e82682c3e706902ca85777e703a06c9f0a82a5dfa6164f527c1ea6",
                1,
                # "215768a626159445ba0d8a1afab729c5724e75aa020a480580cbf86dd2ae4d47",
                # 2,
                0,
                contracts_addresses,
            )

            # Launch Preconf AVS 2
            preconf_avs.launch(
                plan,
                preconf_params.preconf_avs_image,
                network_id,
                all_el_contexts[0],
                all_cl_contexts[0],
                p2pbootnode_context,
                taiko_stack_2,
                all_mevboost_contexts[0],
                prefunded_accounts,
                "0dce41fa73ae9f6bdfd51df4d422d75eee174553dba5fd450c4437e4ed3fc903",
                0,
                # "10c3db5c5bdca44958bc765e040a5cae3439551cfb4651df442cbe499b12ee69",
                # 3,
                1,
                contracts_addresses,
            )

            plan.print("Successfully launched 2 preconf avs")

            plan.run_sh(
                run = "sleep 120",
                description = "Waiting 2 mins for L2 to sync",
            )

            plan.exec(
                service_name = "taiko-tx-transfer",
                description = "Transfering Taiko ETH",
                recipe = ExecRecipe(
                    command = [
                        "sh",
                        "-c",
                        "python tx_spammer.py --count $TX_COUNT --amount $TX_AMOUNT --rpc $RPC_URL | grep 'Transaction sent:' | awk '{print \"{\\\"transaction_hash\\\": \\\"\" $3 \"\\\"}\"}'",
                    ],
                    extract = {
                        "tx_transfer_status": "fromjson | .transaction_hash",
                    },
                ),
            )

            plan.add_service(
                name = "preconf-pytest",
                description = "Launching preconf pytest",
                config = ServiceConfig(
                    image = "nethsurge/test-pytest",
                    env_vars = {
                        "L1_RPC_URL": all_el_contexts[0].rpc_http_url,
                        "L2_RPC_URL_NODE1": taiko_stack_1.rpc_http_url,
                        "L2_RPC_URL_NODE2": taiko_stack_2.rpc_http_url,
                        "TEST_L2_PREFUNDED_PRIVATE_KEY": "39725efee3fb28614de3bacaffe4cc4bd8c436257e2c8bb887c4b5c4be45e76d",
                    }
                ),
            )

            pytest_result = plan.exec(
                service_name = "preconf-pytest",
                description = "Running preconf pytest",
                recipe = ExecRecipe(
                    command = [
                        "pytest"
                    ],
                ),
            )

            plan.print(pytest_result["output"])
        else:
            fail("Invalid additional service %s" % (additional_service))
    if launch_prometheus_grafana:
        plan.print("Launching prometheus...")
        prometheus_private_url = prometheus.launch_prometheus(
            plan,
            all_el_contexts,
            all_cl_contexts,
            all_vc_contexts,
            prometheus_additional_metrics_jobs,
            all_ethereum_metrics_exporter_contexts,
            all_xatu_sentry_contexts,
            global_node_selectors,
            args_with_right_defaults.prometheus_params.storage_tsdb_retention_time,
            args_with_right_defaults.prometheus_params.storage_tsdb_retention_size,
        )

        plan.print("Launching grafana...")
        grafana.launch_grafana(
            plan,
            grafana_datasource_config_template,
            grafana_dashboards_config_template,
            prometheus_private_url,
            global_node_selectors,
            additional_dashboards=args_with_right_defaults.grafana_additional_dashboards,
        )
        plan.print("Successfully launched grafana")

    if args_with_right_defaults.wait_for_finalization:
        plan.print("Waiting for the first finalized epoch")
        first_cl_client = all_cl_contexts[0]
        first_client_beacon_name = first_cl_client.beacon_service_name
        epoch_recipe = GetHttpRequestRecipe(
            endpoint="/eth/v1/beacon/states/head/finality_checkpoints",
            port_id=HTTP_PORT_ID_FOR_FACT,
            extract={"finalized_epoch": ".data.finalized.epoch"},
        )
        plan.wait(
            recipe=epoch_recipe,
            field="extract.finalized_epoch",
            assertion="!=",
            target_value="0",
            timeout="40m",
            service_name=first_client_beacon_name,
        )
        plan.print("First finalized epoch occurred successfully")

    grafana_info = struct(
        dashboard_path=GRAFANA_DASHBOARD_PATH_URL,
        user=GRAFANA_USER,
        password=GRAFANA_PASSWORD,
    )

    output = struct(
        grafana_info=grafana_info,
        blockscout_sc_verif_url=None
        if ("blockscout" in args_with_right_defaults.additional_services) == False
        else blockscout_sc_verif_url,
        all_participants=all_participants,
        pre_funded_accounts=prefunded_accounts,
        network_params=network_params,
        network_id=network_id,
        final_genesis_timestamp=final_genesis_timestamp,
        genesis_validators_root=genesis_validators_root,
    )

    return output

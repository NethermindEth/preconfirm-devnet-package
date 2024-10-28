geth_launcher = import_module("./taiko-geth.star")
nethermind_launcher = import_module("./taiko-nethermind.star")
driver_launcher = import_module("./taiko-driver.star")
proposer_launcher = import_module("./taiko-proposer.star")
prover_launcher = import_module("./taiko-prover.star")

# The dirpath of the execution data directory on the client container
EXECUTION_DATA_DIRPATH_ON_CLIENT_CONTAINER = "/data/taiko-geth"

def launch(
    plan,
    el_context,
    cl_context,
    prefunded_accounts,
    enode,
    index,
):
    data_dirpath = EXECUTION_DATA_DIRPATH_ON_CLIENT_CONTAINER + "-" + str(index)
    jwtsecret_path = data_dirpath + "/geth/jwtsecret"

    # Launch EL

    # geth = geth_launcher.launch(
    #     plan,
    #     data_dirpath,
    #     enode,
    #     index,
    # )

    el = nethermind_launcher.launch(
        plan,
        data_dirpath,
        enode,
        index,
    )

    # Launch driver
    driver = driver_launcher.launch(
        plan,
        data_dirpath,
        jwtsecret_path,
        el_context,
        cl_context,
        el,
        index,
    )

    # Launch prover
    prover = prover_launcher.launch(
        plan,
        data_dirpath,
        jwtsecret_path,
        el_context,
        cl_context,
        el,
        prefunded_accounts,
        index,
    )

    # Launch proposer
    proposer = proposer_launcher.launch(
        plan,
        data_dirpath,
        jwtsecret_path,
        el_context,
        cl_context,
        el,
        prefunded_accounts,
        index,
    )

    return struct(
        client_name="taiko-stack",
        rpc_http_url=el.rpc_http_url,
        ws_url=el.ws_url,
        auth_url=el.auth_url,
        driver_url=driver.driver_url,
        proposer_url=proposer.proposer_url,
        enode=el.enode,
        # enr=el.enr,
    )

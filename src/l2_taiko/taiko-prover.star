PROVER_PORT_NUM = 1234

def launch(
    plan,
    data_dirpath,
    jwtsecret_path,
    el_context,
    cl_context,
    geth,
    prefunded_accounts,
    index,
):
    jwtsecret_file = "/tmp/jwt/jwtsecret"
    service = plan.add_service(
        name = "preconf-taiko-prover-{0}".format(index),
        config = ServiceConfig(
            image = "nethsurge/taiko-client:latest",
            files = {
                "/data/taiko-geth": "taiko_files",
                "/tmp/jwt": "l2_jwt_files",
            },
            entrypoint = ["taiko-client"],
            cmd = [
                "prover",
                "--l1.ws={0}".format(el_context.ws_url),
                "--l2.http={0}".format(geth.rpc_http_url),
                "--l2.ws={0}".format(geth.ws_url),
                "--taikoL1=0xaE37C7A711bcab9B0f8655a97B738d6ccaB6560B",
                "--taikoL2=0x1670000000000000000000000000000000010001",
                # "--jwtSecret={0}".format(jwtsecret_path),
                # "--taikoToken=0x8F0342A7060e76dfc7F6e9dEbfAD9b9eC919952c",
                "--l1.proverPrivKey={0}".format(prefunded_accounts[3].private_key),
                "--prover.capacity=1",
                # "--raiko.host="
            ],
        ),
    )

    # proposer_url = "http://{0}:{1}".format(service.ip_address, PROPOSER_PORT_NUM)

    return struct(
        client_name="taiko-prover",
        ip_addr=service.ip_address,
        prover_port_num=PROVER_PORT_NUM,
        # prover_url=prover_url,
        service_name=service.name,
    )

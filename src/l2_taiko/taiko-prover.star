PROPOSER_PORT_NUM = 1234

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
        name = "preconf-taiko-proposer-{0}".format(index),
        config = ServiceConfig(
            image = "us-docker.pkg.dev/evmchain/images/taiko-client:taiko-client-v0.38.0",
            files = {
                "/data/taiko-geth": "taiko_files",
                "/tmp/jwt": "l2_jwt_files",
            },
            # ports = {
            #     "proposer-port": PortSpec(
            #         number=1234, transport_protocol="TCP"
            #     )
            # },
            entrypoint = ["taiko-client"],
            cmd = [
                "proposer",
                "--l1.ws={0}".format(el_context.ws_url),
                "--l2.http={0}".format(geth.rpc_http_url),
                "--l2.auth={0}".format(geth.auth_url),
                "--taikoL1=0xaDe68b4b6410aDB1578896dcFba75283477b6b01",
                "--taikoL2=00x1670000000000000000000000000000000010001",
                "--jwtSecret={0}".format(jwtsecret_path),
                "--taikoToken=0x8F0342A7060e76dfc7F6e9dEbfAD9b9eC919952c",
                "--l1.proposerPrivKey={0}".format(prefunded_accounts[0].private_key),
                "--l2.suggestedFeeRecipient=0x8e81D13339eE01Bb2080EBf9796c5F2e5621f7E1",
                "--tierFee.optimistic=1",
                "--tierFee.sgx=1",
                "--l1.blobAllowed",
                "--tx.gasLimit=3000000",
            ],
        ),
    )

    proposer_url = "http://{0}:{1}".format(service.ip_address, PROPOSER_PORT_NUM)

    return struct(
        client_name="taiko-proposer",
        ip_addr=service.ip_address,
        proposer_port_num=PROPOSER_PORT_NUM,
        proposer_url=proposer_url,
        service_name=service.name,
    )

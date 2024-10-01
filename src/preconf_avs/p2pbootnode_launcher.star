P2PBOOTNODE_SHARED = "bootnode-shared"

def launch(
    plan,
):
    plan.add_service(
        name = "taiko-preconf-bootnode",
        config = ServiceConfig(
            image = "nethswitchboard/bootnodep2p:e2e",
            cmd = [
                "p2p-boot-node",
                "p2pbootnode_ip_placeholder",
                "9000",
            ],
            private_ip_address_placeholder = "p2pbootnode_ip_placeholder",
            env_vars={
            },
            files = {
                "/shared": Directory(
                    persistent_key=P2PBOOTNODE_SHARED,
                ),
            },
        ),
    )

    bootnode_enr = plan.exec(
        service_name = "taiko-preconf-bootnode",
        recipe = ExecRecipe(
            command = [
                "cat",
                "/shared/enr.txt",
            ],
        ),
        description = "Reading bootnode ENR",
    )

    return struct(
        client_name="preconf-bootnode",
        bootnode_enr=bootnode_enr["output"],
    )

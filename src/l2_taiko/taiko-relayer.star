RELAYER_API_PORT_NUM = 4102
RELAYER_L2_API_PORT_NUM = 4102
RABBITMQ_PORT_NUM = 5672
RABBITMQ_MANAGEMENT_PORT_NUM = 15672
MYSQL_PORT_NUM = 3306

def launch_relayer_infrastructure(
    plan,
    mysql_password = "root",
    mysql_database = "relayer",
    mysql_user = "root",
    rabbitmq_user = "guest",
    rabbitmq_password = "guest",
):
    """Launch the infrastructure services (MySQL and RabbitMQ) required for the relayer"""
    
    # Launch MySQL database
    mysql_service = plan.add_service(
        name = "relayer-mysql-db",
        config = ServiceConfig(
            image = "mysql:8.0",
            env_vars = {
                "MYSQL_DATABASE": mysql_database,
                "MYSQL_ROOT_PASSWORD": mysql_password,
            },
            ports = {
                "mysql": PortSpec(number = MYSQL_PORT_NUM, transport_protocol = "TCP"),
            },
        ),
    )

    # Launch RabbitMQ
    rabbitmq_service = plan.add_service(
        name = "relayer-rabbitmq",
        config = ServiceConfig(
            image = "rabbitmq:3-management-alpine",
            env_vars = {
                "RABBITMQ_DEFAULT_USER": rabbitmq_user,
                "RABBITMQ_DEFAULT_PASS": rabbitmq_password,
            },
            ports = {
                "rabbitmq": PortSpec(number = RABBITMQ_PORT_NUM, transport_protocol = "TCP"),
                "management": PortSpec(number = RABBITMQ_MANAGEMENT_PORT_NUM, transport_protocol = "TCP"),
                "prometheus": PortSpec(number = 15692, transport_protocol = "TCP"),
            },
        ),
    )

    return struct(
        mysql_service = mysql_service,
        rabbitmq_service = rabbitmq_service,
        mysql_host = mysql_service.ip_address,
        rabbitmq_host = rabbitmq_service.ip_address,
    )

def run_migrations(
    plan,
    infrastructure,
    mysql_database = "relayer",
    mysql_user = "root",
    mysql_password = "root",
    migrations_path = "./migrations",
):
    """Run database migrations using goose-docker"""
    
    migrations_service = plan.add_service(
        name = "relayer-migrations",
        config = ServiceConfig(
            image = "nethsurge/relayer-migration:taiko",
            env_vars = {
                "GOOSE_DRIVER": "mysql",
                "GOOSE_DBSTRING": "{0}:{1}@tcp({2}:3306)/{3}".format(
                    mysql_user,
                    mysql_password,
                    infrastructure.mysql_host,
                    mysql_database
                ),
            },
        ),
    )
    
    return migrations_service

def launch_relayer_l1_services(
    plan,
    infrastructure,
    l1_rpc_url,
    l2_rpc_url,
    contracts_addresses,
    processorPrivateKey,
    mysql_config = None,
    rabbitmq_config = None,
):
    """Launch L1 relayer services (indexer, processor, and API)"""
    
    # Default configurations
    if mysql_config == None:
        mysql_config = {
            "password": "root",
            "database": "relayer", 
            "user": "root",
            "max_idle_conns": "10",
            "max_open_conns": "100",
            "conn_max_lifetime": "3600",
        }
    
    if rabbitmq_config == None:
        rabbitmq_config = {
            "user": "guest",
            "password": "guest",
            "port": str(RABBITMQ_PORT_NUM),
        }

    # Common environment variables for all L1 relayer services
    common_db_args = [
        "--db.host=" + infrastructure.mysql_host,
        "--db.name=" + mysql_config["database"],
        "--db.password=" + mysql_config["password"],
        "--db.username=" + mysql_config["user"],
        "--db.maxIdleConns=" + mysql_config["max_idle_conns"],
        "--db.maxOpenConns=" + mysql_config["max_open_conns"],
    ]

    common_queue_args = [
        "--queue.host=" + infrastructure.rabbitmq_host,
        "--queue.password=" + rabbitmq_config["password"],
        "--queue.port=" + rabbitmq_config["port"],
        "--queue.username=" + rabbitmq_config["user"],
    ]

    # L1 Indexer
    l1_indexer = plan.add_service(
        name = "relayer-l1-indexer",
        config = ServiceConfig(
            image = "nethsurge/relayer:taiko",
            entrypoint = ["/usr/local/bin/relayer"],
            cmd = [
                "indexer",
                "--db.connMaxLifetime=" + mysql_config["conn_max_lifetime"],
                "--srcBridgeAddress=" + contracts_addresses.l1_bridge,
                "--srcTaikoAddress=" + contracts_addresses.taiko_l1,
                "--srcSignalServiceAddress=" + contracts_addresses.l1_signal_service,
                "--srcRpcUrl=" + l1_rpc_url,
                "--destBridgeAddress=" + contracts_addresses.l2_bridge,
                "--destRpcUrl=" + l2_rpc_url,
                "--maxNumGoroutines=10",
                "--blockBatchSize=100",
                "--event=MessageSent",
                "--confirmations=0",
            ] + common_db_args + common_queue_args,
        ),
    )

    # L1 Processor  
    l1_processor = plan.add_service(
        name = "relayer-l1-processor",
        config = ServiceConfig(
            image = "nethsurge/relayer:taiko",
            entrypoint = ["/usr/local/bin/relayer"],
            cmd = [
                "processor",
                "--queue.prefetch=100",
                "--processorPrivateKey=" + processorPrivateKey,
                "--srcSignalServiceAddress=" + contracts_addresses.l1_signal_service,
                "--srcRpcUrl=" + l1_rpc_url,
                "--destBridgeAddress=" + contracts_addresses.l2_bridge,
                "--destERC20VaultAddress=" + contracts_addresses.l2_erc20_vault,
                "--destERC721Address=" + contracts_addresses.l2_erc721_vault,
                "--destERC1155Address=" + contracts_addresses.l2_erc1155_vault,
                "--destTaikoAddress=" + contracts_addresses.taiko_l2,
                "--destRpcUrl=" + l2_rpc_url,
                "--confirmations=0",
                "--headerSyncInterval=2",
                "--profitableOnly=false",
                "--tx.minTipCap=0.01",
            ] + common_db_args + common_queue_args,
        ),
    )

    # L1 API
    l1_api = plan.add_service(
        name = "relayer-l1-api",
        config = ServiceConfig(
            image = "nethsurge/relayer:taiko",
            entrypoint = ["/usr/local/bin/relayer"],
            ports = {
                "api": PortSpec(number = RELAYER_API_PORT_NUM, transport_protocol = "TCP"),
            },
            cmd = [
                "api",
                "--db.connMaxLifetime=" + mysql_config["conn_max_lifetime"],
                "--srcRpcUrl=" + l1_rpc_url,
                "--destRpcUrl=" + l2_rpc_url,
                "--destTaikoAddress=" + contracts_addresses.taiko_l2,
                "--processingFeeMultiplier=1",
            ] + common_db_args,
        ),
    )

    return struct(
        l1_indexer = l1_indexer,
        l1_processor = l1_processor,
        l1_api = l1_api,
        l1_api_url = "http://{0}:{1}".format(l1_api.ip_address, RELAYER_API_PORT_NUM),
    )

def launch_relayer_l2_services(
    plan,
    infrastructure,
    l2_rpc_url,
    l1_rpc_url,
    contracts_addresses,
    processorPrivateKey,
    mysql_config = None,
    rabbitmq_config = None,
):
    """Launch L2 relayer services (indexer, processor, and API)"""
    
    # Default configurations
    if mysql_config == None:
        mysql_config = {
            "password": "root",
            "database": "relayer",
            "user": "root", 
            "max_idle_conns": "10",
            "max_open_conns": "100",
            "conn_max_lifetime": "3600",
        }
    
    if rabbitmq_config == None:
        rabbitmq_config = {
            "user": "guest",
            "password": "guest",
            "port": str(RABBITMQ_PORT_NUM),
        }

    # Common environment variables for all L2 relayer services
    common_db_args = [
        "--db.host=" + infrastructure.mysql_host,
        "--db.name=" + mysql_config["database"],
        "--db.password=" + mysql_config["password"],
        "--db.username=" + mysql_config["user"],
        "--db.maxIdleConns=" + mysql_config["max_idle_conns"],
        "--db.maxOpenConns=" + mysql_config["max_open_conns"],
    ]

    common_queue_args = [
        "--queue.host=" + infrastructure.rabbitmq_host,
        "--queue.password=" + rabbitmq_config["password"],
        "--queue.port=" + rabbitmq_config["port"],
        "--queue.username=" + rabbitmq_config["user"],
    ]

    # L2 Indexer
    l2_indexer = plan.add_service(
        name = "relayer-l2-indexer",
        config = ServiceConfig(
            image = "nethsurge/relayer:taiko",
            entrypoint = ["/usr/local/bin/relayer"],
            cmd = [
                "indexer",
                "--db.connMaxLifetime=" + mysql_config["conn_max_lifetime"],
                "--srcBridgeAddress=" + contracts_addresses.l2_bridge,
                "--srcSignalServiceAddress=" + contracts_addresses.l2_signal_service,
                "--srcRpcUrl=" + l2_rpc_url,
                "--destBridgeAddress=" + contracts_addresses.l1_bridge,
                "--destRpcUrl=" + l1_rpc_url,
                "--maxNumGoroutines=10",
                "--blockBatchSize=100",
                "--event=MessageSent",
                "--confirmations=0",
            ] + common_db_args + common_queue_args,
        ),
    )

    # L2 Processor
    l2_processor = plan.add_service(
        name = "relayer-l2-processor", 
        config = ServiceConfig(
            image = "nethsurge/relayer:taiko",
            entrypoint = ["/usr/local/bin/relayer"],
            cmd = [
                "processor",
                "--queue.prefetch=100",
                "--processorPrivateKey=" + processorPrivateKey,
                "--srcSignalServiceAddress=" + contracts_addresses.l2_signal_service,
                "--srcRpcUrl=" + l2_rpc_url,
                "--destBridgeAddress=" + contracts_addresses.l1_bridge,
                "--destERC20VaultAddress=" + contracts_addresses.l1_erc20_vault,
                "--destERC721Address=" + contracts_addresses.l1_erc721_vault,
                "--destERC1155Address=" + contracts_addresses.l1_erc1155_vault,
                "--destTaikoAddress=" + contracts_addresses.taiko_l1,
                "--destRpcUrl=" + l1_rpc_url,
                "--confirmations=0",
                "--headerSyncInterval=2",
                "--profitableOnly=false",
                "--tx.minTipCap=0.01",
            ] + common_db_args + common_queue_args,
        ),
    )

    # L2 API
    l2_api = plan.add_service(
        name = "relayer-l2-api",
        config = ServiceConfig(
            image = "nethsurge/relayer:taiko",
            entrypoint = ["/usr/local/bin/relayer"],
            ports = {
                "api": PortSpec(number = RELAYER_L2_API_PORT_NUM, transport_protocol = "TCP"),
            },
            cmd = [
                "api",
                "--db.connMaxLifetime=" + mysql_config["conn_max_lifetime"],
                "--srcRpcUrl=" + l2_rpc_url,
                "--destRpcUrl=" + l1_rpc_url,
                "--destTaikoAddress=" + contracts_addresses.taiko_l1,
                "--processingFeeMultiplier=1",
            ] + common_db_args,
        ),
    )

    return struct(
        l2_indexer = l2_indexer,
        l2_processor = l2_processor,
        l2_api = l2_api,
        l2_api_url = "http://{0}:{1}".format(l2_api.ip_address, RELAYER_L2_API_PORT_NUM),
    )

def launch(
    plan,
    el_context,
    l2_rpc_url,
    contracts_addresses,
    prefunded_accounts,
):
    """Main function to launch all relayer services"""
    l1_rpc_url = el_context.rpc_http_url
    
    processorPrivateKey = prefunded_accounts[0].private_key
    
    # Launch infrastructure services
    infrastructure = launch_relayer_infrastructure(plan)
    
    # Wait for MySQL to be ready
    plan.wait(
        service_name = infrastructure.mysql_service.name,
        recipe = ExecRecipe(
            command = ["mysqladmin", "ping", "-h", "localhost", "--silent"]
        ),
        field = "code",
        assertion = "==",
        target_value = 0,
        timeout = "60s",
    )
    
    # Run database migrations
    migrations_service = run_migrations(plan, infrastructure)

    # Launch L1 relayer services
    l1_services = launch_relayer_l1_services(
        plan,
        infrastructure,
        l2_rpc_url,
        l1_rpc_url,
        contracts_addresses,
        processorPrivateKey,
    )

    # Launch L2 relayer services
    l2_services = launch_relayer_l2_services(
        plan,
        infrastructure,
        l2_rpc_url,
        l1_rpc_url,
        contracts_addresses,
        processorPrivateKey,
    )

    return struct(
        infrastructure = infrastructure,
        l1_services = l1_services,
        l2_services = l2_services,
        l1_api_url = l1_services.l1_api_url,
        l2_api_url = l2_services.l2_api_url,
    ) 
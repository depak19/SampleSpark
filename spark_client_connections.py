from pyspark.sql import SparkSession
from pyspark import SparkConf, SparkContext
import os

def connect_local():
    """
    Connect to Spark in local mode
    """
    print("\n1. Connecting to Spark in local mode:")
    
    spark = SparkSession.builder \
        .appName("Persistent Table Example") \
        .config("spark.sql.warehouse.dir", "/opt/spark/hive/warehouse") \
        .enableHiveSupport() \
        .config("spark.driver.memory", "16g") \
        .config("spark.executor.memory", "16g") \
        .config("spark.executor.cores", "4") \
        .getOrCreate()
    
    print("Successfully connected to  Spark DataBase")
    print("\nUpdated Table Content:")
    spark.sql("SELECT * FROM persistent_data.people_table ORDER BY age").show()
    return spark

def connect_standalone(master_url: str = None):
    """
    Connect to Spark Standalone cluster.

    The standalone master URL may be provided via the `master_url` argument
    or the `SPARK_MASTER_URL` environment variable. If neither is provided
    the function falls back to `spark://127.0.0.1:7077` for local standalone
    testing.
    """
    print("\n2. Connecting to Spark Standalone cluster:")

    # prefer explicit arg, then env var, then sensible default
    if master_url is None:
        # default to local[*] for quick local testing (avoids connection refused when no standalone master)
        master_url = os.environ.get("SPARK_MASTER_URL", "local[*]")

    # simple validation: hostnames must not contain underscores and URL must start with spark://
    if not master_url.startswith("spark://") and not master_url.startswith("local"):
        raise ValueError(
            "Invalid master URL: must start with 'spark://' or be a local master like 'local[*]'."
        )

    # detect invalid hostname characters (underscore is commonly used in container names but is invalid as DNS hostname)
    # extract host:port if spark://
    if master_url.startswith("spark://"):
        hostport = master_url[len("spark://"):]
        # if there are multiple addresses, do a basic check on each
        for addr in hostport.split(","):
            # strip any trailing path (shouldn't be present) and whitespace
            a = addr.split("/")[0].strip()
            if "_" in a:
                raise ValueError(
                    f"Invalid master URL: hostname '{a}' contains an underscore.\n"
                    "Hostnames must not contain underscores — use hyphens or dots, or set SPARK_MASTER_URL to a valid address."
                )

    print(f"Using Spark master: {master_url}")

    spark = SparkSession.builder \
        .appName("Standalone Spark Connection") \
        .master(master_url) \
        .config("spark.sql.warehouse.dir", "/opt/spark/hive/warehouse") \
        .config("spark.driver.memory", "16g") \
        .config("spark.executor.memory", "16g") \
        .config("spark.executor.cores", "4") \
        .getOrCreate()

    print("Successfully connected to Standalone cluster")
    return spark

def connect_yarn():
    """
    Connect to YARN cluster
    """
    print("\n3. Connecting to YARN cluster:")
    
    # Prefer existing HADOOP_CONF_DIR or YARN_CONF_DIR; only set default if the directory exists.
    default_hadoop_conf = "/etc/hadoop/conf"
    has_env_conf = "HADOOP_CONF_DIR" in os.environ or "YARN_CONF_DIR" in os.environ
    if not has_env_conf:
        if os.path.isdir(default_hadoop_conf):
            os.environ["HADOOP_CONF_DIR"] = default_hadoop_conf
            has_env_conf = True
        else:
            # Fail fast with a clear error so Spark doesn't exit with a confusing Java Gateway error
            raise RuntimeError(
                "When running with master 'yarn' either HADOOP_CONF_DIR or YARN_CONF_DIR must be set.\n"
                "Set one to the Hadoop/YARN configuration directory from your cluster before running.\n"
                "Example:\n"
                "  export HADOOP_CONF_DIR=/path/to/hadoop/conf\n"
                "  export YARN_CONF_DIR=/path/to/hadoop/conf\n"
                "Then re-run the script. If you do not have a Hadoop/YARN cluster available, use local mode:\n"
                "  export SPARK_MASTER_URL='local[*]' && python3 /home/user1/sampledata/spark_client_connections.py"
            )

    # Attempt to determine a non-loopback local IP for binding/advertising.
    local_ip = os.environ.get("SPARK_LOCAL_IP")
    if not local_ip:
        try:
            import socket
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            local_ip = s.getsockname()[0]
            s.close()
            # only set if we resolved something useful
            if local_ip and not local_ip.startswith("127."):
                os.environ.setdefault("SPARK_LOCAL_IP", local_ip)
        except Exception:
            local_ip = None

    # Build the SparkSession; include spark.driver.host if we have a useful local_ip.
    builder = SparkSession.builder \
        .appName("YARN Spark Connection") \
        .master("yarn") \
        .config("spark.yarn.am.memory", "2g") \
        .config("spark.executor.memory", "2g") \
        .config("spark.executor.cores", "2") \
        .config("spark.yarn.submit.waitAppCompletion", "true")

    if local_ip:
        builder = builder.config("spark.driver.host", local_ip)

    spark = builder.getOrCreate()
     
    print("Successfully connected to YARN cluster")
    return spark

def connect_kubernetes():
    """
    Connect to Kubernetes cluster

    - If running inside a pod, the in-cluster service DNS is used.
    - If running outside the cluster, attempt to read kubeconfig (kubectl) to find the API server.
      If that fails, require SPARK_K8S_MASTER to be set.
    """
    print("\n4. Connecting to Kubernetes cluster:")

    # detect in-cluster environment
    in_cluster = "KUBERNETES_SERVICE_HOST" in os.environ

    # prefer explicit env
    master_url = os.environ.get("SPARK_K8S_MASTER")

    # if not specified, try in-cluster service DNS
    if not master_url and in_cluster:
        master_url = "k8s://https://kubernetes.default.svc:443"

    # if still not specified, try to extract from kubeconfig via kubectl (if available)
    if not master_url:
        try:
            import subprocess
            cmd = [
                "kubectl",
                "config",
                "view",
                "--minify",
                "-o",
                "jsonpath={.clusters[0].cluster.server}",
            ]
            server = subprocess.check_output(cmd, stderr=subprocess.DEVNULL, text=True).strip()
            if server:
                # normalize to Spark k8s master form
                if not server.startswith("http"):
                    server = "https://" + server
                master_url = "k8s://" + server
        except Exception:
            master_url = None

    if not master_url:
        raise RuntimeError(
            "Kubernetes master not detected. When running outside a cluster set SPARK_K8S_MASTER to "
            "a valid API server URL (example: k8s://https://<api-server-host>:6443) and ensure kubeconfig/credentials are available.\n"
            "Quick checks:\n"
            "  - Inspect your kubeconfig: cat ~/.kube/config\n"
            "  - Get the server URL: kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'\n"
            "  - Test reachability: curl -k <server-url>\n"
            "Example env:\n"
            "  export SPARK_K8S_MASTER='k8s://https://1.2.3.4:6443'\n"
            "  export SPARK_K8S_IMAGE='your-registry/your-spark-image:tag'\n"
        )

    image = os.environ.get("SPARK_K8S_IMAGE", "apache/spark:v4.0.0")
    namespace = os.environ.get("SPARK_K8S_NAMESPACE", "spark")

    print(f"Using Kubernetes master: {master_url} (namespace={namespace}, image={image})")

    spark = SparkSession.builder \
        .appName("Kubernetes Spark Connection") \
        .master(master_url) \
        .config("spark.kubernetes.container.image", image) \
        .config("spark.kubernetes.namespace", namespace) \
        .config("spark.executor.instances", "2") \
        .config("spark.driver.memory", "2g") \
        .config("spark.executor.memory", "2g") \
        .getOrCreate()

    print("Successfully connected to Kubernetes cluster")
    return spark

def test_connection(spark):
    """
    Test the Spark connection by running a simple operation
    """
    print("\nTesting Spark Connection:")
    
    # Create a sample DataFrame
    data = [("Test", 1), ("Connection", 2), ("Successful", 3)]
    df = spark.createDataFrame(data, ["word", "count"])
    
    print("\nSample DataFrame:")
    df.show()
    
    # Perform a simple transformation
    result = df.select("word").collect()
    print("\nConnection test successful!")
    
    return result

def show_connection_info(spark):
    """
    Display information about the Spark connection
    """
    print("\nSpark Connection Information:")
    print(f"Spark Version: {spark.version}")
    print(f"Master: {spark.sparkContext.master}")
    print(f"App ID: {spark.sparkContext.applicationId}")
    print(f"App Name: {spark.sparkContext.appName}")
    
    # Show active configuration
    print("\nActive Spark Configuration:")
    for item in spark.sparkContext.getConf().getAll():
        print(f"{item[0]}: {item[1]}")

def main():
    try:
        # Example of connecting in local mode
        # spark = connect_local()
        
        # Test the connection
        # test_connection(spark)
        
        # Show connection information
        # how_connection_info(spark)
        
        # Note: Uncomment the following sections to test other connection methods
        # Remember to have the appropriate cluster setup first
        
        # # Connect to Standalone cluster
        # spark_standalone = connect_standalone()
        # test_connection(spark_standalone)
        # spark_standalone.stop()
        
        # # Connect to YARN cluster
        # spark_yarn = connect_yarn()
        # test_connection(spark_yarn)
        # spark_yarn.stop()
        
        # # Connect to Kubernetes cluster
        spark_k8s = connect_kubernetes()
        test_connection(spark_k8s)
        spark_k8s.stop()
        
    except Exception as e:
        print(f"Error: {str(e)}")
    finally:
        # Stop the Spark session
        if "spark" in locals():
            spark.stop()

if __name__ == "__main__":
    main()
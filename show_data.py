from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from pyspark.sql.functions import *
import time

# Initialize Spark Session with Hive support
spark = SparkSession.builder \
    .appName("Insert New Record") \
    .config("spark.sql.warehouse.dir", "/opt/spark/hive/warehouse") \
    .enableHiveSupport() \
    .config("spark.driver.memory", "8g") \
    .config("spark.executor.memory", "8g") \
    .config("spark.executor.cores", "2") \
    .getOrCreate()

# Reduce default shuffle partitions for small/medium local runs to avoid many small tasks
spark.conf.set("spark.sql.shuffle.partitions", "8")

# Verify the insertion by showing all records
print("\nUpdated Table Content:")

# Read the table once, filter once, then reuse/cache to avoid multiple scans
start = time.time()
df_all = spark.table("persistent_data.census")
df_filtered = df_all.filter((col("age") >= 40) & (col("age") <= 50))

# Cache the filtered dataframe since we run multiple actions against it
df_filtered.cache()
# Materialize cache (will trigger a job)
count_before = df_filtered.count()
print(f"Cached filtered rows: {count_before}")
print(f"Materialize cache time: {time.time() - start:.2f}s")

# Show a limited sample (avoids collecting huge result sets)
show_start = time.time()
df_filtered.show(50, truncate=False)
print(f"Show sample time: {time.time() - show_start:.2f}s")

# Get the total count of records (fast because of cache)
count_start = time.time()
count = df_filtered.count()
print(f"\nTotal number of records after insertion: {count} (count time: {time.time() - count_start:.2f}s)")

# Group by Year across the full dataset (single scan of df_all)
group_start = time.time()
df_all.groupBy("Year").count().orderBy("Year").show()
print(f"GroupBy time: {time.time() - group_start:.2f}s")


spark.stop()
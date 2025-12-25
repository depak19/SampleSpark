from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from pyspark.sql.functions import *

# Initialize Spark Session with Hive support
spark = SparkSession.builder \
    .appName("Insert New Record") \
    .config("spark.sql.warehouse.dir", "/opt/spark/hive/warehouse") \
    .enableHiveSupport() \
    .getOrCreate()

# Create a new record as a DataFrame
new_data = [(6, "David Wilson", 29, "Seattle")]
schema = StructType([
    StructField("id", IntegerType(), False),
    StructField("name", StringType(), False),
    StructField("age", IntegerType(), False),
    StructField("city", StringType(), False)
])

new_record_df = spark.createDataFrame(new_data, schema)

# Show the new record
print("New Record to Insert:")
new_record_df.show()

# Insert the new record into the existing table
new_record_df.write \
    .mode("append") \
    .format("parquet") \
    .saveAsTable("persistent_data.people_table")

# Verify the insertion by showing all records
print("\nUpdated Table Content:")
spark.sql("SELECT * FROM persistent_data.people_table ORDER BY id").show()

# Get the total count of records
count = spark.sql("SELECT COUNT(*) as total_records FROM persistent_data.people_table").collect()[0]["total_records"]
print(f"\nTotal number of records after insertion: {count}")

spark.stop()
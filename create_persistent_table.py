from pyspark.sql import SparkSession

# Initialize Spark Session with Hive support
spark = SparkSession.builder \
    .appName("Persistent Table Example") \
    .config("spark.sql.warehouse.dir", "/opt/spark/hive/warehouse") \
    .enableHiveSupport() \
    .config("spark.driver.memory", "16g") \
    .config("spark.executor.memory", "16g") \
    .config("spark.executor.cores", "4") \
    .getOrCreate()

# Define the schema for the CSV file
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

schema = StructType([
    StructField("Year", IntegerType(), False),
    StructField("Age", IntegerType(), False),
    StructField("Ethnic", IntegerType(), False),
    StructField("Sex", IntegerType(), False),
    StructField("Area", StringType(), False),
    StructField("Count", IntegerType(), False),
])

# Read the CSV file into a DataFrame
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "false") \
    .schema(schema) \
    .csv("/home/user1/sampledata/csvdata/Data8277.csv")

# Create a database if it doesn not exist
spark.sql("CREATE DATABASE IF NOT EXISTS census")

# Save the DataFrame as a permanent table
df.write \
    .mode("overwrite") \
    .format("parquet") \
    .saveAsTable("persistent_data.census")

# Verify the table was created and data was saved
print("\nTable Schema:")
spark.sql("DESCRIBE persistent_data.census").show()

print("\nTable Content:")
spark.sql("SELECT * FROM persistent_data.census").show()

# Show table location
print("\nTable Location:")
table_location = spark.sql("DESCRIBE FORMATTED persistent_data.census").filter("col_name = \'Year\'").select("data_type").collect()[0][0]
print(table_location)

print("\nVerification: Reading from the saved table")
# Read from the saved table to verify persistence
saved_df = spark.table("persistent_data.census")
saved_df.show()

# Get the total count of records
count = spark.sql("SELECT COUNT(*) as total_records FROM persistent_data.people_table").collect()[0]["total_records"]
print(f"\nTotal number of records after insertion: {count}")

# Stop the Spark session
spark.stop()

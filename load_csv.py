from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType

# Initialize Spark Session
spark = SparkSession.builder \
    .appName("CSV Loading Example") \
    .getOrCreate()

# Define the schema for the CSV file
schema = StructType([
    StructField("id", IntegerType(), False),
    StructField("name", StringType(), False),
    StructField("age", IntegerType(), False),
    StructField("city", StringType(), False)
])

# Read the CSV file into a DataFrame
df = spark.read \
    .option("header", "true") \
    .option("inferSchema", "false") \
    .schema(schema) \
    .csv("sample_data.csv")

# Show the data
print("\nDataFrame Content:")
df.show()

# Print the schema
print("\nDataFrame Schema:")
df.printSchema()

# Register the DataFrame as a temporary table
df.createOrReplaceTempView("people")

# Run a sample SQL query
print("\nSQL Query Result (people over 30):")
spark.sql("SELECT * FROM people WHERE age > 30").show()

# Some basic DataFrame operations
print("\nAverage age by city:")
df.groupBy("city").avg("age").show()

# Stop the Spark session
spark.stop()

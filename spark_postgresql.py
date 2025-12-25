from pyspark.sql import SparkSession

# Initialize Spark Session
spark = SparkSession.builder \
    .appName("Spark PostgreSQL Connection") \
    .config("spark.jars", "/path/to/postgresql-42.7.1.jar") \
    .getOrCreate()

# PostgreSQL connection properties
postgresql_properties = {
    "driver": "org.postgresql.Driver",
    "url": "jdbc:postgresql://localhost:5432/your_database",
    "user": "your_username",
    "password": "your_password"
}

# Read data from PostgreSQL
df = spark.read \
    .format("jdbc") \
    .option("driver", postgresql_properties["driver"]) \
    .option("url", postgresql_properties["url"]) \
    .option("dbtable", "your_table") \
    .option("user", postgresql_properties["user"]) \
    .option("password", postgresql_properties["password"]) \
    .load()

print("Data from PostgreSQL:")
df.show()

# Write data back to PostgreSQL
df.write \
    .format("jdbc") \
    .option("driver", postgresql_properties["driver"]) \
    .option("url", postgresql_properties["url"]) \
    .option("dbtable", "new_table") \
    .option("user", postgresql_properties["user"]) \
    .option("password", postgresql_properties["password"]) \
    .mode("overwrite") \
    .save()

spark.stop()
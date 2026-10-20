spark.sql("""
    CREATE SCHEMA IF NOT EXISTS `01_ecommerce_dev`.bronze
""")

print("Bronze schema is ready.")
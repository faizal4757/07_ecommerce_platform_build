import subprocess

schemas = [
    ("dev_bronze", "01_ecommerce_dev.bronze"),
    ("dev_silver", "01_ecommerce_dev.silver"),
    ("dev_gold", "01_ecommerce_dev.gold"),
    ("stg_bronze", "02_ecommerce_stg.bronze"),
    ("stg_silver", "02_ecommerce_stg.silver"),
    ("stg_gold", "02_ecommerce_stg.gold"),
    ("prod_bronze", "03_ecommerce_prod.bronze"),
    ("prod_silver", "03_ecommerce_prod.silver"),
    ("prod_gold", "03_ecommerce_prod.gold"),
]

for key, id in schemas:
    addr = f'databricks_schema.medallion["{key}"]'
    print(f"Importing {addr}")
    subprocess.run(["terraform", "import", addr, id])
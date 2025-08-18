# Configuration for Data Import Script

echo "-------------- Générer les données à partir du langage python  -----------------------"
#python3 ../data-generator/generate-business-data.py

import csv
import json
import requests

ES_URL = "http://localhost:9200/sales-data/_bulk"
ES_AUTH = ("elastic", "changeme")

with open("data/sales/sales.csv", "r") as f:
    reader = csv.DictReader(f)
    bulk_data = ""
    for row in reader:
        bulk_data += json.dumps({"index": {}}) + "\n"
        bulk_data += json.dumps(row) + "\n"

response = requests.post(ES_URL, auth=ES_AUTH, headers={"Content-Type": "application/x-ndjson"}, data=bulk_data)
print(response.json())

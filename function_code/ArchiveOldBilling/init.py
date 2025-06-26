import datetime
import logging
import azure.functions as func
import os
import json
from azure.cosmos import CosmosClient, PartitionKey
from azure.storage.blob import BlobServiceClient

# Environment variables
COSMOS_ENDPOINT = os.environ["COSMOS_ENDPOINT"]
COSMOS_KEY = os.environ["COSMOS_KEY"]
COSMOS_DB = os.environ["COSMOS_DB"]
COSMOS_CONTAINER = os.environ["COSMOS_CONTAINER"]
ARCHIVE_CONTAINER = os.environ["ARCHIVE_CONTAINER"]
BLOB_CONNECTION_STRING = os.environ["AzureWebJobsStorage"]

def main(mytimer: func.TimerRequest) -> None:
    logging.info("Starting archive process")

    client = CosmosClient(COSMOS_ENDPOINT, COSMOS_KEY)
    db = client.get_database_client(COSMOS_DB)
    container = db.get_container_client(COSMOS_CONTAINER)

    blob_service = BlobServiceClient.from_connection_string(BLOB_CONNECTION_STRING)
    blob_container = blob_service.get_container_client(ARCHIVE_CONTAINER)

    cutoff_date = (datetime.datetime.utcnow() - datetime.timedelta(days=90)).isoformat()

    query = f"SELECT * FROM c WHERE c.createdAt < '{cutoff_date}'"
    archived_count = 0

    for item in container.query_items(query=query, enable_cross_partition_query=True):
        record_id = item['id']
        billing_data = json.dumps(item)
        blob_name = f"{record_id}.json"

        blob_container.upload_blob(name=blob_name, data=billing_data, overwrite=True)

        # Optional: soft-delete or tag in Cosmos instead of delete
        container.delete_item(item=item, partition_key=item['partitionKey'])
        archived_count += 1

    logging.info(f"Archived {archived_count} records.")

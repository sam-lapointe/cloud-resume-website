from azure.data.tables import TableServiceClient, UpdateMode
from azure.core import exceptions

import os 
import logging

CONNECTION_STRING = os.environ["PersonalWebsite_DB_ConnectionString"]
SERVICE = TableServiceClient.from_connection_string(conn_str=CONNECTION_STRING)
TABLE = SERVICE.get_table_client(table_name="websites_views")

class Entity:
    def __init__(self, website, page):
        try:
            self.entity = TABLE.get_entity(str(website), str(page))
        except exceptions.ResourceNotFoundError:
            self.entity = {
                "PartitionKey": str(website),
                "RowKey": str(page),
                "views": 0
            }

    
    def update_views(self):
        self.entity["views"] += 1

    
    def update_db(self):
        if (self.entity["views"] == 1):
            logging.info(f"Creating an entity. PartitionKey: '{self.entity['PartitionKey']}', RowKey: '{self.entity['page']}'")
            TABLE.create_entity(self.entity)
        else:
            TABLE.update_entity(mode=UpdateMode.REPLACE, entity=self.entity)
# REGISTER A SCHEMA WITH SCHEMA REGISTRY
from azure.schemaregistry import SchemaRegistryClient 
from azure.identity import DefaultAzureCredential

# Define schema
sampleSchema = """
  {"namespace": "com.azure.sampleschema.avro", 
    "type": "record", 
    "name": "Trip", 
  "fields": [ 
    {"name": "tripId", "type": "string"}, 
    {"name": "startLocation", "type": "string"}, 
    {"name": "endLocation", "type": "string"} ] 
  }
 """

# Create schema registry client
azureCredential = DefaultAzureCredential()
schema_registry_client = SchemaRegistryClient( 
  fully_qualified_namespace=<SCHEMA-NAMESPACE>.servicebus.windows.net, 
  credential=azureCredential
)

# Resgister schema
With schema_registry_client: 
  schema_properties = schema_registry_client.register_schema( 
    <SCHEMA_GROUPNAME>, 
    <SCHEMA_NAME>, 
    sampleSchema, 
    "Avro"
  )
  
# Get the schema id
schema_id = schema_properties.id


# RETRIEVE A SCHEMA FROM SCHEMA REGISTRY
from azure.schemaregistry import SchemaRegistryClient 
from azure.identity import DefaultAzureCredential

# Create schema registry client
azureCredential = DefaultAzureCredential()
schema_registry_client = SchemaRegistryClient( 
  fully_qualified_namespace=<SCHEMA-NAMESPACE>.servicebus.windows.net, 
  credential=azureCredential
)

# Retireve schema
With schema_registry_client: 
  schema = schema_registry_client.get_schema(schema_id) 
  definition = schema.definition
  properties = schema.properties

Import asyncio from azure.eventhub.aio 
import EventHubConsumerClient from azure.eventhub.extensions.checkpointstoreblobaio 
import BlobCheckpointStore 

async def on_event(partition_context, event):
  # Process the event 
  # Checkpoint after processing
  await partition_context.update_checkpoint(event)

async def main(): 
  storeChkPoint = BlobCheckpointStore.from_connection_string(
    <STORE_CONN_STRING>, 
    <STORE_CONTAINER_NAME> 
  ) 
  
  ehClient = EventHubConsumerClient.from_connection_string(
    <EVENTHUB_CONN_STRING>, 
    <CONSUMER_GROUP_NAME>, 
    eventhub_name=<EVENTHUB_NAME>, 
    checkpoint_store= storeChkPoint 
   ) 
  
  async with ehClient: 
    await ehClient.receive(on_event) 
 
if __name__ == '__main__': 
  loop = asyncio.get_event_loop() 
  loop.run_until_complete(main())

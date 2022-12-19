# instantiate checkpoint store
storeChkPoint = BlobCheckpointStore.from_connection_string( 
  <STORE_CONN_STRING>, 
  <STORE_CONTAINER_NAME> 
)

# instantiate the EventHubConsumerClient class
ehClient = EventHubConsumerClient.from_connection_string( 
  <EVENTHUB_CONN_STRING>, 
  <CONSUMER_GROUP_NAME>, 
  eventhub_name=<EVENTHUB_NAME>, 
  checkpoint_store= storeChkPoint # This enables load balancing across partitions 
)

# define on_event method to process the event when it arrives
Def on_event(partition_context, event): 
  # Process the event 
  partition_context.update_checkpoint(event)

# call on_event method when an event arrives
With ehClient: 
  ehClient.receive(
    on_event=on_event, 
    starting_position="-1",  # To start from the beginning of the partition. 
 )

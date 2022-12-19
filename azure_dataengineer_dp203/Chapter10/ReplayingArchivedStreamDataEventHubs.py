Consumer_client = EventHubConsumerClient.from_connection_string( 
  conn_str=CONNECTION_STR, 
  consumer_group='$Default', 
  eventhub_name=EVENTHUB_NAME, 
) 

consumer_client.receive( 
  on_event=on_event, 
  partition_id="0", 
  starting_position="-1" # "-1" is the start of the partition. 
)

import pika, os, logging, json
logging.basicConfig(filename = "example_publisher.log", level = logging.DEBUG)

# Parse CLODUAMQP_URL (fallback to localhost)
params = pika.URLParameters("amqp://xcavtrsf:Z0ddLX0_IsuW_JjNRG8MVUq2XeuL15PW@penguin.rmq.cloudamqp.com/xcavtrsf")
params.socket_timeout = 2
params.heartbeat_interval = 1
params.connection_attempts = 10

connection = pika.BlockingConnection(params) # Connect to CloudAMQP
channel = connection.channel() # start a channel
channel.queue_declare(queue='HelloQ') # Declare a queue
# send a message

message = {"datafile" : 'SI_Data_No_Guest_Mod_V0.2.csv',
           "customername" : 'Sequence_Test',
           "Order" : "order",
           "Date" : "date",
           "Customer" : "customer" ,
           "Item" : "item" ,
           "Sales Amount" : "amount",
           "Quantity" : "quantity",
           "Unit Price" : "price"}

#message = "TESTing Connection.close()"

#message = {"datafile" : "24_month_order data2.csv",
#           "customername" : "Nixon_Test",
#           "Document No_" : "order",
#           "Posting Date" : "date",
#           "Customer" : "customer",
#           "Item" : "item",
#           "Sales Amount (Actual)" : "amount",
#           "Quantity" : "quantity",
#           "price" : "price"}

#message = {"datafile" : "",
#           "customername" : "",
#           "0" : "order",
#           "1" : "date",
#           "3" : "customer",
#           "4" : "item",
#           "5" : "amount",
#           "" : "quantity",
#           "" : "price"}


print("Encoding Message as JSON> {}".format(type(json.dumps(message))))

channel.basic_publish(exchange='',
                      routing_key='HelloQ',
                      body=json.dumps(message),
                      properties = pika.BasicProperties(delivery_mode = 2))
print (" [x] Message sent to ETL Process")
connection.close()

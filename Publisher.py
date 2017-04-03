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

message = {"datafile" : 'SI_Data_No_Guest_Mod_Div.csv',
           "customername" : 'RabbitMQ',
           "Order" : "order",
           "Date" : "date",
           "Customer" : "customer" ,
           "Item" : "item" ,
           "Total_Price" : "amount",
           "Quantity" : "quantity",
           "Unit_Price" : "price"}

print("Encoding Message as JSON> {}".format(type(json.dumps(message))))

channel.basic_publish(exchange='',
                      routing_key='HelloQ',
                      body=json.dumps(message),
                      properties = pika.BasicProperties(delivery_mode = 2))
print (" [x] Message sent to ETL Process")
connection.close()

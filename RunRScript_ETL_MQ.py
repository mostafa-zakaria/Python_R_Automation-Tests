import pika, logging, json
import pandas as pd

from subprocess import run, PIPE
from pandas import DataFrame, read_csv, to_numeric, to_datetime
logging.basicConfig(filename = "example_ETLProcess.log", level = logging.DEBUG)

command = 'Rscript'
translationScript = 'Data_Translation.R'
profilingScript = "profiling_sales_item.R"
columnNames = ["order", "date", "customer", "item", "quantity", "amount", "price"]

def consumeMQ(channel):
    # start consuming (blocks)
    print(" [*] Waiting for messages. To exit press CTRL+C")
    channel.start_consuming()

def connectMQ():
    # Parse CLODUAMQP_URL (fallback to localhost)
    params = pika.URLParameters("amqp://xcavtrsf:Z0ddLX0_IsuW_JjNRG8MVUq2XeuL15PW@penguin.rmq.cloudamqp.com/xcavtrsf")
    params.socket_timeout = 2
    params.heartbeat_interval = 1
    params.connection_attempts = 10

    connection = pika.BlockingConnection(params) # Connect to CloudAMQP
    channel = connection.channel() # start a channel

    #set up subscription on the queue
    channel.basic_consume(callbackProcess,
      queue='HelloQ',
      no_ack=True)
    return(connection, channel)

def callbackProcess(ch, method, properties, body):
    args = getArgumentsQueue(body)
    #print(" [**]args type> {}".format(type(args)))
    runSIProfilerArgs(args)
    ch.basic_ack(delivery_tag = method.delivery_tag)
    
def getArgumentsQueue(body):
    if(type(body) != bytes):
        args = body
    else:
        args = json.loads(body.decode('utf-8'))
    return(args)
    
def getColumnMap(args):
    columnMap = {k : v for k, v in args.items() if v in columnNames}
    print(' [**]columnMap> {}'.format(columnMap))
    return(columnMap)

def runETLProcess(args):
    df = pd.read_csv(args['datafile'])

    columnMap = getColumnMap(args)
    df = df.rename(columns = columnMap)
    print(' [**]Column Names> {}'.format(df.columns))

    df["date"] = to_datetime(df["date"], infer_datetime_format = True, errors= 'coerce')

    df["amount"] = to_numeric(df["amount"], downcast = 'float', errors = 'coerce')
    df["quantity"] = to_numeric(df["quantity"], downcast = 'integer', errors = 'coerce')
    df["price"] = to_numeric(df["price"], downcast = 'float', errors = 'coerce')
    
    df.to_csv("Automation_Orders.csv",
              columnNames,
              index = False, index_label = False,
              encoding='utf-8',
              date_format = '%d/%m/%Y')
    return(0)

def runSIProfilerArgs(args):
    try:
        print("Pandas ETL Process> {}".format(runETLProcess(args)))

        cmdStr = " ".join([command, profilingScript, args['customername']])
        CP = run(cmdStr,
                 shell = True,
                 check = True,
                 stdout = PIPE,
                 stderr = PIPE,
                 universal_newlines=True)
        print("\n profiling_sales_item> Return_Code> {0} STDOUT> {1}".format(CP.returncode, CP.stdout))
        return(0)
    except Exception as err:
        print("EXCEPTION RAISED> ReturnCode> {0} STDOUT>{1}".format(err.returncode, err.stdout))
        return(-1)

def main():
    conn, channel = connectMQ()
    consumeMQ(channel)
    conn.close()
    print(' [*]Process Completed> Check Directory for files')
    return(0)
    
print(main())

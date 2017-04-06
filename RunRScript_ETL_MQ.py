import pika, logging, time, json
import pandas as pd

from subprocess import run, PIPE
from pandas import DataFrame, read_csv, to_numeric, to_datetime
logging.basicConfig(filename = "example_ETLProcess.log", level = logging.DEBUG)

command = 'Rscript'
translationScript = 'Data_Translation.R'
profilingScript = "profiling_sales_item.R"
columnNames = ["order", "date", "customer", "item", "amount", "quantity",  "price"]

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
    #channel.basic_consume(doNothing,
    #    queue='HelloQ',
    #    no_ack=True)
    return(connection, channel)

def doNothing(ch, method, properties, body):
    print(" [*] Doing Nothing, Whatever...")
    time.sleep(2)
    print(" [*] Nothing, is done...")
#    ch.basic_ack(delivery_tag = method.delivery_tag)
    time.sleep(2)
    print(" [*] Waiting for messages. To exit press CTRL+C")

def callbackProcess(ch, method, properties, body):
    args = getArgumentsQueue(body)
    #print(" [**]args type> {}".format(type(args)))
    #runETLProcess(args)
    runSIProfilerArgs(args)
#    ch.basic_ack(delivery_tag = method.delivery_tag)
    time.sleep(2)
    print(" [*] Waiting for messages. To exit press CTRL+C")
    
def getArgumentsQueue(body):
    if(type(body) != bytes):
        args = body
    else:
        args = json.loads(body.decode('utf-8'))
    return(args)
    
def getColumnMap(args):
    columnMap = {k : v for k, v in args.items() if v in columnNames}
    #print(' [**]columnMap> {}'.format(columnMap))
    return(columnMap)

def runETLProcess(args):
    print(" [**] Starting ETL Process>>>")
    df = pd.read_csv(args['datafile'], encoding = 'latin1')

    columnMap = getColumnMap(args)
    df = df.rename(columns = columnMap)
    print(' [**] Processing Datatypes>>')

    errAction = 'coerce'
    #errAction = 'ignore'
    #errAction = 'raise'

    df["order"] = df["order"].apply(lambda x: str(x).strip())
    df["customer"] = df["customer"].apply(lambda x: str(x).strip())
    df["date"] = to_datetime(df["date"], infer_datetime_format = True, errors= errAction)
    df["amount"] = to_numeric(df["amount"], downcast = 'float', errors = errAction)
    df["quantity"] = to_numeric(df["quantity"], downcast = 'integer', errors = errAction)
    df["price"] = to_numeric(df["price"], downcast = 'float', errors = errAction)

    df = df.round({'amount' : 2, 'price' : 2})

    #print(df.head(10))
                             
    print(" [**] Writing Clean CSV for eRFM Processing>>")
    df.to_csv("Automation_Orders.csv",
              columns = columnNames,
              index = False,
              index_label = False,
              encoding='utf-8',
              float_format = '%.2f',
              date_format = '%d/%m/%Y')
    print (" [**] ETL Process Completed>>>")
    return(0)

def runSIProfilerArgs(args):
    try:
        runETLProcess(args)

        print(" [**] Starting eRFM Profiler>>>")
        cmdStr = " ".join([command, profilingScript, args['customername']])
        CP = run(cmdStr,
                 shell = True,
                 check = True,
                 stdout = PIPE,
                 stderr = PIPE,
                 universal_newlines=True)
        print("\n profiling_sales_item> Return_Code> {0} STDOUT> {1}".format(CP.returncode, CP.stdout))
        print(" [**] eRFM Profiler Completed>> Check Directory for Output Files>>")
        return(0)
    except Exception as err:
        print("EXCEPTION RAISED> ReturnCode> {0} STDOUT>{1}".format(err.returncode, err.stdout))
        return(-1)

def main():
    try:
        conn, channel = connectMQ()
        consumeMQ(channel)
    except KeyboardInterrupt:
        conn.close()
    finally:
        print(' [*] Closing Connection> Ending Worker Process>')

    return(0)
    
print(main())

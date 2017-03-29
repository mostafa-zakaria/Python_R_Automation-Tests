import timeit as tt
import pandas as pd

from subprocess import run, PIPE
from pandas import DataFrame, read_csv, to_numeric, to_datetime

data = {}
customerName = ""
columnMap = {}
command = 'Rscript'
translationScript = 'Data_Translation.R'
profilingScript = "profiling_sales_item.R"

datafile = "SI_Data_No_Guest_Mod_Div.csv"
#datafile = "sample.csv"

def getArgumentsOrig():
    global customerName
    global data

    customerName = "R_ETL_Test"
    
    data = {"orderFile" : datafile,
            "order" : "Order",
            "date" : "Date",
            "customer" : "Customer",
            "item" : "Item",
            "amount" : "Total_Price",
            "quantity" : "Quantity",
            "price" : "Unit_Price"}

#    data = {"orderFile" : datafile,
#            "order" : "Order",
#            "date" : "Date",
#            "customer" : "Customer",
#            "item" : "Item",
#            "amount" : "Amount",
#            "quantity" : "Quantity",
#            "price" : "Price"}

def getArguments():
    global customerName
    global columnMap
    
    customerName = "Python_ETL_Test"
    
    columnMap = {"Order" : "order",
                 "Date" : "date",
                 "Customer" : "customer",
                 "Item" : "item",
                 "Total_Price" : "amount",
                 "Quantity" : "quantity",
                 "Unit_Price" : "price"}

#    columnMap = {"Order" : "order",
#                "Date" : "date",
#                "Customer" : "customer",
#                "Item" : "item",
#                "Amount" : "amount",
#                "Quantity" : "quantity",
#                "Price" : "price"}
    

def runETLProcess(location):
    df = pd.read_csv(location)
    df = df.rename(columns = columnMap)

    df["date"] = to_datetime(df["date"], infer_datetime_format = True, errors= 'coerce')

    df["amount"] = to_numeric(df["amount"], downcast = 'float', errors = 'coerce')
    df["quantity"] = to_numeric(df["quantity"], downcast = 'integer', errors = 'coerce')
    df["price"] = to_numeric(df["price"], downcast = 'float', errors = 'coerce')
    
    df.to_csv("Automation_Orders.csv",
              columns=["order", "date", "customer", "item", "quantity", "amount", "price"],
              index = False, index_label = False,
              encoding='utf-8',
              date_format = '%d/%m/%Y')
    return(0)

def runSIProfiler():
    try:
        print("Pandas ETL Process Error> {}".format(runETLProcess(datafile)))

        cmdStr = " ".join([command, profilingScript, customerName])
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

def runSIProfilerOrig():
    try:
        print(data)

        args = [data["orderFile"],
                data["order"],
                data["date"],
                data["customer"],
                data["item"],
                data["amount"],
                data["quantity"],
                data["price"]]
        
        cmdStr = " ".join([command, translationScript] + args)
        CP = run(cmdStr,
                 shell = True,
                 check = True,
                 stdout = PIPE,
                 stderr = PIPE,
                 universal_newlines=True)
        print("\n Data_Translation> Return_Code> {0} STDOUT> {1}".format(CP.returncode, CP.stdout))

        cmdStr = " ".join([command, profilingScript, customerName])
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
    getArguments()
    return(runSIProfiler())

def mainOrig():
    getArgumentsOrig()
    return(runSIProfilerOrig())
    
#getArguments()
#print(runETLProcess(datafile))

#print(mainOrig())
print(main())



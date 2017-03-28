from subprocess import run, PIPE

command = 'Rscript'
path2script = 'Data_Translation.R'
eRFMScriptLocation = '~/Documents/Proposals & Works/Profiler/Elemis/'

data = {"orderFile" : "SI_Data_No_Guest_Mod_Div.csv",
            "order" : "Order",
            "date" : "Date",
            "customer" : "Customer",
            "item" : "Item",
            "amount" : "Total_Price",
            "quantity" : "Quantity",
            "price" : "Unit_Price"}

args = [data["orderFile"], data["order"], data["date"], data["customer"],
        data["item"], data["amount"], data["quantity"], data["price"]]

cmdStr = " ".join([command, path2script] + args)

try:

    CP = run(cmdStr,
             shell = True,
             check = True,
             stdout = PIPE,
             stderr = PIPE,
             universal_newlines=True)
    print("\n Data_Translation> Return_Code> {0} STDOUT> {1}".format(CP.returncode, CP.stdout))

    CP = run(command + " profiling_sales_item.R",
             shell = True,
             check = True,
             stdout = PIPE,
             stderr = PIPE,
             universal_newlines=True)
    print("\n profiling_sales_item> Return_Code> {0} STDOUT> {1}".format(CP.returncode, CP.stdout))

except Exception as err:
    print("EXCEPTION RAISED> ReturnCode> {0} STDOUT>{1}".format(err.returncode, err.stdout))

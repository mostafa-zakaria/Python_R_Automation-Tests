#VERSION: v0.86.1
#PARAMETERS
#FILES

#in linux or osx environments uncomment the next line, and set a writable folder for storing the necessary packages.
#RLibraryLocation <- "~/R_library"

customerName <- "Automation"	#
#eRFM params
eRFMScriptLocation <- "~/Documents/Proposals & Works/Profiler/Elemis/eRFM"
rfm_calc_years <- 2

profilingScriptLocation <- "~/Documents/Proposals & Works/Profiler/Elemis/profiling_script" #Full path

#To skip a specific file, delete the file parameter or set an empty sring for the name
#PRODUCT
product_file_params <- list(
  name = '',
  separator = ','
)
#SALES_ITEM FILE PARAMS
sales_items_file_params <- list(
  name = 'Automation_Orders.csv',
  separator = ','
)

#CONTACTFILE PARAMS
contact_file_params <- list(
  name = '',
  separator = ',',
  quote = ""
)

#Required column names in CONTACT
UserId_CN <- ""
registration_date_CN <- ""

#PRODUCT
product_columns <- list(
  item = "item",
  title = "title",
  category = "category"
)

#SALES_ITEM
sales_item_columns <- list(
  order = "order",
  date = "date",
  customer = "customer",
  item = "item",
  amount = "amount",
  quantity = "quantity",
  price = "price"
)

#OPTIONAL PARAMS

source(paste(profilingScriptLocation,"/run_profiling_si.R",sep=""))
source("run_eRFM.R")
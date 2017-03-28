#VERSION: v0.85.9
#PARAMETERS
#FILES

#in linux or osx environments uncomment the next line, and set a writable folder for storing the necessary packages.
#RLibraryLocation <- "~/R_library"

customerName <- ""	#
#eRFM params
eRFMScriptLocation <- ""
rfm_calc_years <- 2

profilingScriptLocation <- "" #Full path
#e.g: c:/works/<profiling_script>
#important, to use "/" character instead of "\" character in paths.

profilingOutputDir <- "./Profiling/"
profilingOutput <- "profiling.txt"

#To skip a specific file, delete the file parameter or set an empty sring for the name
#ORDER
order_file_params <- list(
  name = '',     #eg.: "orders.csv"
  separator = ',',
  quote = ''
)

#ORDER_ITEM
order_item_file_params <- list(
  name = ''     #eg.: "order_items.csv"
)

#CONTACT FILE PARAMS
contact_file_params <- list(
  name = '',    #eg.: "contacts.txt"
  separator = ','
)

#Required column names in CONTACT
UserId_CN <- "customerid"
registration_date_CN <- "first_order_date"

#Required column names in ORDER
#order ID: The unique identifier of the order.
OrderId_CN <- "OrderID"
#order date: The date of the order, in YYYY-MM-DD format (e.g. 2013-03-01).
OrderDate_CN <- "OrderDate"
#amount: The total sum of the order (can be gross or net, or both amounts can be included in the file).
OrderAmount_CN <- "Total"
#user ID: The unique identifier of the user who made the purchase. This value is used to connect the e-commerce users to the customer's contacts in Suite so this field must be included in the customer's contact table in Suite as well.
OrderUserId_CN <- "CustomerId"

#Required column names in ORDER_ITEMS
#order ID: The identifier of the order that this item was purchased in.
OrderItemOrderId_CN <- "OrderID"
#product ID: The identifier of the product that was purchased.
OrderItemItemID_CN <- "ItemID"
#product name: The name of the product that was purchased.
OrderItemItemname_CN <- "ItemName"
#product category: The name of the category the product belongs to. (More than 1 product category field may be present.)
OrderItemProductCat1_CN <- "Category1"
#sales amount: The total amount of this sales item (unit price * quantity).
OrderItemSalesAmount_CN <- "Price"
#quantity (optional): The number of items bought.
OrderItemSalesQuantity_CN <- "Quantity"
#unit price (optional)

source(paste(profilingScriptLocation,"/run_profiling.R",sep=""))
opt <- options("scipen" = 20)


if(!exists("load_and_install_package", mode="function")) source(paste(profilingScriptLocation,"/utils/package_tools.R",sep=""))

load_and_install_package("Hmisc")

workingDirectory <- getwd()
print(workingDirectory)

if(!exists("exclude_negative_values_by_column", mode="function")) source(paste(profilingScriptLocation,"/utils/utils.R",sep=""))
if(!exists("checkDate", mode="function")) source(paste(profilingScriptLocation,"/utils/checkDate.R",sep=""))
if(!exists("readFile", mode="function")) source(paste(profilingScriptLocation,"/utils/readFile.R",sep=""), chdir=TRUE)
if(!exists("summaries", mode="function")) source(paste(profilingScriptLocation,"/utils/summaries.R",sep=""))
if(!exists("write_summaries", mode="function")) source(paste(profilingScriptLocation,"/utils/write_summaries.R",sep=""), chdir=TRUE)

if(!exists("checkOrder", mode="function")) source(paste(profilingScriptLocation,"/checkOrder.R",sep=""))
if(!exists("checkOrderItem", mode="function")) source(paste(profilingScriptLocation,"/checkOrderItem.R",sep=""))
if(!exists("checkContact", mode="function")) source(paste(profilingScriptLocation,"/checkContacts.R",sep=""))
if(!exists("writeFreqs", mode="function")) source(paste(profilingScriptLocation,"/writeFreqs.R",sep="")) 

startTime <- proc.time()

profilingOutputDir <- "./Profiling/"
profilingOutput <- "./Profiling/profiling.txt"

dir.create(file.path(workingDirectory, profilingOutputDir), showWarnings = FALSE)
#setwd(file.path(mainDir, subDir))

profilingOutput <- paste(profilingOutputDir,profilingOutput,sep="")
lastDot <- regexpr("\\.[^\\.]*$", profilingOutput)[1]
if (lastDot > 0 ) {
  profilingLog <- paste(substr(profilingOutput, 1, lastDot - 1),".log",sep="")
} else {
  profilingLog <- paste(profilingOutput,".log")
}

#CHECKING PARAMS
if (!exists("calculate_eRFM_sales_items", mode="any")) {
  if (nchar(eRFMScriptLocation) > 0) {
    calculate_eRFM_sales_items <- TRUE
  } else {
    calculate_eRFM_sales_items <- FALSE
  }
}

fileHasHeader <- TRUE
cfileHasHeader <- TRUE

if (!exists("writeOrdersFreq", mode="any")) {
  writeOrdersFreq <- TRUE
}
if (!exists("writeOrderItemsFreq", mode="any")) {
  writeOrderItemsFreq <- TRUE
}
if (!exists("writeContactsFreq", mode="any")) {
  writeContactsFreq <- TRUE
}
if (!exists("show_freq_limit", mode="any")) {
  show_freq_limit <- 10000
}
if (!exists("registration_date_CN", mode="any")) {
  registration_date_CN <- ""
}

write("Profiling Start. Params:", file=profilingLog)
write("Profiling.", file=profilingOutput)

#options(width= 200)
OrderUserId_CI <- -1
OrderUserId_CI <- -1
OrderAmount_CI <- -1

if (params_exist("order_file_params")) {
  write("Start Order Checking.", file=profilingLog, append=TRUE)
  order_file_params <- build_file_params(order_file_params)
  order <- checkOrder(order_file_params, profilingOutputDir, profilingOutput, profilingLog, naValues,
                      OrderId_CN, OrderDate_CN,OrderAmount_CN, OrderUserId_CN)
    
  OrderOrderId_CI <- getColumnIndice(order, OrderId_CN, "OrderID")
  OrderUserId_CI <- getColumnIndice(order, OrderUserId_CN, "User ID")
  OrderAmount_CI <- getColumnIndice(order, OrderAmount_CN, "Amount")
  OrderDate_CI <- getColumnIndice(order, OrderDate_CN, "order date")
  
  if (writeOrdersFreq == TRUE) {
    write("Write Order frequencies.", file=profilingLog, append=TRUE)
    order_freqs <- writeFreqs(order,freqFilename = paste("./Profiling/",strsplit(order_file_params$name, split="\\.")[[1]][1],"_freq.csv", sep=""), show_freq_limit = show_freq_limit)
  }    
}

if (params_exist("order_item_file_params")) {
  write("Start Order Item Checking.", file=profilingLog, append=TRUE)
  order_item_file_params <- build_file_params(order_item_file_params)
  
  order_item <- checkOrderItem (
    order_item_file_params, profilingOutputDir, profilingOutput, profilingLog, naValues,
    OrderItemOrderId_CN, OrderItemItemID_CN, OrderItemItemname_CN, OrderItemProductCat1_CN, OrderItemSalesAmount_CN, OrderItemSalesQuantity_CN,
    order, OrderOrderId_CI, OrderAmount_CI)

  OrderItemOrderID_CI <- getColumnIndice(order_item, OrderItemOrderId_CN, "order ID")
  OrderItemItemID_CI <- getColumnIndice(order_item, OrderItemItemID_CN, "product ID")
  OrderItemSalesAmount_CI <- getColumnIndice(order_item, OrderItemSalesAmount_CN, "sales amount")
  OrderItemSalesQuantity_CI <- getColumnIndice(order_item, OrderItemSalesQuantity_CN, "quantity")

  if (writeOrderItemsFreq == TRUE) {
    write("Write Order Item frequencies.", file=profilingLog, append=TRUE)
    order_item_freqs <- writeFreqs(order_item,freqFilename = paste("./Profiling/",strsplit(order_item_file_params$name, split="\\.")[[1]][1],"_freq.csv", sep=""), show_freq_limit = show_freq_limit)
  }    
}


if (params_exist("contact_file_params")) {
  write("Start Contact Checking.", file=profilingLog, append=TRUE)
  contact_file_params <- build_file_params(contact_file_params)
  results <- checkContact (contact_file_params, profilingOutput, naValues,
                           UserId_CN, registration_date_CN,
                           order, OrderUserId_CI, OrderDate_CI = OrderDate_CI, OrderOrderID_CI = OrderItemOrderID_CI)
  contact <- results$contact
  customer <- results$customer
  
  if (writeContactsFreq == TRUE) {
    write("Write Contact frequencies.", file=profilingLog, append=TRUE)
    contact_freqs <- writeFreqs(contact,freqFilename = paste("./Profiling/",strsplit(contact_file_params$name, split="\\.")[[1]][1],"_freq.csv", sep=""), show_freq_limit = show_freq_limit)
  }    
}

if (calculate_eRFM_sales_items) {

  sales_item <- merge(order[,c(OrderOrderId_CI,OrderUserId_CI,OrderDate_CI)], order_item[,c(OrderItemOrderID_CI,OrderItemItemID_CI,OrderItemSalesAmount_CI,OrderItemSalesQuantity_CI)], by.x = 1, by.y = 1)
  names(sales_item) <- c("OrderID","CustomerID","OrderDate", "Item","Price", "Quantity")
  #sales_item$Price <- sales_item$ItemPrice*sales_item$Quantity
  
  si_order_CI <- 1
  si_customer_CI <- 2
  si_date_CI <- 3
  si_item_CI <- 4
  si_amount_CI <- 5
  
  fileNames <- paste(order_file_params$name,",",order_item_file_params$name)
}

write("", file=profilingOutput, append = TRUE)
write(paste("Profiling End. Time:",(proc.time() - startTime)[3]), file=profilingOutput, append = TRUE)
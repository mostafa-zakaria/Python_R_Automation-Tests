#myArgs <- commandArgs(trailingOnly = TRUE)

#eRFMScriptLocation <- myArgs[1]

eRFMScriptLocation <- "~/Documents/Proposals\\ \\&\\ Works/Profiler/Elemis"
#installing necessary libraries
source(paste(eRFMScriptLocation,"/profiling_script/utils/exception_handling.R",sep=""), chdir=TRUE)
source(paste(eRFMScriptLocation,"/eRFM/utils/recency_k_mean.R",sep=""), chdir=TRUE)

#source("profiling_script/utils/exception_handling.R", chdir=TRUE)
#source("eRFM/utils/recency_k_mean.R", chdir=TRUE)

if(!exists("load_and_install_package", mode="function")) source(paste(eRFMScriptLocation,"profiling_script/utils/package_tools.R",sep=""))
load_and_install_package("knitr")
load_and_install_package("reshape")
##############################################################################################################################
#eRFM related base calculations, and necessary functions

#If the customer douesn't have quantity or unit price column:
act_sales_item <- sales_item$data[,c(sales_item$columns$order$index,sales_item$columns$date$index,sales_item$columns$customer$index,sales_item$columns$item$index,sales_item$columns$amount$index)]
names(act_sales_item) <- c("OrderID","OrderDate","CustomerID","ItemCode", "Price")

#Common issue 1:
#If the customer douesn't have Amount column (mandatory), but quantity and amount (which is unit price) are present:
#act_sales_item <- sales_item[,c(si_order_CI,si_date_CI,si_customer_CI,si_item_CI,si_quantity_CI,si_amount_CI)]
#If the customer douesn't have Amount column (mandatory), but quantity and price (which is unit price) are present:
#act_sales_item <- sales_item[,c(si_order_CI,si_date_CI,si_customer_CI,si_item_CI,si_quantity_CI,si_price_CI)]
#names(act_sales_item) <- c("OrderID","OrderDate","CustomerID","ItemCode", "Quantity", "ItemPrice")
#act_sales_item$Price <- act_sales_item$ItemPrice*act_sales_item$Quantity

#Common issue 2:
#Date conversion. 
dateFormat <- checkDate (sales_item$data,sales_item$columns$date$index) 
act_sales_item$OrderDate <- as.Date(as.character(act_sales_item$OrderDate),dateFormat)
#act_sales_item$OrderDate <- as.Date(as.character(act_sales_item$OrderDate))

# NA handling in date column
order_date_na_examples <- get_na_examples_by_column(df = act_sales_item, na_lookup_column_id = 2, return_column_id = 1)
act_sales_item <- act_sales_item[!is.na(act_sales_item$OrderDate),]

#Write to the console the date range
min(act_sales_item$OrderDate)
max(act_sales_item$OrderDate)

#Common issue 3:
#Round and check the prices
stop_if_not_a_number(act_sales_item$Price, "Price (si_amount_CN)")
act_sales_item$Price <- convert_to_numeric_if_factor(act_sales_item$Price)
act_sales_item$Price <- round(act_sales_item$Price)

#SALES RFM CALCULATION
#the RFM score calculation use sales_items data between the maximum orderdate and (maximum orderdate - <rfm_calc_years> years)
# system.time(source(paste(eRFMScriptLocation,"/calculate_salesRFM.R",sep="")))
system.time(source(paste(eRFMScriptLocation,"/dplyr_calculate_salesRFM.R",sep="")))

knit2html (input<-'rfm_interval_tests.rmd',output=paste(customerName,"_rfm_ints_test.html",sep=""))
knit2html (input<-'rfm_interval_tests_essential.rmd',output=paste(customerName,"_rfm_ints_test_essential.html",sep=""))
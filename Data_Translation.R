setwd("~/Documents/Proposals & Works/Profiler/Elemis")
###### Required Packages ##########
for (package in c('lubridate')) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

result <- tryCatch({
  ########## Inputs ############
  
  myArgs <- commandArgs(trailingOnly = TRUE)
   
  #retreive order file and field mapping from commandline arguments
  #orderFile <- "SI_Data_No_Guest_Mod_Div.csv"
  #order <-  "Order"
  #date <- "Date"
  #customer <- "Customer"
  #item <- "Item"
  #amount <- "Total_Price"
  #quantity <- "Quantity"
  #price <- "Unit_Price"

  orderFile <- myArgs[1]
  order <-  myArgs[2]
  date <- myArgs[3]
  customer <- myArgs[4]
  item <- myArgs[5]
  amount <- myArgs[6]
  quantity <- myArgs[7]
  price <- myArgs[8]
  
  
    #### Load Raw Data #####
  
  Orders <- read.csv(orderFile, header = TRUE, sep = ",", stringsAsFactors = FALSE, strip.white = TRUE)
  
  # If there is no contact file, comment out by inserting a "#" before Contacts on the line below.
  
  #Contacts <- read.csv(contactFile, header = TRUE, sep = ",", stringsAsFactors = FALSE, strip.white = TRUE)
  
  ########################
  
  #####################
  #  Order File Prep  #
  #####################
  
  #### Change names in order file to match profiler 
  
  names(Orders)[names(Orders) == order] <- 'order'
  names(Orders)[names(Orders) == date] <- 'date'
  names(Orders)[names(Orders) == customer] <- 'customer'
  names(Orders)[names(Orders) == item] <- 'item'
  names(Orders)[names(Orders) == amount] <- 'amount'
  names(Orders)[names(Orders) == quantity] <- 'quantity'
  names(Orders)[names(Orders) == price] <- 'price'
  
  #### Remove columns that are not needed ####
  
  Orders <- Orders[c("order", "date", "customer", "item", "amount", "quantity", "price")]
  
  #### Change field type to match profiler ####
  
  Orders$order <- as.character(Orders$order)
  #Orders$date <- ymd(Orders$date) # Depending on the date format in the source file, you may need to edit this field.  
  # R may do this on it's own. If you get an error, this is a place to check. date formate is
  # yyyy-mm-dd - see help or google dates transformation in R
  Orders$date <- strptime(as.character(Orders$date), "%m/%d/%y")
  Orders$date <- format(Orders$date, "%Y/%m/%d")
  Orders$amount <- as.numeric(Orders$amount)
  Orders$quantity <- as.numeric(Orders$quantity)
  Orders$price <- as.numeric(Orders$price)
  
  #### Remove NA's from Orders ####
  
  Orders <- Orders[complete.cases(Orders),]
  
  #### Write csv of clean order file to working directory
  
  write.csv(Orders, file = paste("Automation_Orders.csv"), row.names = FALSE, na = "")
  
  # #######################
  # #  Contact File Prep  #
  # #######################
  # 
  # #### !!!!! NOTE: If there is no contact file to , comment out the remaining code by doing the following !!!!! ####
  # 
  # # 1. Highlight from here to the bottom of the script
  # # 2. Select Code > Comment/Uncomment Lines  (or CMD/Shift"C" for Mac...)
  # 
  # #### Change names in order file to match profiler
  # 
  # names(Contacts)[names(Contacts) == UserId_CN] <- 'UserId_CN'
  # names(Orders)[names(Orders) == registration_date_CN] <- 'registration_date_CN'
  # 
  # #### Remove all fields except CustomerID and First order Date
  # 
  # Contacts <- Contacts[c("UserID_CN","registration_date_CN"),]
  # 
  # #### Convert Contact Fields to correct Type
  # 
  # Contacts$UserID_CN <- as.character(Contacts$UserID_CN)
  # Contacts$registration_date_CN <- as.Date(Contacts$registration_date_CN)
  # 
  # #### Remove NA's from Contacts ####
  # 
  # Contacts <- Contacts[complete.cases(ContactsFinal),]
  # 
  # #### Write final formatted files back to working directory ####
  # 
  # write.csv(ContactsFinal, file = "Contacts.csv", row.names = FALSE, na = "")
  # 
  # 
  # 
}, error = function(err){
  print(paste("MY_ERROR>  ", err))
  return(-1)
})


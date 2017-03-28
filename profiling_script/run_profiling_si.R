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

if(!exists("writeFreqs", mode="function")) source(paste(profilingScriptLocation,"/writeFreqs.R",sep="")) 

if(!exists("checkProduct", mode="function")) source(paste(profilingScriptLocation,"/checkProduct.R",sep=""), chdir=TRUE)
if(!exists("checkSalesItem", mode="function")) source(paste(profilingScriptLocation,"/checkSalesItem.R",sep=""))
if(!exists("checkContact", mode="function")) source(paste(profilingScriptLocation,"/checkContacts.R",sep=""))

startTime <- proc.time()

profilingOutputDir <- "./Profiling/"
profilingOutput <- "./Profiling/profiling.txt"

dir.create(file.path(workingDirectory, profilingOutputDir), showWarnings = FALSE)
#setwd(file.path(mainDir, subDir))

if (!exists("writeProductFreq", mode="any")) {
  writeProductFreq <- TRUE
}
if (!exists("writeSalesIemFreq", mode="any")) {
  writeSalesIemFreq <- TRUE
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


print("Profiling Start.")
write("Profiling.", file=profilingOutput)

# PRODUCT
# if (exists("product_file_params", mode="list") & nchar(product_file_params$name) > 0) {
file <- file(profilingOutput, open="ab", encoding="UTF-8")

product <- NULL
if (params_exist("product_file_params")) {
  print("Start Product Checking.")

  product_file_params <- build_file_params(product_file_params)
  product_file_params <- override_item_colum_type(product_file_params, product_columns$item, 'character')

  product <- checkProduct(product_file_params, file, product_columns)
  sapply(product$data,class)
  if (writeProductFreq == TRUE) {
    print("Write Product frequencies.")
    product_freqs <- writeFreqs(product$data,freqFilename = paste("./Profiling/",strsplit(product_file_params$name, split="\\.")[[1]][1],"_freq.csv", sep=""), show_freq_limit = show_freq_limit)
  }    
  products <- product$data
  bad_products_guesses <- highlight_bad_row_guesses(product$result)
  products_tail <- tail_df(product$result)
}


# SALES_ITEM
if (params_exist("sales_items_file_params")) {
  print("Start Sales Item Checking.")
  sales_items_file_params <- build_file_params(sales_items_file_params)
  sales_items_file_params <- override_item_colum_type(sales_items_file_params, sales_item_columns$item, 'character')
  
  sales_item <- checkSalesItem(sales_items_file_params, file, sales_item_columns, product)

  sales_item_prefix <- strsplit(sales_items_file_params$name, split="\\.")[[1]][1]
  if (anyDuplicated(sales_item$data)) 
    write.csv(unique(sales_item$data[duplicated(sales_item$data),]), file=paste("./Profiling/",sales_item_prefix,"_unique_duplications.csv", sep=""), row.names=F)    
  
  if (writeSalesIemFreq == TRUE) {
    print("Write sales_items frequencies.")
    sales_item_freqs <- writeFreqs(sales_item$data,freqFilename = paste("./Profiling/",sales_item_prefix,"_freq.csv", sep=""), show_freq_limit = show_freq_limit)
  }    
  sales_items <- sales_item$data
  bad_sales_items_guesses <- highlight_bad_row_guesses(sales_item$result)
  sales_items_tail <- tail_df(sales_item$result)  
}
close(file) 

results <- NULL
#CONTACT
if (exists("contact_file_params", mode="list") & nchar(contact_file_params$name) > 0) {
  print("Start Contact Checking.")
  contact_file_params <- build_file_params(contact_file_params)
  results <- checkContact (contact_file_params, profilingOutput, 
                           UserId_CN, registration_date_CN,
                           order = sales_item$data, OrderUserId_CI = sales_item$columns$customer$index, OrderDate_CI = sales_item$columns$date$index, OrderOrderID_CI = sales_item$columns$order$index)
  contact <- results$contact
  customer <- results$customer
  contact_dim <- results$contact_dim
  if (writeContactsFreq == TRUE) {
    print("Write Contact frequencies.")
    contact_freqs <- writeFreqs(contact,freqFilename = paste("./Profiling/",strsplit(contact_file_params$name, split="\\.")[[1]][1],"_freq.csv", sep=""), show_freq_limit = show_freq_limit)
  }    
}

if (is.null(results$contact_dim) & !is.null(sales_items))
  contact_dim <- create_contact_dim(as.character(unique(sales_items[,sales_item$columns$customer$index])))

if (!is.null(sales_items)) {
  sales_item$data <- merge(sales_item$data, contact_dim, by.x=sales_item$columns$customer$index, by.y = 'ExternalID')[, union(names(sales_item$data), 'contact_integer_id')]
  sales_items <- sales_item$data
  sales_item$columns$contact_integer_id = list(
    name = 'contact_integer_id', 
    index = getColumnIndice(sales_item$data, 'contact_integer_id'))
  
}

fileNames <- paste(sales_items_file_params$name)

write("", file=profilingOutput, append = TRUE)
write(paste("Profiling End. Time:",(proc.time() - startTime)[3]), file=profilingOutput, append = TRUE)
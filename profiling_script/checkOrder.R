checkOrder <- function(file_params, profilingOutputDir, profilingOutput, profilingLog, naValues,
                       OrderId_CN, OrderDate_CN,OrderAmount_CN, OrderUserId_CN) {
  
  write("############################################################## ORDERS #######################################################", file=profilingOutput, append = TRUE)
  order <- readFile (file_params)$data
  
  write("", file=profilingLog, append = TRUE)
  write("Checking columns:", file=profilingLog, append = TRUE)
  
  OrderId_CI <- getColumnIndice(order, OrderId_CN, "order ID")
  OrderDate_CI <- getColumnIndice(order, OrderDate_CN, "order date")

  OrderAmount_CI <- getColumnIndice(order, OrderAmount_CN, "amount")
  OrderUserId_CI <- getColumnIndice(order, OrderUserId_CN, "user ID")

  write("", file=profilingOutput, append = TRUE)
  if ((OrderId_CI == 0) | (OrderDate_CI == 0) | (OrderUserId_CI == 0)) {
    write("There is missing required columns. Profiling has been stopped.", file=profilingOutput, append = TRUE)
    stop()
  } else {
    write("1. Required columns found.", file=profilingOutput, append = TRUE)
  }
  
  #VARIABLE TYPES
  write("", file=profilingOutput, append = TRUE)
  write("2. variable types: ", file=profilingOutput, append = TRUE)
  write(paste(names(order), collapse="\t"), file=profilingOutput, append = TRUE)
  write(paste(paste(sapply(order[1,], class),collapse="\t")), file=profilingOutput, append = TRUE)
  
  #SUMMARY
  write("", file=profilingLog, append = TRUE)
  fn_prefix = paste(profilingOutputDir ,strsplit(file_params$name, split="\\.")[[1]][1], sep="")
  summaryFile <- paste(fn_prefix,"_description.txt", sep="")
  write(paste("Writing summaries of the file: ",summaryFile), file=profilingLog, append = TRUE)
  
  write("", file=profilingLog, append = TRUE)
  naCount <- sum(is.na(order))
  write(paste("Count of NA values: ",naCount), file=profilingLog, append = TRUE)
  
  #in which rows are there missing values?
  
  if (naCount > 0) {
    naFile <- paste(fn_prefix,"_na_head.csv", sep="")
    write(paste("Writing NA examples: ",naFile), file=profilingLog, append = TRUE)
    write.csv2(head(order[rowSums(is.na(order))>0,]), file=naFile, quote=FALSE)   
  }
  
  #"_description.txt"
  sink(file=summaryFile, split=TRUE)
  
  print("Summary:")
  print(summary(order))
  
  #description of all Variables
  print("description of all variables:")
  desc <- describe(order)
  
  print(desc)
  
  #OrderID
  if (as.integer(desc[[names(order)[OrderId_CI]]][["counts"]][["unique"]]) != as.integer(desc[[names(order)[OrderId_CI]]][["counts"]][["n"]]) ) {
    write("", file=profilingOutput, append = TRUE)
    write(paste("OrderId doesn't unique."), file=profilingOutput, append = TRUE)
    write(paste("#order ID: ",desc[[names(order)[OrderId_CI]]][["counts"]][["n"]]), file=profilingOutput, append = TRUE)
    write(paste("#order ID unique: ",desc[[names(order)[OrderId_CI]]][["counts"]][["unique"]]), file=profilingOutput, append = TRUE)
  }
  
  #OrderDate
  write("", file=profilingOutput, append = TRUE)
  write(paste("Checking OrderDate column"), file=profilingLog, append = TRUE)
  
  dateFormat <- checkDate (order,OrderDate_CI) 
  
  if (nchar(dateFormat) > 0) {
    write(paste("3. (",OrderDate_CN,") column is a valid Date. Format:", dateFormat, sep=""), file=profilingOutput, append = TRUE)
  } else {
    write(paste("3. (",OrderDate_CN,") column is malformed.", sep=""), file=profilingOutput, append = TRUE)
  }
  
  sink()
  return (order)
}

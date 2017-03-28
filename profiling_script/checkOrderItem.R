checkOrderItem <- function(
    file_params, profilingOutputDir, profilingOutput, profilingLog, naValues,
    OrderItemOrderId_CN, OrderItemItemID_CN, OrderItemItemname_CN, OrderItemProductCat1_CN, OrderItemSalesAmount_CN, OrderItemSalesQuantity_CN,
    order = NULL, OrderOrderId_CI = -1, OrderAmount_CI = -1) {
  
  write("############################################################## ITEMS #######################################################", file=profilingOutput, append = TRUE)
  
  order_item <- readFile (file_params)$data  
  
  write("", file=profilingLog, append = TRUE)
  write("Checking columns:", file=profilingLog, append = TRUE)

  #OrderDate_ColumnId <- getColumnIndice(order_item, OrderDate_ColumnName, profilingLog)
  OrderId_CI <- getColumnIndice(order_item, OrderItemOrderId_CN, "order ID")
  OrderItemID_CI <- getColumnIndice(order_item, OrderItemItemID_CN, "product ID")
  OrderItemname_CI <- getColumnIndice(order_item, OrderItemItemname_CN, "product name")
  
  OrderItemProductCat1_CI <- getColumnIndice(order_item, OrderItemProductCat1_CN, "product category1")
  OrderItemSalesAmount_CI <- getColumnIndice(order_item, OrderItemSalesAmount_CN, "sales amount")
  OrderItemSalesQuantity_CI <- getColumnIndice(order_item, OrderItemSalesQuantity_CN, "quantity")
  
  write("", file=profilingOutput, append = TRUE)
  if ((OrderId_CI == 0) | (OrderItemID_CI == 0) | (OrderItemname_CI == 0) ) {
    write("1. There is missing required columns. Profiling has been stopped.", file=profilingOutput, append = TRUE)
    return (order_item)#stop()#browser()#quit()
  } 

  if ((OrderItemProductCat1_CI == 0) | (OrderItemSalesAmount_CI == 0) ) {
    write("1. There is missing required columns. Profiling running forward.", file=profilingOutput, append = TRUE)
  }
  
  if (!((OrderId_CI == 0) | (OrderItemID_CI == 0) | (OrderItemname_CI == 0) | (OrderItemProductCat1_CI == 0) | (OrderItemSalesAmount_CI == 0))) {
    write("1. Required columns found.", file=profilingOutput, append = TRUE)
  }

  #VARIABLE TYPES
  write("", file=profilingOutput, append = TRUE)
  write("2. variable types: ", file=profilingOutput, append = TRUE)
  write(paste(names(order_item), collapse="\t"), file=profilingOutput, append = TRUE)
  write(paste(paste(sapply(order_item[1,], class),collapse="\t")), file=profilingOutput, append = TRUE)
  
  #SUMMARY
  write("", file=profilingLog, append = TRUE)
  fn_prefix = paste(profilingOutputDir ,strsplit(file_params$name, split="\\.")[[1]][1], sep="")
  summaryFile <- paste(fn_prefix,"_description.txt", sep="")
  write(paste("Writing summaries of the file: ",summaryFile), file=profilingLog, append = TRUE)

  write("", file=profilingLog, append = TRUE)
  naCount <- sum(is.na(order_item))
  write(paste("Count of NA values: ",naCount), file=profilingLog, append = TRUE)
  
  #in which rows are there missing values?
  
  if (naCount > 0) {
    naFile <- paste(fn_prefix,"_na_head.csv", sep="")
    write(paste("Writing NA examples: ",naFile), file=profilingLog, append = TRUE)
    write.csv2(head(order_item[rowSums(is.na(order_item))>0,]), file=naFile, quote=FALSE)   
  }
  #"_description.txt"
  sink(file=summaryFile, split=TRUE)
  
  print("Summary:")
  print(summary(order_item))

  #description of all Variables
  print("description of all variables:")
  desc <- describe(order_item)

  print(desc)

  sink()
  #Checking Items.
  
  write(paste("3. Item checks."), file=profilingOutput, append = TRUE)
  
#   if (as.integer(desc[[OrderId_CI]][["counts"]][["unique"]]) <= as.integer(desc[[OrderItemname_CI]][["counts"]][["unique"]]) ) {
#     write("", file=profilingOutput, append = TRUE)
#     write(paste("Count of distinct OrderId's <= item names"), file=profilingOutput, append = TRUE)
#     write(paste("#order ID: ",desc[[OrderId_CI]][["counts"]][["unique"]]), file=profilingOutput, append = TRUE)
#     write(paste("#item names: ",desc[[OrderItemname_CI]][["counts"]][["unique"]]), file=profilingOutput, append = TRUE)
#   } 

  if ((as.integer(desc[[names(order_item)[OrderItemID_CI]]][["counts"]][["unique"]]) != as.integer(desc[[names(order_item)[OrderItemname_CI]]][["counts"]][["unique"]]))) {
    write("", file=profilingOutput, append = TRUE)
    write(paste("Count of distinct items codes != item names."), file=profilingOutput, append = TRUE)
    write(paste("#items codes: ",desc[[names(order_item)[OrderItemID_CI]]][["counts"]][["unique"]]), file=profilingOutput, append = TRUE)
    write(paste("#item names: ",desc[[names(order_item)[OrderItemname_CI]]][["counts"]][["unique"]]), file=profilingOutput, append = TRUE)
    
    uniqueItemFile <- paste(fn_prefix,"_item.csv", sep="")
    write(paste("Writing unique Item: ",uniqueItemFile), file=profilingOutput, append = TRUE)
    write.csv2(unique(order_item[order(order_item[,OrderItemname_CI]),c(OrderItemname_CI,OrderItemID_CI)]),file=uniqueItemFile, quote=FALSE)
  } else {
    write(paste("#Item codes = Item names."), file=profilingOutput, append = TRUE)
  }

  if (OrderOrderId_CI > 0) {
    order_item$row_id <- as.numeric(rownames(order_item))
    order$row_id <- as.numeric(rownames(order))
    OrderSeq_ColumnId <- getColumnIndice(order, "row_id")
    OrderItemSeq_ColumnId <- getColumnIndice(order_item, "row_id")

    merged <- merge(order_item[,c(OrderItemSeq_ColumnId,OrderId_CI)], order[,c(OrderSeq_ColumnId,OrderOrderId_CI,OrderOrderId_CI)], by.x = 2, by.y = 2, all = TRUE)
    mRowsCount <- nrow(merged)
    write("", file=profilingOutput, append = TRUE)
    #Orders without order_items
    write(paste("4/I. #Orders without order_items: ", sum(is.na(merged$row_id.x))), file=profilingOutput, append = TRUE)
    if (sum(is.na(merged$row_id.x)) > 0) {
      write("OrdersID examples without order_items: ", file=profilingOutput, append = TRUE)
      write(paste(head(unique(merged[is.na(merged$row_id.x),4])), sep=";"), file=profilingOutput, append = TRUE)
    }
         
    #order_item without order
    write(paste("4/II. #Order itmes without order: ", sum(is.na(merged$row_id.y))), file=profilingOutput, append = TRUE)
    if (sum(is.na(merged$row_id.y)) > 0) {
      write("OrdersID examples without orders: ", file=profilingOutput, append = TRUE)
    write(paste(head(unique(merged[is.na(merged$row_id.y),1])), sep=";"), file=profilingOutput, append = TRUE)
  }

    if (OrderItemSalesAmount_CI > 0) {
      #item_agg <- aggregate(order_item[,c(OrderItemSalesAmount_CI)], by=list(OrderID=order_item[,c(OrderId_CI)]), FUN=sum)
      order_item$item_sum <- order_item[,c(OrderItemSalesAmount_CI)]*order_item[,c(OrderItemSalesQuantity_CI)]
      totalAgg <- merge( 
          order[,c(OrderOrderId_CI,OrderAmount_CI)], 
          aggregate(order_item[,"item_sum"], by=list(OrderID=order_item[,c(OrderId_CI)]), FUN=sum),
          by.x = 1, by.y = 1, all = FALSE)
      diffCount <- dim(totalAgg[round(totalAgg[,2] - totalAgg[,3],2) != 0, ])[1]
      if (diffCount > 0) {
        write("", file=profilingOutput, append = TRUE)
        write(paste("5. #order.Total != sum(order_item.price*order_item.quantity): ", diffCount), file=profilingOutput, append = TRUE)
        write("OrdersID examples: ", file=profilingOutput, append = TRUE)
        write(paste(head(totalAgg[round(totalAgg[,2] - totalAgg[,3],2) != 0,1]), sep=";"), file=profilingOutput, append = TRUE)
      }
      order_item$item_sum <- NULL
    }
  }

  return (order_item)
}

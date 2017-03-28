checkSalesItem <- function(file_params, file, sales_item_columns, product = NULL) {
  wappend("############################################################## SALES ITEMS #######################################################", file)
  
  sales_item_results <- readFile (file_params)
  sales_item <- sales_item_results$data
  
  wappend("Checking columns:", file, TRUE)
  sales_item_columns <- parse_columns(sales_item, sales_item_columns)
  
  if ((sales_item_columns$order$index == 0) | (sales_item_columns$date$index == 0) | (sales_item_columns$customer$index == 0) | (sales_item_columns$item$index == 0) | (sales_item_columns$amount$index == 0)) {
    wappend("1. There is missing required column. Profiling has been stopped.", file, TRUE)
    return (sales_item)
  } 

  if ((sales_item_columns$quantity$index == 0) | (sales_item_columns$price$index == 0) ) {
    wappend("1. There is missing optional column. Profiling running forward.", file, TRUE)
  }

  summary <- summaries (sales_item, unique_CI = NULL, date_CI = sales_item_columns$date$index)
  write_summaries(summary = summary, file = file)
  
  #Checking SALES ITEMS
  wappend("3. Sales item checks.", file, TRUE)
  
  if (!is.null(product)) {
    print("Starting Sales Items VS Product checks.")
    product_item_CI = product$columns$item$index
    l_product <- as.data.frame(unique(product$data[,c(product_item_CI)]))
    sales_item$row_id <- as.numeric(rownames(sales_item))
    l_product$row_id <- as.numeric(rownames(l_product))
    productSeq_CI <- getColumnIndice(l_product, "row_id")
    sales_itemSeq_CI <- getColumnIndice(sales_item, "row_id")
    
    merged <- merge(sales_item[,c(sales_itemSeq_CI,sales_item_columns$item$index)], l_product[,c(productSeq_CI,1,1)], by.x = 2, by.y = 2, all = TRUE)
    mRowsCount <- nrow(merged)
    #products without sales_items
    write_percent ("4/I. #distinct products without sales_items: ", sum(is.na(merged$row_id.x)), nrow(l_product), file)
    
    if (sum(is.na(merged$row_id.x)) > 0) {
      wappend("product examples without sales_items: ", file)
      wappend(paste(head(unique(merged[is.na(merged$row_id.x),4])), sep=";"), file)
    }
         
    #sales_item without product
    write_percent ("4/II. #Sales itmes without product: ", sum(is.na(merged$row_id.y)), nrow(sales_item), file)
    if (sum(is.na(merged$row_id.y)) > 0) {
      wappend("product item examples without product: ", file)
      wappend(paste(head(unique(merged[is.na(merged$row_id.y),1])), sep=";"), file)
      write.table(unique(merged[is.na(merged$row_id.y),1]), file=paste("./Profiling/",strsplit(file_params$name, split="\\.")[[1]][1],"_missing_products.csv", sep=""), row.names=F, quote = FALSE, col.names=F)    
    }
    sales_item$row_id <- NULL
  }
  
  sales_item_duplication_count <- nrow(sales_item[duplicated(sales_item),])
  sales_item_unique_duplication_count <- nrow(unique(sales_item[duplicated(sales_item),]))
  sales_item_all_duplicatin_count <- sales_item_duplication_count + sales_item_unique_duplication_count
  sales_item_count <- nrow(sales_item)
  if (sales_item_duplication_count > 0) {
    wappend(paste("5. Count of duplicated rows in sales_item :", sales_item_all_duplicatin_count,"(",sales_item_unique_duplication_count,"unique) out of", sales_item_count,"(",round(100*sales_item_all_duplicatin_count/sales_item_count,2), "%). Examples:"), file, TRUE)
    suppressWarnings(write.table(head(unique(sales_item[duplicated(sales_item),]),10), file=file, append = TRUE, na = "", sep=file_params$separator, row.names=F))
    write.csv(unique(sales_item[duplicated(sales_item),]), file=paste("./Profiling/",strsplit(file_params$name, split="\\.")[[1]][1],"_unique_duplications.csv", sep=""), row.names=F)    
  } else {
    wappend("5. Duplicated rows have not found in the sales_item file.", file, TRUE)
  }

  return  (list(data=sales_item, columns=sales_item_columns, result = sales_item_results$result))
}

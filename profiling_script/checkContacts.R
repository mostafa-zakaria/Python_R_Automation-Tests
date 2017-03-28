checkContact <- function(file_params, profilingOutput, 
                          UserId_CN, registration_date_CN = NULL,
                          order = NULL, OrderUserId_CI, OrderDate_CI, OrderOrderID_CI) {

  file <- file(profilingOutput, open="ab", encoding="UTF-8")
  wappend("############################################################## CONTACTS #######################################################", file)
  
  contact <-readFile (file_params)$data

  wappend("Checking columns:", file, TRUE)
  registration_date_CI <- -1
  UserId_CI <- -1
  if (nchar(registration_date_CN)>0) {
    registration_date_CI <- getColumnIndice(contact, registration_date_CN, "registration date")
  }
  
  if (nchar(UserId_CN)>0) {
    UserId_CI <- getColumnIndice(contact, UserId_CN, "user ID")
    
    if (UserId_CI == 0){
      wappend("1. There is missing required column. Profiling has been stopped.", file, TRUE)
      return (list(contact=contact, customer=NULL))
    } else {
      wappend("1. Required columns found.", file, TRUE)
    }
  } else {
    wappend("User ID related test skipped.", file, TRUE)
  }

  summary <- summaries (contact, unique_CI = UserId_CI, date_CI = registration_date_CI)
  write_summaries(summary = summary, file = file)
  
  customer=NULL
  
  if (!summary$unique_column$is.missing) {
    if (if_param_is_a_column_indice("OrderUserId_CI")) {
      #Check UserID
      wappend("5. Contact <-> order checks. ", file)
      
      contact_dim <- create_contact_dim(c(as.character(unique(contact[,c(UserId_CI)])), as.character(unique(order[,c(OrderUserId_CI)]))))
      contact <- merge(contact, contact_dim, by.x=UserId_CI, by.y = 'ExternalID')[, union(names(contact), 'contact_integer_id')]
#       order <- merge(order, contact_dim, by.x=OrderUserId_CI, by.y = 'ExternalID')
      order <- merge(order, contact_dim, by.x=OrderUserId_CI, by.y = 'ExternalID')[, union(names(order), 'contact_integer_id')]
      
      contact$row_id <- as.numeric(rownames(contact))
      order$row_id <- as.numeric(rownames(order))
      OrderSeq_ColumnId <- getColumnIndice(order, "row_id")
      ContactSeq_ColumnId <- getColumnIndice(contact, "row_id")
      
      order_contact_integer_ColumnId <- getColumnIndice(order, "contact_integer_id")
      contact_contact_integer_ColumnId <- getColumnIndice(contact, "contact_integer_id")
      
      #to omit invalid factor level warning
      contact[,UserId_CI] <- as.character(contact[,UserId_CI])
      
      merged <- merge(contact[!is.na(contact[,c(UserId_CI)]),c(ContactSeq_ColumnId, contact_contact_integer_ColumnId)], 
                      order[,c(OrderSeq_ColumnId,order_contact_integer_ColumnId, order_contact_integer_ColumnId, OrderOrderID_CI)], by.x = 2, by.y = 2, all = TRUE)

      mRowsCount <- nrow(merged)
      wappend(paste("#Distinct contacts : ",length(unique(contact[!is.na(contact[,UserId_CI]),UserId_CI]))), file)
      wappend(paste("#Distinct contacts in order : ",length(unique(order[,OrderUserId_CI]))), file)
      
      all_issues <- sum(is.na(merged$row_id.x))
      
      #Orders without contacts
      write_percent_with_unique ("5/I. #Orders without contacts: ", sum(is.na(merged$row_id.x)), 
                                 paste("(",length(unique(merged[is.na(merged$row_id.x),5])), "orders;", length(unique(merged[is.na(merged$row_id.x),4])), "contacts)"), 
                                 nrow(order), file)
      if (sum(is.na(merged$row_id.x)) > 0) {
        wappend("examples: ", file, TRUE)
        wappend(paste(contact_dim[contact_dim$contact_integer_id %in% head(unique(merged[is.na(merged$row_id.x),4])),2], sep=";"), file)
      }
      
      #contact without order
      write_percent_with_unique ("5/II. #contact without order: ", sum(is.na(merged$row_id.y)), length(unique(merged[is.na(merged$row_id.y),1])), nrow(contact), file)
      if (sum(is.na(merged$row_id.y)) > 0) {
        wappend("examples: ", file)
        wappend(paste(contact_dim[contact_dim$contact_integer_id %in% head(unique(merged[is.na(merged$row_id.y),1])),2], sep=";"), file)
      }
      
      #Check double UserId's

      duplicated_UserId <- as.data.frame(unique(contact[duplicated(tolower(contact[,c(UserId_CI)])) == TRUE & !is.na(contact[,c(UserId_CI)]),c(UserId_CI)]))
      duplicated_UserId_orders <- merge(order[,c(OrderSeq_ColumnId,OrderUserId_CI)], duplicated_UserId, by.x = 2, by.y = 1, all = FALSE)
      names(duplicated_UserId_orders)[1] <- "UserID"
      
      wappend(paste("6/1. #Orders count with duplicated userIDs:",nrow(duplicated_UserId_orders)), file)
      if (nrow(duplicated_UserId_orders) > 0) {
        wappend("examples: ", file)
        suppressWarnings(write.table(
          contact_dim[contact_dim$contact_integer_id %in% head(unique(duplicated_UserId_orders$UserID)),2]
          , file=file, append = TRUE, na = "", sep=file_params$separator, row.names=F))
      } 
    }
    if (if_param_is_a_column_indice("UserId_CI") & if_param_is_a_column_indice("registration_date_CI") & if_param_is_a_column_indice("OrderUserId_CI") & if_param_is_a_column_indice("OrderDate_CI") & !summary$date_column$is.missing) {
      load_and_install_package("plyr")
      load_and_install_package("dplyr")
      con <- contact[,c(UserId_CI, registration_date_CI)]
      names(con) <- c("customer_id", "registration_date")
      con$customer_id <- as.character(con$customer_id)
      con$registration_date <- as.Date(con$registration_date, summary$date_column$date_format)
      
      sim <- order[,c(OrderUserId_CI, OrderDate_CI)]
      names(sim) <- c("customer_id", "order_date")
      sim$customer_id <- as.character(sim$customer_id)
      sim_date_format <- checkDate (sim,2) 
      sim$order_date <- as.Date(sim$order_date, sim_date_format)
      
      sim_agg <- group_by(sim, customer_id) %>%
        summarise( min_order_date = min(order_date))
      
      customer <- inner_join(con, sim_agg) %>%
        mutate(first_order_distance = min_order_date - registration_date)
      customer <- customer[!is.na(customer$first_order_distance),]
    } 
  } 

  close(file)
  return (list(contact=contact, customer=customer, contact_dim=contact_dim))
}

load_and_install_package("Hmisc")

summaries <- function (df, describe = NULL, date_CI = NULL, unique_CI = NULL) {
  result <- list(
    na.count = sum(is.na(df)), 
    na.examples = head(df[rowSums(is.na(df))>0,]),
    summary = summary(df),
    description = describe,
    column.names = names(df),
    column.types = sapply(df[1,], class)
    )
    
  if (is.null(result$description)) result$description = describe(df)
  
  if (!is.null(unique_CI))
    result$unique_column <- get_column_measures (result$column.names, unique_CI, result$description)
  
  if (!is.null(date_CI)) {
    result$date_column <- get_column_measures(result$column.names, date_CI, result$description)
    result$date_column$date_format = checkDate (df, date_CI)
  }
  
  result
}



get_column_measures <- function (column.names, CI, describe) {
  column <- list(name=find_column_by_id(column.names, CI))
  if (!is.null(column$name)) {
    column$is.missing <- FALSE
    column$count <- as.integer(describe[[column$name]][["counts"]][["n"]])
    column$missing <- as.integer(describe[[column$name]][["counts"]][["missing"]])
    column$unique <- as.integer(describe[[column$name]][["counts"]][["unique"]])
    
    if (is.missing_column(describe, column$name))
      column$is.missing <- TRUE
  } else 
    column$is.missing <- TRUE

  column
}



find_column_by_id <- function (column.names, CI) {
  column_name <- NULL
  if (if_param_is_a_column_indice("CI"))
    if (CI <= length(column.names))
      column_name = column.names[CI]
  column_name
}




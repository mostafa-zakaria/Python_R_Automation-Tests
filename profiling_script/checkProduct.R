source("utils/parse_columns.R", chdir=TRUE)

checkProduct <- function(file_params, file, product_columns) {
  
  wappend("############################################################## PRODUCTS #######################################################", file)
  
  product_results <- readFile (file_params)
  product <- product_results$data
  
  wappend("Checking columns:", file, TRUE)
  product_columns <- parse_columns(product, product_columns)
  
  if ((product_columns$item$index == 0) | (product_columns$title$index == 0) | (product_columns$category$index == 0) ) {
    wappend("1. There is missing required column. Profiling has been stopped.", file, TRUE)
    return (product)
  } else {
    wappend("1. Required columns found.", file, TRUE)
  }

  summary <- summaries (product, unique_CI = product_columns$item$index)

  write_summaries(summary = summary, file = file)
  
  return (list(data=product, columns=product_columns, result=product_results$result))
}



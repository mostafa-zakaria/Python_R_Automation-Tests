source("getNumberOfRowsFromFile.R", chdir=TRUE)
source("exception_handling.R", chdir=TRUE)
source("file_related_issues.R", chdir=TRUE)

readFile <- function(file_params) {
  if (file_params$big_file) {
    load_and_install_package("data.table")
    column_types <- read_column_types(file_params)
    column_types[names(file_params$column_types)] <- file_params$column_types
    system.time(df <- fread(file_params$name, sep=file_params$separator, header=file_params$has_header, colClasses=column_types, stringsAsFactors=file_params$string_as_factor, na.strings=file_params$na_values))  
    setnames(df,1,delete_BOM_from_string(names(df)[1], file_params$encoding))
    df  <- data.frame(df)
    for (i in seq(length(column_types))) {
      if (column_types[i] == 'numeric' & !(class(df[,c(i)]) == 'numeric') ) {
        print(paste('Converting to number:',names(column_types)[i]))
        df[,c(i)]  <- as.numeric(gsub(file_params$dec, ".", df[,c(i)]))
      }
    }
  } else {
    stop_if_more_columns_than_column_names(file_params)    
    df <- read.table(file_params$name, sep=file_params$separator, row.names = NULL, fill=TRUE, header=file_params$has_header, quote=file_params$quote, comment.char = file_params$comment_char, encoding=file_params$encoding, stringsAsFactors=file_params$string_as_factor, dec=file_params$dec, na.strings=file_params$na_values, colClasses=file_params$column_types)
  }
  
  result <- list(
    number_of_observations = nrow(df),
    number_of_rows = getNumberOfRowsFromFile(file_params$name),
    element_count_check_warning = check_element_counts (file_params, df)
  )
 
  if (file_params$has_header == TRUE)
    result$number_of_rows <- result$number_of_rows - 1
  
  result$badly_loaded_rows_count = abs(result$number_of_rows - result$number_of_observations)
  if (result$badly_loaded_rows_count > 0) {
    #make_guesses_about_bad_rows_count_issue doesn't work for big files: very slow and leaking the memory
    result$bad_rows_guesses <- df[FALSE,]#make_guesses_about_bad_rows_count_issue(df)
    result$tail <- tail(df)
  } 

  review_result(result, file_params$stop_count)
  if (!file_params$big_file) {
    names(df)[1] <- delete_BOM_from_string(names(df)[1], file_params$encoding)
  }

  return (list(data=df,result=result))
}



check_element_counts <- function (file_params, df) {
  if (file_params$big_file)
    return (NULL)
  
  error <- tryCatch({
    scan(file = file_params$name, what=as.list(sapply(df,class)), sep = file_params$separator, quote = file_params$quote, 
         dec = file_params$dec, skip = 1, na.strings = file_params$na_values, quiet = TRUE, fill = FALSE, strip.white = FALSE, 
         blank.lines.skip = TRUE, multi.line = FALSE, comment.char = file_params$comment_char, allowEscapes = FALSE, 
         flush  = FALSE, encoding = file_params$encoding)  
    NULL
  }, warning = function(w) { }, error = function(e) {return(e)}, finally = {})
  return (gsub("elements","columns", error[1]))
}



stop_if_more_columns_than_column_names <- function (file_params) {
  if (!is.character(file_params$name)) 
    return (NULL)

  file <- file(file_params$name, "rt")

  header_length <- length(scan(file, what = "", sep = file_params$separator, quote = file_params$quote,nlines = 1, quiet = TRUE, skip = 0, strip.white = TRUE, comment.char = file_params$comment_char, encoding = file_params$encoding))
  
  col <- numeric(5)
  for (i in seq(5)) 
    col[i] <- length(scan(file, what = "", sep = file_params$separator, quote = file_params$quote,nlines = 1, quiet = TRUE, skip = 0, comment.char = file_params$comment_char, encoding = file_params$encoding))
  
  data_columns_length <- max(col)
  close(file)
  if (header_length < data_columns_length)
    custom_stop("more columns than column names", "more columns than column names")
}



highlight_bad_row_guesses <- function(results) {
  results$bad_rows_guesses
}



tail_df <- function(results) {
  results$tail
}



review_result <- function (results, stop_count) {

  if (!is.null(results$element_count_check_warning))
    if (length(results$element_count_check_warning) > 0)
      warning(results$element_count_check_warning)
  
  if (is.null(results$bad_rows_guesses))
    results$bad_rows_guesses <- as.data.frame(NULL)
    
  if (results$badly_loaded_rows_count > 0)
    if (results$badly_loaded_rows_count == 1 & nrow(results$bad_rows_guesses) == 0) {
      NULL
    } else {
      warning(paste("Loaded observation count is different from rows count in file. Difference is",results$badly_loaded_rows_count,"There might be bad string quoting in the file."))
    }
  
  if (results$badly_loaded_rows_count > stop_count)
    custom_stop("Bad string quoting", paste("Bad string quoting in file. Limit:",stop_count,", occured:",results$badly_loaded_rows_count))
}



build_file_params <- function(params) {
  
  if (is.null(params$separator)) params$separator <- ","
  if (is.null(params$has_header)) params$has_header <- TRUE
  if (is.null(params$quote)) params$quote <- "\""
  if (is.null(params$comment_char)) params$comment_char <- ""
  if (is.null(params$stop_count)) params$stop_count <- 3
  if (is.null(params$encoding)) params$encoding <- "UTF-8"
  if (is.null(params$dec)) params$dec <- "."
  if (is.null(params$na_values)) params$na_values <- c("na","na.","n/a","n/a.","#n/a","#n/a.", "null")
  params$na_values <- c(params$na_values, toupper(params$na_values), "")
  if (is.null(params$string_as_factor)) params$string_as_factor <- TRUE
  if (is.null(params$big_file)) params$big_file  <- FALSE
  if (is.null(params$column_types)) params$column_types  <- NA
  
  return (params)
}



read_column_types <- function(file_params) {
  df <- read.table(file_params$name, sep=file_params$separator, header=file_params$has_header, quote=file_params$quote, comment.char = file_params$comment_char, encoding=file_params$encoding, dec=file_params$dec, nrows = 1000)
  sapply(df, class)
}



params_exist <- function (file_param_name, envir=parent.frame()) {
  if (exists(file_param_name, mode="list", envir=envir)) {
    if (eval(parse(file="", text=paste("nchar(",file_param_name,"$name) > 0",sep="")), envir=envir))
      return (TRUE)
    else 
      return (FALSE)
  }
  else
    return (FALSE)
}

source("summaries.R", chdir=TRUE)

write_summaries <- function (summary, file) {
  write_variable_types (file, summary)
  #write_simple_summary (file, summary)
  write_detailed_description (file, summary)
  
  write_na_data       (summary, file)
  write_unique_column (summary, file)
  write_date_column   (summary, file)
  
  return (TRUE) 
}



write_variable_types <- function (file, summary) {
  wappend("VARIABLE TYPES:", file, TRUE)
  wappend(flatten_vector(summary$column.names), file)
  wappend(flatten_vector(summary$column.types), file)
}



write_simple_summary <- function (file, summary) {
  wappend("SIMPLE SUMMARY OF THE FILE", file, TRUE)
  capture.output(summary$summary, file = file, append = TRUE) 
}



write_detailed_description <- function (file, summary) {
  wappend("Detailed description:", file, TRUE)
  capture.output(summary$description, file = file, append = TRUE) 
}


write_na_data <- function (summary, file) {
  wappend(paste("Count of NA values: ",summary$na.count), file, TRUE)
  
#   if (summary$na.count > 0) {
#     wappend("NA examples:", file, TRUE)
#     write.csv2(summary$na.examples, file=file, quote=FALSE)   
#   }
}



write_unique_column <- function (summary, file) {
  if (is.null(summary$unique_column))
    return (NULL)
  
  if (summary$unique_column$is.missing)
    wappend("Unique column is missing", file, TRUE)
  else {
    if (summary$unique_column$unique != summary$unique_column$count) {
      wappend(paste(summary$unique_column$name, "column is not unique"), file, TRUE)
      wappend(paste("Count", summary$unique_column$count), file)
      wappend(paste("Missing", summary$unique_column$missing), file)
      wappend(paste("Unique", summary$unique_column$unique), file)
    }
    else
      wappend(paste(summary$unique_column$name, "column is unique"), file, TRUE)
    
  }
}    



write_date_column <- function (summary, file) {
  if (is.null(summary$date_column))
    return (NULL)
  
  if (summary$date_column$is.missing) {
    wappend("Date column is missing", file, TRUE)
  } else {
    if (summary$date_column$date_format == "")
      wappend(paste(summary$date_column$name, "is not a valid date"), file, TRUE)
    else
      wappend(paste(summary$date_column$name, "format:", summary$date_column$date_format), file, TRUE)
  }
}    



write_percent <- function (text, value, out_of_value, file) {
  wappend(paste(text, value, "lines out of", out_of_value, "lines (", round(100*value/out_of_value, 2), "%)."), file, TRUE)
}



write_percent_with_unique <- function (text, value, unique_text, out_of_value, file) {
  wappend(paste(text, 
                value,"lines",unique_text,"out of", 
                out_of_value,"lines (",round(100*value/out_of_value,2), "%)."), file, TRUE)  
}



wappend <- function (string, file, newline = FALSE) {
  if (newline) write("", file=file, append = TRUE)
  write(string, file=file, append = TRUE)
}



flatten_vector <- function(vector, sep="\t") {
  paste(vector, collapse=sep)
}
#TEST TOOLS


create_summary_file <- function (df, file_name, describe = NULL, unique_CI=1, date_CI = NULL) {
  summary <- summaries(df = df, describe = describe, unique_CI = unique_CI, date_CI = date_CI)
  file <- prepare_file(file_name)
  write_summaries(summary = summary, file = file)
  close(file) 
}



remove_output_file <- function (file_name) {
  if (file.exists(file_name)) file.remove(file_name)
}

 

prepare_file <- function (file_name) {
  remove_output_file(file_name)
  file(file_name, open="wb", encoding="UTF-8")
}



file_contains_the_vector <- function(file_name, vector, sep=".*") {
  file_content <- readChar(file_name, file.info(file_name)$size)
  grepl(paste(vector,collapse=sep), file_content)
}



file_contains_the_string <- function(file_name, string) {
  file_content <- readChar(file_name, file.info(file_name)$size)
  grepl(string, file_content)
}
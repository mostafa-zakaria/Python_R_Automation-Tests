checkDate <- function(df, colInd, format = "", withDebug = FALSE, sep="") {

  #validate_date_by_length_and_separator(df, colInd, sep)

  custom_format <- test_format(df,colInd,format,withDebug)
  if (nchar(custom_format) > 0) return (custom_format)
  
  acceptable_formats = c("%d/%m/%Y","%d-%m-%Y","%d.%m.%Y",
                         "%Y/%m/%d","%Y-%m-%d","%Y.%m.%d",
                         "%m/%d/%Y","%m-%d-%Y","%m.%d.%Y", 
                         "%Y%m%d")
  
  return (test_formats (acceptable_formats, df, colInd, withDebug))
}



validate_date_by_length_and_separator <- function (df, colInd, sep) {
  if (sep == "")
    sep = paste("[",get_separator_from_string(df[1,colInd]),"]",sep="")
  
  if (min(nchar(unlist(strsplit(as.character(df[,colInd]),sep)))) + 3 < max(nchar(unlist(strsplit(as.character(df[,colInd]),sep))))
      | min(nchar(as.character(df[,colInd]))) + 2 < max(nchar(as.character(df[,colInd])))) {
    custom_stop("Different string lengths in date column", paste("Different date formats"))
  }
}



get_separator_from_string <- function (string) {
  acceptable_separators <- c(".","/","-")
  
  i <- 1
  while (i <= length (acceptable_separators) ) {
    if (grepl(paste("[",acceptable_separators[i],"]", sep=""),string))
      return (acceptable_separators[i])
    i = i + 1;
  }
  return ("")  
}


test_formats <- function (acceptable_formats, df, colInd, withDebug) {
  i <- 1
  while (i <= length (acceptable_formats) ) {
    format <- test_format(df,colInd,acceptable_formats[i],withDebug)
    if (nchar(format) > 0) return (format)
    i = i+1;
  }
  return ("")  
}



test_format <- function(df, colInd, format, withDebug = FALSE) {
  f1 <- ""
  tryCatch({
    if (withDebug) print(paste("Check: ",format))
    testCol <- as.Date(as.character(df[,colInd]), format=format)
    if (sum(is.na(df[,colInd])) == sum(is.na(testCol))) {
      f1 <- format
    }
  }, warning = function(w) { }, error = function(e) { }, finally = {})
  
  return (f1)
}



test_custom_format <- function (format, withDebug, df, colInd) {
  if (nchar(format) > 0) {
    if (withDebug) print(paste("format: ",format))
    return (test_format(df,colInd,format,withDebug))
  } 
}

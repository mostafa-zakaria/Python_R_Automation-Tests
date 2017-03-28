exclude_negative_or_na_values_by_column <- function (dataFrame, columnIndex) {
  return (dataFrame[dataFrame[,c(columnIndex)] >= 0 & !is.na(dataFrame[,c(columnIndex)]),])
}



get_na_examples_by_column <- function (df, na_lookup_column_id, return_column_id) {
  return (data.frame(df)[is.na(df[,c(na_lookup_column_id)]),c(return_column_id)])
}



get_negative_examples_by_column <- function (df, lookup_column_id, return_column_id) {
  return (data.frame(df)[data.frame(df)[,c(lookup_column_id)] < 0 & !is.na(data.frame(df)[,c(lookup_column_id)]),c(return_column_id)])
}



is.missing_column <- function (describe_object, column_name) {
  if (!(class(describe_object) == 'describe'))
    custom_stop("invalid_class", 'invalid_class: is.missing_column doesn\'t accepts other class than \"describe\"')
  
  column_name %in% attributes(describe_object)$missing.vars
}



stop_if_not_a_number <- function (values_vector, column_name) {
  tryCatch({
    as.numeric(as.character(values_vector))
  }, warning = throw_invalid_number, error = throw_invalid_number, finally = {})
  FALSE
}



convert_to_numeric_if_factor <- function (values_vector) {
#   if (!is.factor(values_vector))
#     custom_stop("invalid_class", 'invalid_class: column is not a factor')
  if (is.factor(values_vector))
    return (as.numeric(as.character(values_vector)))
  else 
    return (values_vector)
}
  


get_date_before <- function (date, years, months = NULL) {
  d <- as.POSIXlt(date)
  d$year <- d$year - years
  if (!is.null(months))
    d$mon <- d$mon - months
  as.Date(d)
}



if_param_is_a_column_indice <- function (param, envir=parent.frame()) {
  if (!exists(param, mode="integer", envir=envir)) {
    return (FALSE)
  }
  
  if (eval(parse(file="", text=paste("(",param, " < 1)", sep="")), envir=envir))
    return (FALSE)
  
#   if (param < 1)
#     return (FALSE)
  return (TRUE)
}



getColumnIndice <- function( df, column_name, column_to_find=""){
  column_id <- find_string_in_vector(colnames(df), column_name)
  
  if (length(column_id) > 0) {
    return(column_id)
  } else {
    warning(paste(column_to_find, "column -",column_name,"- didn't find.", sep=" "))
    return(0)
  }  
}



find_string_in_vector <- function(vector, string) {
  which( vector==convert_string_to_column_name(string) )
}



convert_string_to_column_name <- function(column_name) {
  gsub(" ",".",column_name )
}



delete_BOM_from_string <- function (string, encoding = 'UTF-8') {
  if (encoding != "UTF-8" & isTRUE(all.equal(charToRaw(substr(string,1,3)), c(as.raw(239),as.raw(46),as.raw(191)))))
    string <- substr(string,4,nchar(string))
  
  #It works differently from Rscript and RStudio
  string <- sub("X...","", string)
  string <- sub("FEFF.","", string)
  
  return (sub("X.U.FEFF.","", string))
}



override_item_colum_type <- function(file_params, column_name, type) {
  override_column_types_with <- c(type)
  colnames <- names(read_column_types(file_params)[1])
  
  if (length(find_string_in_vector(delete_BOM_from_string(colnames, file_params$encoding),convert_string_to_column_name(column_name))) > 0) {
    names(override_column_types_with)[1] <- colnames
  } else {
    names(override_column_types_with)[1] <- convert_string_to_column_name(column_name)
  }
  
  file_params$column_types = override_column_types_with
  file_params
  
}


create_contact_dim <- function(user_id_vector) {
  contact_dim <- unique(user_id_vector)
  contact_dim <- as.data.frame(contact_dim[order(contact_dim)])
  names(contact_dim) <- c('ExternalID')
  contact_dim$ExternalID <- as.character(contact_dim$ExternalID)
  contact_dim$contact_integer_id <- seq(1, nrow(contact_dim))
  contact_dim[,c('contact_integer_id','ExternalID')]
}

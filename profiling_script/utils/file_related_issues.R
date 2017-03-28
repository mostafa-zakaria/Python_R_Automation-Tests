load_and_install_package('stringr')

make_guesses_about_bad_rows_count_issue <- function(df) {
  df[count_of_eol_in_row(df) > 0, ]
}



count_of_eol_in_row <- function(df) {
  rowSums(
    as.data.frame(lapply(df,count_of_eol)) - as.numeric(is.na(df))
    , na.rm = T)
}



count_of_eol <- function(x) {
  str_count(x,'\n')
}



# View(tail(df))

throw_invalid_number <- function (x) {
  custom_stop("invalid number", paste('invalid number:',x,"column is not a number. Check the decimal_separator parameter in profiling_sales_item.R file."))
}



custom_stop <- function(subclass, message, call = sys.call(-1), ...) {
  c <- condition(c(subclass, "error"), message, call = call, ...)
  stop(c)
} 



condition <- function(subclass, message, call = sys.call(-1), ...) {
  structure(
    class = c(subclass, "condition"),
    list(message = message, call = call),
    ...
  )
}
is.condition <- function(x) inherits(x, "condition")

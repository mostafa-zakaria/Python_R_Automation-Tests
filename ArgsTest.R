result <- tryCatch({
  # max.R
  # Fetch command line arguments
  myArgs <- commandArgs(trailingOnly = TRUE)
  
  print(paste("First Argument>  ", myArgs[1]))
  
  erd <- 5 / 0
  
}, error = function(err){
  print(paste("MY_ERROR>  ", err))
  return(-1)
}, finally = {
  print("FINALLY")
}
)

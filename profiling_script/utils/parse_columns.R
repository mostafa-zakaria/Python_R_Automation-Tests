source("utils.R", chdir=TRUE)

parse_columns <- function(df, columns) {
  
  for (i in 1:length(columns)) {
    columns[[i]] <- list(
                        name = columns[[i]], 
                        index = getColumnIndice(df, columns[[i]], names(columns)[i]))
  }
  
#   columns <- product_columns <- list(
#     item = list(name="item", index=5),
#     title = list(name="title", index=4),
#     category = list(name="category", index=4)
#   )
#   
#   product_columns_src <- list(
#     item = "item",
#     title = "title",
#     category = "category"
#   )
#   
#   names(product_columns_src)[1]
  
  columns
}
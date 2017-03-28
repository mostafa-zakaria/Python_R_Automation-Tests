print(getwd())
source("../../profiling_script/utils/utils.R")
load_and_install_package("plyr")
load_and_install_package("dplyr")
load_and_install_package("data.table")


aggregate_rfm <- function (act_sales_item, rfm_calc_years) {
  max_order_date <- max(act_sales_item$OrderDate)
  fromDate <- get_date_before(max_order_date, years <- rfm_calc_years, months <- NULL)
  act_sales_item <- filter(act_sales_item, OrderDate >= fromDate)
  
  #Aggregate by ORDER
  sales_cust <- act_sales_item %>%
    group_by(CustomerID, OrderID) %>%
    summarise( Price = sum(Price,na.rm = TRUE), OrderDate = min(OrderDate))
  sales_cust <- sales_cust %>%
    mutate(
      #     recency = difftime(max_order_date,OrderDate,units="days")
      recency =as.integer(max_order_date) - as.integer(OrderDate)
    )
  sales_cust <- sales_cust %>%
    arrange(CustomerID, OrderDate)
  
  sales_cust <- sales_cust %>%
    ungroup() %>%
    group_by(CustomerID) %>%
    arrange(CustomerID, OrderDate) %>%
    mutate(
      # days_diff = as.integer(OrderDate) - as.integer(lag(OrderDate)),
      rn = row_number(CustomerID)
    ) 
  
  sales_cust <- data.table(sales_cust)
  sales_cust[, integer_date := as.integer(OrderDate)]
  sales_cust <- sales_cust[, lag.integer_date:=c(NA, integer_date[-.N]), by=CustomerID]
  sales_cust <- sales_cust[, days_diff := as.integer(OrderDate) - lag.integer_date]
  
  sales_cust <- as.data.frame(sales_cust) %>% 
    group_by(CustomerID) 
  
  sales_cust <- sales_cust %>%
    summarise(
      Recency = min(recency),
      Frequency = n(),
      Monetary = round(sum(Price)),
      MonetaryMean = round(mean(Price)),
      ConversionPeriod = max(ifelse( rn == 2, days_diff,-1)),
      ActivityPeriod = round(mean(days_diff, na.rm=TRUE))
    ) %>%
    arrange(CustomerID)
  
  sales_cust[sales_cust$ConversionPeriod == -1,]$ConversionPeriod <- NA
  sales_cust
}
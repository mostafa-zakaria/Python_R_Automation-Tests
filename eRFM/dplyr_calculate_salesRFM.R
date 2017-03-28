load_and_install_package("plyr")
load_and_install_package("dplyr")
load_and_install_package("data.table")
source(paste(eRFMScriptLocation,"/utils/aggregate_salesrfm.R",sep=""), chdir = T)

salesRFM <- aggregate_rfm(act_sales_item, rfm_calc_years)

na_monetary.examples <- contact_dim[contact_dim$contact_integer_id %in% get_na_examples_by_column(salesRFM, 4, 1),2]

na_monetary.count <- length(na_monetary.examples)

negative_monetary.examples <- contact_dim[contact_dim$contact_integer_id %in% get_negative_examples_by_column(salesRFM, 4, 1),2]
negative_monetary.count <- length(negative_monetary.examples)

salesRFM <- exclude_negative_or_na_values_by_column(salesRFM, 4)
salesRFM <- as.data.frame(salesRFM)
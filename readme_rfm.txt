#########################################
eRFM limit testing
#########################################
0. start RStudio
1. select the working directory where the profiler.R file presents. (in RStudio there is a file pane on the bottom right area, there you will find an icon with "..." on it)
2. in the file pane click "more" and click on "Set As Working Directory"
3. Open profiler.R file (or profiling_sales_item.R in case of the new format), by clicking on it in the file pane.
4. set the appropriate parameters:
   - eRFMScriptLocation: where the eRFM script present (it should be next to profiling_script folder)
   - rfm_calc_years: based on customer requirements;
     the RFM score calculation use sales_items data between the maximum orderdate and (maximum orderdate - <rfm_calc_years> years)

4. hit Ctrl+alt+R to run the profiler.R script (or press the Source button on the top-right corner of the editor).
   - there is a red stop table on the top right corner of the consol pane until the script is running.
   - you can find common warning message in the console:
     Warning messages:
     1: package �Hmisc� was built under R version 3.0.2
     2: In write.table(head(duplicated_product_item), file = profilingOutput,  :
       appending column names to file
5. When the script is finished successfully, very important to check the results of profiling.
   Any data related problems may result in meaningless eRFM limits without any warnings
6. copy \eRFM\run_eRFM.R and \eRFM\rfm_interval_tests.rmd the into working folder

   If customer data meets the specification, then no changes necessary in the above scripts.
   Otherwise, you can find 3 common issues as commented in run_eRFM.R:
   - #If the customer douesn't have Amount column (mandatory), but quantity and price are present
   - #Cannot convert date automatically
   - #Round the prices if necessary

7. After the necessary changes run the script. (hit Ctrl+alt+R to run the script (or press the Source button on the top-right corner of the editor).)
You can find the output in <customerName>_rfm_ints_test.html file.

8. If some customization is necessary, open and edit rfm_interval_tests.rmd

   From this point you can run (select & Ctrl+R or Select & Ctrl+Enter in linux) the commands and check the results on the console or on the plot pane.

   The salesRFM data frame contains purchases from the last <rfm_calc_years> years, aggregated by "CustomerID".

   The following columns are present in this data frame:
   "CustomerID"       "Recency"          "Frequency"        "Monetary"         "MonetaryMean"     "ConversionPeriod" "ActivityPeriod"

   Every data calculated per Customer.

   Recency:        the distance of the maximum (order date) and the latest order of the Customer in days.
   Frequency:        the count of the purchases in the examined time window
   Monetary:        the whole amount spent by a customer in the examined time window
   MonetaryMean:    average order value by customer (Monetary/Frequency) - doesn't used currently

   #in case of recurring Customers (=Frequency > 1)
   ConversionPeriod:    time elapsed in days between the customer first and second purchases
   ActivityPeriod:    average time elapsed between purchases in days.

9. Modifying calculations
There are 3 different functions in this section:

   - table: calculates the frequency table of the given variable. Output on the console

   - display_kmeans: caluclates kmeans centers based on the first variable of df, and then call show_intervals, to display the results.
      # df: data frame with two columns. KMeans runs on the first column, and the Total spend calculation uses the second column (it should be the Monetary value)
      # df <- salesRFM[salesRFM$Frequency > 1,c("Recency", "Monetization")]
      
      # p_centers: the target number of clusters 
      # p_centers <- 5
      
      # p_nstart: how many times should kmeans restarted
      # p_nstart <- 20
      
      # p_title: main title of the plot. Some additional information will be concatenated to the end.
      # p_title <- "title"
      
      # original_max_value: the original maximum value of the first column. Meaningful only if there were some outliers excluded.
      # original_max_value <- max(salesRFM$Recency)
      
      # p_exclude_top_n: exclude top <p_exclude_top_n> rows based on value before kmeans calculation
      # p_exclude_top_n <- 10
      
      # p_from: minimum value for the density curve
      # p_from <- NULL
      
      # p_bw : the smoothing bandwidth to be used
      # p_bw <- "nrd0"

   - show_intervals: displays the density of the first variable of the df, and marks the p_breaks on this plot as red lines. 
      # The second part of the results is a bar-chart, where intervals are on the x-axis and the total amount spend (based on the sec. column of df) by an interval appears on y-axis
      # The last chart is similar to the second but with counts on y-axis.
      
      # df: data frame with two columns. Density based on the first column, and the Total spend calculation uses the second column (it should be the Monetary value)
      # df <- salesRFM[salesRFM$Frequency > 1,c("RecencyMean", "Monetization")]
      
      # p_breaks: interval limits. Should include the lowest and the highest values
      # p_breaks <- quantile(salesRFM$Monetization, probs=seq(0,1, by=0.20))
      
      # p_title: main title of the plot.
      # p_title <- "title"
      
      # p_xlim: a vector with two elements (c(x1,x2)). the first is the start of the x-axis, the second is the end of the x-axis
      # p_xlim <- c(0,quantile(salesRFM$Monetization, 0.75) + IQR(salesRFM$Monetization) * 4)

      # p_from: minimum value for the density curve
      # p_from <- NULL

      # p_bw : the smoothing bandwidth to be used
      # p_bw <- "nrd0"

10. You can save changes you made in rfm_interval_tests.rmd and regenerate the output html with repeating the (7.) step. or with the last 2 commands in run_eRFM.R:
    knit2html (input<-'rfm_interval_tests.rmd',output=paste(customerName,"_rfm_ints_test.html",sep=""))
    knit2html (input<-'rfm_interval_tests_essential.rmd',output=paste(customerName,"_rfm_ints_test_essential.html",sep=""))

#########################################
eRFM output description
#########################################
Every figures consist of 3 part.
    - The first is an approximated density function (black line) based on empirical values (the values of the current variable, eg. Monetary values).
      The ordered value set on the x-axis, and the density of the values on the y-axis (~the relative frequency of the current value).
      [1] Its graph is a curve above the horizontal axis that defines a total area, between itself and the axis, of 1. The percentage of this area included between any two values coincides with the probability that the outcome of an observation described by the density function falls between those values.
      The red lines represent the group limits.
    - The second part is a barchart, about Total spent value by each group.
    - The third part is a barchart again, about the Count of occurrences by each group.

Groups are identified by either of
    - custom interval limits. These are just the sequence of numbers from the value set of the current variable, including min and max.
    - With the Quantiles function - find specific percentiles of the variable. 
	[2] The nth percentile of an observation variable is the value that cuts off the first n percent of the data values when it is sorted in ascending order. 
	[3] A percentile (or a centile) is a measure indicating the value below which a given percentage of observations in a group of observations fall
    - kmeans clustering algorithm
	[4] k-means clustering aims to partition n observations into k clusters in which each observation belongs to the cluster with the nearest mean, serving as a prototype of the cluster



[1] - http://www.britannica.com/EBchecked/topic/477515/density-function
[2] - http://www.r-tutor.com/elementary-statistics/numerical-measures/percentile
[3] - http://en.wikipedia.org/wiki/Percentile
[4] - http://en.wikipedia.org/wiki/K-means_clustering (here is a good demonstration as well: "Demonstration of the standard algorithm")

source("../../profiling_script/utils/exception_handling.R", chdir=TRUE)

      # display_kmeans: caluclates kmeans centers based on the first variable of df, and then call show_intervals, to display the results.
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

display_kmeans <- function(df, p_centers, p_nstart, p_title, p_xlim=NULL, original_max_value = -1, p_exclude_top_n = 0,  p_from = NULL, p_bw = "nrd0") {
  names(df) <- c("value", "prize_value")
#   print(paste("original_max_value:", original_max_value))
#   print(paste("p_exclude_top_n:", p_exclude_top_n))
#   print(paste("p_from:", p_from))
#   print(paste("p_bw", p_bw))
  l_df <- break_df_by_top_nth_value(df, 1, p_exclude_top_n)$rest
  
  p_title <- paste(p_title,"- kmeans (",p_centers,")")
  kClust <- kmeans(l_df$value,centers=p_centers, nstart=p_nstart)
  
  l_df$cluster <- kClust$cluster
  
  km_group_limits <- aggregate(l_df$value, by=list(l_df$cluster), min)
  km_group_limits <- km_group_limits[order(km_group_limits$x),]

  k_breaks <- unlist(km_group_limits[,2])
  if (original_max_value != -1) {
    #we need to include all of the available value
    if (max(k_breaks) < as.numeric(original_max_value)) {
      k_breaks <- append(k_breaks, as.numeric(original_max_value))
    } else if (max(k_breaks) == as.numeric(original_max_value)) {
      k_breaks[length(k_breaks)] <- k_breaks[length(k_breaks)] - 1
      k_breaks <- append(k_breaks, as.numeric(original_max_value))
    }
  } else {
    if (max(k_breaks) < as.numeric(max(df$value))) {
      k_breaks <- append(k_breaks, as.numeric(max(df$value)))
    } else if (max(k_breaks) == as.numeric(max(df$value))) {
      k_breaks[length(k_breaks)] <- k_breaks[length(k_breaks)] - 1
      k_breaks <- append(k_breaks, as.numeric(max(df$value)))
    }
  }
#  df$groups=cut(df$value, breaks=k_breaks, include.lowest=TRUE, dig.lab=10)
  cat("breaks:","\n")
  cat(k_breaks,"\n")
  show_intervals (df, p_breaks = k_breaks, p_title = p_title, p_xlim=p_xlim, p_from, p_bw)
  return (k_breaks)
}



break_df_by_top_nth_value <- function (df, column_index, n_rows_to_exclude) {
  if (n_rows_to_exclude < 1) return (df)
  top_nth_value <- min(tail(sort(df[,column_index]),n_rows_to_exclude))
  
  result = list()
  result$top <- df[df[,column_index] >= top_nth_value ,]
  result$rest <- df[df[,column_index] < top_nth_value,]
  result
}

      # show_intervals: displays the density of the first variable of the df, and marks the p_breaks on this plot as red lines. 
      # The second part of the results is a bar-chart, where intervals are on the x-axis and the total amount spend (based on the sec. column of df) by an interval appears on y-axis
      # The last chart is similar to the second but with counts on y-axis.
      
      # df: data frame with two columns. Density based on the first column, and the Total spend calculation uses the second column (it should be the Monetary value)
      # df <- salesRFM[salesRFM$Frequency > 1,c(""Recency", "Monetary")]
      
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

      # p_write_ints : whether to print interval Totals and Counts
      # p_write_ints <- TRUE

show_intervals <- function(df, p_breaks, p_title = NULL, p_xlim = NULL, p_from = NULL, p_bw = "nrd0", p_write_ints = TRUE, p_analize_density = FALSE) {
  names(df) <- c("value", "prize_value")
  
  if (!is.null(p_xlim)) {
    if (p_xlim[2] < max(head(sort(unique(df$value)),2))) {
      warning("xlim_to is too low: xlim_to should be over the second ranked value. Using x_lim = NULL.")
      p_xlim <- NULL
    }
  }

  if (length(unique(p_breaks)) < length(p_breaks)) {
    custom_stop("breaks aren't unique", "breaks aren't unique")    
  }
  
  if (p_write_ints)
    cat(paste("Mean:", round(mean(df$value),2)),"\n")

  if (is.null(p_from)) {
    p_from <- min(df$value)
  }
  
  density_col = "#FF7F0E" #"#1E4FB8"
  bar_col = "#4F81B8"
  int_col = "#059D0C" #"#D62728"

  p_cex <- 1.3
  par(las=1)
  par(mar=c(4,7,4,2)) 
  par(lwd=2)  
  
  df$groups=cut(df$value, breaks=p_breaks, include.lowest=TRUE, right = FALSE, dig.lab=10)
  par(mfrow=c(3,1))
  if (exists("p_xlim", mode="any", inherits = FALSE) & !is.null(p_xlim)) {
    plot(density(df[df$value < p_xlim[2],]$value, bw=p_bw, from=p_from), main=p_title, cex.axis=p_cex, cex.main=p_cex*1.2, cex.lab=p_cex, col=density_col, yaxt="n")
  } else {
    plot(density(df$value, bw=p_bw, from=p_from),main=p_title, cex.axis=p_cex, cex.main=p_cex*1.2, cex.lab=p_cex, col=density_col, yaxt="n")
  }
  
  draw_breaks_on_plot (p_breaks, int_col, p_write_ints)

  if (p_analize_density) {
    dd <- density(df$value, bw=p_bw, from=p_from)
    identify(dd$x, dd$y, labels=dd$x) # identify points 
    return (NULL)    
  }
  
  sums <- aggregate(df$prize_value,list(df$group),sum)
  names(sums) <- c("group","total")
  counts <- aggregate(df$prize_value,list(df$group),length)
  names(counts) <- c("group","count")  

  barplot(sums$total, names.arg=sums$group, main="Total spent", cex.axis=p_cex, cex.names=p_cex, cex.main=p_cex*1.2, col=bar_col)
  #cat("X")
  barplot(counts$count, names.arg=sums$group, main="Count", cex.axis=p_cex, cex.names=p_cex, cex.main=p_cex*1.2, col=bar_col)

  if (p_write_ints) {
    cat("\n")
    cat("Interval Totals.","\n")
    print(sums)
    cat("\n")
    cat("Interval Counts.","\n")
    print(counts)
  }
  
}

draw_breaks_on_plot <- function (p_breaks, int_col, p_write_ints) {
  
  for (i in 1:length(p_breaks) ) {
    abline(v=p_breaks[i],lwd=1, col=int_col)
  }
  
  if (p_write_ints) {
    cat("Interval limits: ","\n")
    cat(p_breaks,"\n")  
  }
}

writeFreqs <-function(df,freqFilename, show_freq_limit = 10000) {

  i <- 1
  while (i <= ncol(df)) {
    if (length(unique(df[,i])) != length(df[,i])) {
      if (length(unique(df[,i])) <= show_freq_limit ) {
        df_freq_temp <- as.data.frame(table(df[,i], useNA ="ifany")) 
      } else {
        df_freq_temp <- head(as.data.frame(table(df[,i]))[order(-as.data.frame(table(df[,i]))[,2]),],1000)
      }
      df_freq_temp$Var1 <- as.character(df_freq_temp$Var1)
      df_freq_temp[is.na(df_freq_temp$Var1),"Var1"] <- "NA"
      
        names(df_freq_temp) <- c(names(df)[i],paste(names(df)[i],"_Freq",sep=""))
        df_freq_temp$FreqNdx <- seq(1,nrow(df_freq_temp))
        if (exists("df_freqs")) {
          df_freqs <- merge(df_freqs, df_freq_temp, by.x = "FreqNdx", by.y = "FreqNdx", all = TRUE)
        } else {
          df_freqs <- df_freq_temp
        }
    }
    i <- i + 1
  }

  if(exists("df_freqs", mode="any")) {
    write.csv2(df_freqs, freqFilename, na = "") 
    return (df_freqs)
  } else {
    return (NULL);    
  }
}


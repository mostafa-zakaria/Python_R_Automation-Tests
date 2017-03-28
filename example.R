set.seed(9327)
# Number of observations
observationCount <- 100

# Value set, eg: Frequency, integers from 1 to 60
f <- seq(1:60)

# Random sample from the data set above
freqSample <- sample(f, observationCount, replace = TRUE, prob = dweibull(f, 1, 5))

#Frequency table (first line is the value set, second is the frequencies)
table(freqSample)

#Figure of frequencies
plot(table(freqSample))

#density
plot(density(freqSample, from=1))

#view as data frame
View(as.data.frame(freqSample[order(freqSample)]))

#Quantiles, percentiles

#Vector of percentiles
probs <- c(0, 0.50, 0.95, 1.0)

#calculated values, based on percentiles
breaks <- quantile( freqSample, probs=probs)

#plot - add lines
for (i in 1:length(breaks) ) {
  abline(v=breaks[i],lwd=1, col="blue")
}

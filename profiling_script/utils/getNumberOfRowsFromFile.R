getNumberOfRowsFromFile <- function( filename ){
  if(.Platform$OS.type=="windows"){
    system.time({
      cmd<-system(paste("/RTools/bin/wc -l \"",filename, "\"",sep=""), intern=TRUE)
      cmd<-strsplit(cmd, " ")[[1]][1]
    })
    return(as.numeric(cmd) + 1)
  } else {
    system.time({
      cmd<-system(paste("wc -l \"",filename,"\" | awk \'{print $1}\'", sep=""), intern=TRUE)
      cmd<-strsplit(cmd, " ")[[1]][1]
    })
    return(as.numeric(cmd) + 1)
  }
}

remove_installed_custom_packages <- function () {
  ip <- installed.packages() 
  pkgs.to.remove <- ip[!(ip[,"Priority"] %in% c("base", "recommended")), 1]
  sapply(pkgs.to.remove, remove.packages)#, lib=.libPaths()) 
}

load_and_install_package <- function (package, repository = "http://cran.us.r-project.org") {
  if (package %in% rownames(installed.packages()) == FALSE) {
    print(paste("Installing",package, "pacgage"))
    install.packages(package,repos=repository)
  }
  eval(parse(text=paste("suppressPackageStartupMessages(library(", package, "))", sep="")))
}
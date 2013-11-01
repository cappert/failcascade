if(!is.element('forecast', installed.packages()[,1])){
  install.packages("Rcpp", repos='http://cran.r-project.org', dependencies = TRUE)
  install.packages("forecast", repos='http://cran.r-project.org', dependencies = TRUE)
}

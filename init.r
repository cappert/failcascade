if(!is.element('forecast', installed.packages()[,1])){
  install.packages("http://cran.r-project.org/src/contrib/Archive/Rcpp/Rcpp_0.9.12.tar.gz", contriburl=NULL, type="source")
  install.packages("forecast", repos='http://cran.r-project.org', dependencies = TRUE)
}

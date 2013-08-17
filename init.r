if(!is.element('forecast', installed.packages()[,1])){
  install.packages("forecast", repos='http://cran.r-project.org', dependencies = TRUE)
}

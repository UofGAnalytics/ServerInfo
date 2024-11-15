Args <- commandArgs(trailingOnly = TRUE)
n <- if(length(Args)==0) 100 else as.numeric(Args[1])
x <- rnorm(n)
x <- x^2
save(x, file="~/test_r_dir/rnorm.RData")
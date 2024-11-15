Args <- commandArgs(trailingOnly = TRUE)
n <- if(length(Args)==0) 10 else as.numeric(Args[1])

x <- numeric(n)
for(i in seq(n)){
  message(i)
  x[i] <- rnorm(1)
  Sys.sleep(1)
}

print(x)

message("Complete")
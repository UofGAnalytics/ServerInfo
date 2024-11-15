# This script will be used in a demo of how to use slurm for year-one PhD students. It is just a collection of functions which generate
# some simulated data for a linear regression model. The functions that generate the regression coefficients, design matrix and response
# are introduced, followed by another function which generates all the data. The simulated data are stored in a list, and saved to the 
# current working directory.

# Load in required package package
library(MASS)

generate_beta <- function(p, q, limits = c(-2, 2)){
  
  # This function generates the 'true' parameter vector for a linear regression model. Its arguments are:
  # p - the total number of parameters to be generated
  # q - the number of non-zero parameters
  # limits - the hyperparameters of the uniform distribution which we will draw the non-zero values from
  
  # Initialise the parameter vector as a vector of zeros
  beta <- numeric(p)
  
  # Randomly select q of the p parameters to be non-zero
  significant_betas <- sample(1:p, q)
  
  # Set q of the beta terms equal to a draw from a uniform distribution
  beta[significant_betas] <- runif(q, min = limits[1], max = limits[2])
  
  # The function returns the 'true' simulated parameter vector
  return(beta)
}

generate_X <- function(n, p){
  
  # This function generates the design matrix as independent standard Normal random variables. Its arguments are:
  # n - number of observations
  # p - number of variables
  
  # Generate design matrix as standard Normal random variables
  X <- matrix(data = rnorm(n * p), nrow = n, ncol = p)
  
  # The function returns the simulated design matrix
  return(X)
}

generate_data <- function(n = 20, p = 5, q = 2, sigma2 = 1, limits = c(-2, 2)){
  
  # This function simulates the data to be used in the np-splitting algorithm. It's arguments are:
  # n - number of observations
  # p - number of covariates
  # q - the number of important covariates
  # sigma2 - the residual variance
  
  # Generate regression coefficients
  beta <- generate_beta(p, q, limits)
  
  # Generate design matrix
  X <- generate_X(n, p)
  
  # Generate response
  y <- rnorm(n, mean = X %*% beta, sd = sqrt(sigma2))
  
  # The function returns a list with the following elements:
  # y - the full simulated y
  # X - the full simulated design matrix
  # beta - the vector of true regression coefficients
  
  return(list("y" = y, "X" = X, "beta" = beta))
  
}

# Generate some data
simulated_data <- generate_data()

# Write the results to a .csv file in the current working directory
write.csv(simulated_data, "simulated_data.csv")

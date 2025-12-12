## Chat conversion of the python code

# Set up output file
file <- "results_r.csv"

# Function to generate random uppercase name of length 6
random_name <- function() {
  paste0(sample(LETTERS, 6, replace = TRUE), collapse = "")
}

# Generate data
names <- replicate(100, random_name())
values <- runif(100)

# Create a data frame
df <- data.frame(Name = names, Value = values)

# Write to CSV
write.csv(df, file, row.names = FALSE)


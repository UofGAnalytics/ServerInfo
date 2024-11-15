# Load necessary libraries
library(ggplot2)
library(caret)
library(e1071)  # For logistic regression model compatibility with caret
library(dplyr)

# Load the iris dataset
data(iris)

# Perform PCA to reduce data to 2D for visualization
pca_model <- prcomp(iris[, 1:4], center = TRUE, scale. = TRUE)
iris_pca <- as.data.frame(pca_model$x[, 1:2])  # Take first 2 principal components
iris_pca$Species <- iris$Species

# Split the data into training and test sets (70/30 split)
set.seed(42)
train_indices <- createDataPartition(iris_pca$Species, p = 0.7, list = FALSE)
train_data <- iris_pca[train_indices, ]
test_data <- iris_pca[-train_indices, ]

# Train a logistic regression model using caret
model <- train(Species ~ ., data = train_data, method = "multinom")

# Predict classifications for the test set
test_data$Predicted <- predict(model, newdata = test_data)

# Create a grid for decision boundary visualization
x_min <- min(iris_pca$PC1) - 1
x_max <- max(iris_pca$PC1) + 1
y_min <- min(iris_pca$PC2) - 1
y_max <- max(iris_pca$PC2) + 1
grid <- expand.grid(PC1 = seq(x_min, x_max, length.out = 200),
                    PC2 = seq(y_min, y_max, length.out = 200))

# Predict classifications for the entire grid
grid$Species <- predict(model, newdata = grid)

# Plot the decision boundaries and the actual data points
plot <- ggplot() +
  geom_tile(data = grid, aes(x = PC1, y = PC2, fill = Species), alpha = 0.3) +
  geom_point(data = iris_pca, aes(x = PC1, y = PC2, color = Species), size = 3) +
  labs(title = "Logistic Regression on Iris Dataset (2D PCA)",
       x = "Principal Component 1", y = "Principal Component 2") +
  theme_minimal() +
  scale_fill_manual(values = c("setosa" = "#FF9999", "versicolor" = "#99CC99", "virginica" = "#9999FF")) +
  scale_color_manual(values = c("setosa" = "#FF5555", "versicolor" = "#55AA55", "virginica" = "#5555AA"))

# Save the plot to disk
ggsave("iris_classification.png", plot, width = 10, height = 6)

# Show the plot
print(plot)


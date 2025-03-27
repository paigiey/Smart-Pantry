Smart Pantry
Smart Pantry is an interactive R Shiny application designed to reduce food waste by helping users discover recipes based on the ingredients they already have at home. By combining ingredient-based filtering, nutritional data, and dynamic visualization, this app provides an intuitive and practical tool for home cooks.

Project Highlights
Developed a user-friendly recipe recommendation engine using R Shiny.
Enables users to filter recipes by available ingredients, cooking time, and difficulty level.
Provides full recipe details, including instructions, estimated calories, and ingredient quantities.
Incorporates interactive visuals to show match quality and calorie breakdowns.
Designed with a clean, mobile-friendly UI for accessibility across devices.

Core Features
Ingredient-Based Recipe Search
Users input available ingredients from their pantry or fridge.
Option to exclude unwanted ingredients.
Results filtered into exact matches and partial matches (requiring a few additional ingredients).

Detailed Recipe Information
Each recipe result includes:
Step-by-step instructions
Cooking time and difficulty
Ingredient quantities
Estimated calorie count

Smart Filtering
Filter recipes by:
Maximum cooking time
Difficulty level (Easy, Medium, Hard)
Dietary preferences or ingredients to avoid

Visual Analytics
Pie chart visualizes how many recipes are exact vs. partial matches.
Bar chart displays the number of recipes by calorie range.

Technologies & Libraries
R + R Shiny
readxl, dplyr, ggplot2, purrr, stringr, scales
shinythemes for responsive theming
Data sourced from a custom Excel recipe database

Methodology
Data Preparation:
Imported recipe data from an Excel file using readxl.
Parsed and cleaned ingredient fields into structured lists.
Converted cooking time and difficulty into filterable fields.

User Input Logic:
Users specify ingredients they have and those to avoid.
Recipes scored based on ingredient matches and exclusions.

Categorized into:
All-match: All ingredients present
Partial-match: Some ingredients present, rest need shopping

Visual Output:
Pie chart to show exact vs. partial match proportions.
Bar chart to show calorie distribution across returned recipes.

Impact:
Encourages smarter, more sustainable cooking habits.
Helps users avoid unnecessary grocery trips and reduce food waste.
Makes meal planning more efficient, especially for budget-conscious or eco-minded users.

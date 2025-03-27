library(shiny)
library(readxl)
library(dplyr)
library(stringr)
library(purrr)
library(ggplot2)
library(scales)

# Load recipe data
recipes <- read_excel("updated_recipes.xlsx") %>%
  mutate(Ingredients = str_split(Ingredients, ",\\s*"),
         Difficulty = factor(Difficulty, levels = c("Easy", "Medium", "Hard")),
         Cooking_Time = as.numeric(Time)) 

# Extract unique ingredients while preserving original case
all_ingredients <- sort(unique(unlist(recipes$Ingredients)))
all_difficulty_levels <- levels(recipes$Difficulty)

# Define UI
ui <- fluidPage(
  theme = shinythemes::shinytheme("sandstone"),
  titlePanel("Recipe Finder"),
  sidebarLayout(
    sidebarPanel(
      helpText(
        "With this recipe finder, you can prevent food waste",
        "and become a more creative home cook.",
        "Just tell us what ingredients you already have in your kitchen,",
        "how much time you have, and your preferred difficulty level,",
        "and we will recommend delicious recipes."
      ),
      h3("What do you have in your fridge or pantry?"),
      selectInput("yes_ingredients", "I have:", choices = all_ingredients, selected = c("Salt", "Pepper", "Olive Oil"), multiple = TRUE),
      selectInput("no_ingredients", "Avoid these:", choices = all_ingredients, multiple = TRUE),
      sliderInput("max_time", "Max Cooking Time (minutes):", min = 5, max = 60, value = 30, step = 5),
      selectInput("difficulty", "Select Difficulty:", choices = c("All", all_difficulty_levels)),
      actionButton("find", "Find Recipes")
    ),
    mainPanel(
      plotOutput("recipe_pie_chart"),
      plotOutput("calorie_distribution_plot"),
      h4("You have all of the ingredients to make these recipes:"),
      tableOutput("all_match"),
      h4("You have some ingredients but you need to do some shopping:"),
      tableOutput("partial_match"),
    )
  )
)

# Define Server
server <- function(input, output, session) {
  observeEvent(input$find, {
    
    # Ingredients the user has (reactively trimmed)
    selected_ingredients <- reactive({ trimws(input$yes_ingredients) })
    
    # Ingredients the user doesn't want
    excluded_ingredients <- reactive({ trimws(input$no_ingredients) })
    max_time <- input$max_time
    difficulty <- input$difficulty
    
    print(paste("Selected ingredients:", paste(selected_ingredients(), collapse = ", ")))
    print(paste("Excluded ingredients:", paste(excluded_ingredients(), collapse = ", ")))
    print(paste("Max cooking time:", max_time))
    print(paste("Difficulty level:", difficulty))
    
    # If no ingredients are specified, exit early.
    if (length(selected_ingredients()) == 0 && length(excluded_ingredients()) == 0) return()
    
    # Count matching and excluded ingredients for each recipe
    filtered_recipes <- recipes %>%
      mutate(
        match_count = map_int(Ingredients, ~ sum(setdiff(selected_ingredients(), c("Salt", "Pepper", "Olive Oil")) %in% .x)), 
        exclude_count = map_int(Ingredients, ~ sum(excluded_ingredients() %in% .x))
      ) %>%
      filter(Cooking_Time <= max_time)
    
    # Filter by difficulty if specified
    if (difficulty != "All") {
      filtered_recipes <- filtered_recipes %>% filter(Difficulty == difficulty)
    }
    
    # Filter recipes based on ingredient match and exclusion criteria
    all_match <- filtered_recipes %>% 
      filter(map_lgl(Ingredients, ~ all(.x %in% selected_ingredients())) & exclude_count == 0)
    
    partial_match <- filtered_recipes %>% 
      filter(match_count >= 1 & match_count <= length(setdiff(selected_ingredients(), c("Salt", "Pepper", "Olive Oil"))) 
             & exclude_count == 0 & !Recipe %in% all_match$Recipe)
    
    output$all_match <- renderTable({
      all_match %>%
        mutate(Ingredients = sapply(Ingredients, function(x) paste(x, collapse = ", "))) %>%
        arrange(Recipe) %>%
        select(Recipe, "Ingredients and Amounts" = Amount, Instructions, Time = Cooking_Time, Difficulty, Calories)
    }, rownames = FALSE)
    
    output$partial_match <- renderTable({
      partial_match %>%
        mutate(Ingredients = sapply(Ingredients, function(x) paste(x, collapse = ", "))) %>%
        arrange(Recipe) %>%
        select(Recipe, "Ingredients and Amounts" = Amount, Instructions, Time = Cooking_Time, Difficulty, Calories)
    }, rownames = FALSE)
    
    output$recipe_pie_chart <- renderPlot({
      counts <- c(nrow(all_match), nrow(partial_match))
      labels <- c("Exact Match", "Needs Shopping")
      
      df <- data.frame(Category = labels, Count = counts)
      
      ggplot(df, aes(x = "", y = Count, fill = Category)) +
        geom_bar(stat = "identity", width = 1) +
        coord_polar(theta = "y") +
        scale_fill_manual(values = c("#A3D9B1", "#4D9F64")) +
        labs(title = "Recipe Match Overview", fill = "Category") +
        theme_void() +
        geom_text(aes(label = Count), position = position_stack(vjust = 0.5), size = 6, color = "black") +
        theme(legend.text = element_text(size = 14)) 
    })
    output$calorie_distribution_plot <- renderPlot({
      # Combine all matched and partially matched recipes
      filtered_data <- bind_rows(all_match, partial_match)
      
      if (nrow(filtered_data) == 0) {
        ggplot() + 
          annotate("text", x = 1, y = 1, label = "No recipes match your criteria", size = 6, hjust = 0.5) +
          theme_void()
      } else {
        filtered_data %>%
          mutate(Calorie_Range = case_when(
            Calories < 351 ~ "<350",
            Calories <= 600 ~ "350-600",
            TRUE ~ ">600"
          )) %>%
          mutate(Calorie_Range = factor(Calorie_Range, levels = c("<350", "350-600", ">600"))) %>%
          group_by(Calorie_Range) %>%
          summarise(Count = n(), .groups = "drop") %>%
          ggplot(aes(x = Calorie_Range, y = Count, fill = Calorie_Range)) +
          geom_col(show.legend = FALSE) +
          labs(
            title = "Number of Recipes by Calorie Range",
            x = "Calorie Range",
            y = "Count of Recipes"
          ) +
          scale_fill_manual(values = c("<350" = "#A3D9B1", "350-600" = "#4D9F64", ">600" = "#2B5930")) +
          theme_minimal(base_size = 14)
      }
    })
  })
}

# Run the app
shinyApp(ui, server)
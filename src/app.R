library(shiny)
library(bslib)

library(plotly)
library(ggplot2)
library(tidyverse)
library(lubridate)

options(shiny.autoreload = TRUE)
#data
data <- read_csv("../data/raw/goodreads_export.csv") |> 
  mutate(date_added = year(as.Date(date_added, format = "%Y/%m/%d")),
         date_read = year(as.Date(date_read, format = "%Y/%m/%d"))
         ) |> 
  select(title, author, date_read, date_added, exclusive_self, my_rating, average_rating, number_of_pages, genre)
print(paste(nrow(data)))

#ui
ui <- fluidPage(
  titlePanel(
    tags$h1("Goodreads Data Explorer", style="font-weight: bold; color: grey73")
    ),
  sidebarLayout(
    sidebarPanel(
      width=3,
      sliderInput("year", "Select Year:", min = 2013, max = 2025, value = c(2021, 2024), step=1, sep = ""),
      
      radioButtons(
        "shelf",
        "Select Bookshelf:",
        choices = list("Read" = 1, "To-Read" = 2, "Both" = 3),
        selected = 3
      )
      
    ),
  mainPanel(
      fluidRow(
        column(5, 
               fluidRow(
                 div(class = "card", 
                     style = "background-color: #E6E6FA; padding: 10px; border-radius: 3px;font-size: 52px; color:  #551A8B", 
                     h3("Number of Books Read", class = "card-title"),
                     textOutput(outputId = "num_read")
                 )
               ),
               br(),
               fluidRow(
                 div(class = "card", 
                     style = "background-color: #E6E6FA; padding: 10px; border-radius: 3px;font-size: 52px; color:  #551A8B", 
                     h3("Number of Books Shelved", class = "card-title"),
                     textOutput(outputId = "num_added")
                 )
               ),
               br(),
               fluidRow(
                 div(class = "card", 
                     style = "background-color: #E6E6FA; padding: 10px; border-radius: 3px;font-size: 52px; color: #551A8B", 
                     h3("Total Pages Read", class = "card-title"),
                     textOutput(outputId = "total_pages")
                 )
               )
    
        ),
        column(7, 
               div(class = "card", 
                   style = "background-color: #f8f9fa; padding: 10px; border-radius: 3px;", 
                   style = "font-size: 28px;", 
                   h3("My ratings compared to average Goodreads rating", class = "card-title"),
                   plotOutput(outputId = "rating_plot")
               )
        )
      ),
      br(),
      fluidRow(
        column(12, 
               div(class = "card", 
                   style = "background-color: #f8f9fa; padding: 20px; border-radius: 3px;", 
                   h3("Genre preferences", class = "card-title"),
                   plotOutput(outputId="genre_plot")
               )
        )
      )
    )
  )
)

#server
server <- function(input, output, session) {

  all_books <- reactive({
    filtered_data <- data |> 
      filter(date_added >= input$year[1] & date_added <= input$year[2])
    filtered_data
  })
  
  read_books <- reactive({
    filtered_data <- all_books() |> 
      filter(exclusive_self == 'read' & date_read >= input$year[1] & date_read <= input$year[2])
    filtered_data
  })
  
  to_read_books <- reactive({
    filtered_data <- all_books() |> 
      filter(exclusive_self == 'to-read')
    filtered_data
  })
  
  
  output$genre_plot <- renderPlot({
    if(input$shelf==3){
      plot_data <- all_books()
    } else if (input$shelf==1){
      plot_data <- read_books()
    } else {
      plot_data <- to_read_books()
    }
    
    plot_data |> 
      add_count(genre) |> 
      ggplot(aes(y=reorder(genre, -n))) +
      geom_bar(color="orchid4", fill="orchid") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(size = 14),  
        axis.text.y = element_text(size = 16), 
        axis.title.x = element_text(size = 14), 
        axis.title.y = element_blank()
      ) +
      labs(
        x = "Count"
      )
  })
  
  output$num_read <- renderText({
    nrow(read_books())
  })
  
  output$num_added <- renderText({
    nrow(to_read_books())
  })
  
  output$total_pages <- renderText({
    format(sum(read_books()$number_of_pages, na.rm = TRUE), big.mark=",")
  })
  
  output$rating_plot <- renderPlot({
    my_rating_data <- read_books() |> 
      group_by(date_read) |> 
      summarise(my_avg_rating = mean(my_rating, na.rm=TRUE),
                user_avg_rating = mean(average_rating, na.rm=TRUE))
    
    ggplot(my_rating_data, aes(x = date_read)) +
      geom_line(aes(y = my_avg_rating, color = "My Rating"), size = 2) +
      geom_point(aes(y = my_avg_rating, color = "My Rating"), size = 4, shape = 21, fill = "turquoise4") +
      geom_line(aes(y = user_avg_rating, color = "Goodreads rating"), size = 2) +
      geom_point(aes(y = user_avg_rating, color = "Goodreads rating"), size = 4, shape = 21, fill = "indianred4") + 
      labs(x = "Year read", y = "Average Rating") +
      scale_y_continuous(limits = c(1, 5)) +
      scale_color_manual(values = c("My Rating" = "turquoise4", "Goodreads rating" = "indianred4")) +  # Custom colors for the legend
      theme_minimal() +
      theme(
        axis.text.x = element_text(size = 14),  
        axis.text.y = element_text(size = 14), 
        axis.title.x = element_text(size = 14), 
        axis.title.y = element_text(size = 14),
        legend.title = element_blank(),
        legend.text = element_text(size = 12)
      ) 
  })
}

shinyApp(ui, server)


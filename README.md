# Goodreads Reading Data Explorer

## Motivation
Target audience: any Goodreads user

As an avid reader, I am always curious to know more about my reading habits and preferences. I wanted to explore patterns in my reading history, such as the genres I tend to gravitate toward, the number of books I’ve read versus those I’ve shelved, and how my ratings compare to the broader Goodreads community. This dashboard uses my Goodreads account. As any user can export their own data, this dashbaord can be further developed to surve as a 'plug-in' visualization app.

## App Description

App demo can be found here {INSERT LINK}

## Instalation Instruction

1. Clone the repository:  

   ```shell
   git clone git@github.ubc.ca:mds-2024-25/DSCI_532_individual-assignment_dariakh.git
   ```  

2. Open RStudio (if not installed on your device please go to <https://posit.co/downloads/>) and navigate to the project's root directory.

3. Install required packages by running the following commands in your RStudio console:

   ```R
   install.packages("renv") # omit if renv is already installed on your devide
   renv::activate()
   ```

4. In console type `shiny::runApp()` or open `app.R` file and hit "Run App" button at the top right

5. This should open the app in your browser automatically. If not paste http://127.0.0.1:4166 into your browser.

6. When done, don't forget to quit the app.

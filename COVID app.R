# ============================ SHINY APP ============================

# Load packages
library("shiny")
library("leaflet")
library("dplyr")
library("rgdal")

# Load in data
Municipalities_df <- read.csv("Municipalities_df.csv")
Municipalities_df$Date <- as.Date(Municipalities_df$Date)
shapefile <- readOGR("Gemeentegrenzen__voorlopig____kustlijn.shp")

# Create list with bins required for the map color palettes
bins <- list("Total_reported" = c(0, 10, 20, 50, 100, 200, 500, 1000, Inf),
             "CasesPer10000" = c(0, 2, 5, 10, 20, 50, 75, Inf),
             "Deceased" = c(0, 2, 5, 10, 20, 50, 100, 200, 500, Inf),
             "DeceasedPer10000" = c(0, 2, 4, 8, 10, 15, 20, 50, Inf),
             "Weekly_casegrowth" = c(-20, 0, 20, 40, 60, 80, 100, 200, 500, Inf)
             )



ui <- fluidPage(
  
  titlePanel("COVID-19 Effects in The Netherlands - Interactive Choropleth Map"),

  
  sidebarLayout(
    
    sidebarPanel(
      tabsetPanel(id= "tabs",
                  
                  tabPanel("Map", id = "Map", 
                           br(), 
                           
                           p("Choose options below to interact with the Map"), 
                           
                           # Initialize drop-down list to select which map to show
                           selectInput("measure", "Select the measure",
                                       choices = list("Total confirmed cases" = "Total_reported",
                                                      "Cases per 10000" = "CasesPer10000",
                                                      "Total deceased" = "Deceased",
                                                      "Deceased per 10000" = "DeceasedPer10000",
                                                      "Weekly change" = "Weekly_casegrowth"),
                                       selected = "Total confirmed cases"),
                           
                           # Initialize slider to specify the date
                           sliderInput("date", "Select the date", min = min(Municipalities_df$Date) , max = max(Municipalities_df$Date), 
                                       value = max(Municipalities_df$Date), step = 1, dragRange= TRUE, animate = animationOptions(interval = 1500))
                          
                  )
      )
    ),
    
    mainPanel(
      
      tabsetPanel(type= "tabs",
                  
                  tabPanel("Interactive Map", leafletOutput(outputId = "map_choropleth", height = "80vh"))

      )
    )
  )
)



server <- function(input, output) {
  
  output$map_choropleth <- renderLeaflet({
    
    pal <- colorBin("YlOrRd", domain = Municipalities_df[,input$measure], bins = bins[[input$measure]])
    
    leaflet(shapefile) %>% 
      addProviderTiles("CartoDB.DarkMatter") %>%                                                                                          # Initialize dark world map
      addPolygons(data = shapefile, weight = 1, smoothFactor = 0.5, color = "grey", fillOpacity = 0.9,                                    # Add polygons corresponding to Dutch municipalities
                  fillColor = pal(Municipalities_df[,input$measure][Municipalities_df$Date == input$date]),                               # Select appropriate measure to fill map colors with
                  popup = Municipalities_df$popup_info[Municipalities_df$Date == input$date],                                             # Enable pop-up text that shows up whenever the user clicks on a municipality
                  highlight = highlightOptions(weight = 2, color = "#555", fillOpacity = 1, bringToFront = TRUE)) %>%                     # Highlight borders of municipality when hovering over it
      addLegend(values = ~Municipalities_df[,input$measure][Municipalities_df$Date == input$date], pal = pal, title = input$measure)      # Add legend
  })

}


shinyApp(ui, server)

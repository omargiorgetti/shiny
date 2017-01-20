library(shinydashboard)
data <- readRDS(file="casualties_2005-14.Rda")
data$date <- as.Date(data$date, "%Y-%m-%d")
data$severity <- factor(data$severity, levels= c("Fatal", "Serious", "Slight"), ordered = TRUE)
data$day <- factor(data$day, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"), ordered=T)
data$hour <- factor(data$hour)
data$light <- ordered(data$light, levels = c("Dark", "Daylight"))
borough_choices <- c("All", levels(data$borough))
mode_choices <- c("All", levels(data$mode))
severity_choices <- c("All", levels(data$severity))
boroughs <-  readOGR("boroughs.geojson", "OGRGeoJSON")

ui <- dashboardPage(
  dashboardHeader(title = "Basic dashboard"),
  dashboardSidebar(),
  dashboardBody(
    # Boxes need to be put in a row (or column)
    fluidRow(
      column(width = 6,
             box(width = NULL,
                 valueBoxOutput("casualtyBox"),
                 valueBoxOutput("KSIBox"),
                 valueBoxOutput("collisionBox"),
                 tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
                 leafletOutput("map"))
      ),
      column(width = 6,
             box(width = NULL, 
                 dateRangeInput("Date range", inputId = "date_range",  
                                start = "2014-01-01",
                                end = "2014-12-31",
                                format = "yyyy-mm-dd"),
                 selectInput("Borough", inputId = "borough",
                             choices = borough_choices,
                             selected = "All", multiple = TRUE),
                 selectInput("Mode of travel", inputId = "mode",
                             choices = mode_choices, 
                             selected = "Pedal Cycle", multiple = TRUE),
                 selectInput("Casualty severity",inputId = "severity",
                             choices = severity_choices, 
                             selected = "All", multiple = TRUE),
                 hr(),
                 tabBox(width = NULL,
                        tabPanel("Boroughs",
                                 h5("Casualties by borough", style = "color:black", align = "center"),
                                 ggvisOutput("borough_count")),
                        tabPanel("Months",
                                 h5("Casualties by month and gender", style = "color:black", align = "center"),
                                 ggvisOutput("timeband_month")),
                        tabPanel("Hours",
                                 h5("Casualties by hour and severity", style = "color:black", align = "center"),
                                 ggvisOutput("timeband_hour")),
                        tabPanel("Demographics",
                                 h5("Casualties by ageband and gender", style = "color:black", align = "center"),
                                 ggvisOutput("ageband_gender")),
                        tabPanel("Data",
                                 DT::dataTableOutput("table")),
                        tabPanel("About", br(),
                                 p("This Shiny application is designed to allow the user to interrogate road casualties reported in Greater London between 2005 and 2014."),
                                 strong("How to use"),
                                 p("The filter panel allows the user to plot reported road casualties by date range, borough, mode of travel and severity onto the map. 
                                   Details of the collision can be obtained by clicking on any of the points. 
                                   Information on the temporal and demographic profile of casualties are provided under the relevant tabs."),
                                 strong("Data sources"),
                                 p("STATS19 collision data for Greater London are available from",
                                   a("Transport for London",
                                     href = "https://www.tfl.gov.uk/corporate/publications-and-reports/road-safety"),
                                   "and a guide to the variables can be found",
                                   a("here.",
                                     href = "https://www.tfl.gov.uk/cdn/static/cms/documents/collision-data-guide.pdf")),
                                 strong("Credits"),
                                 p("The ",
                                   a("leaflet",
                                     href = "https://rstudio.github.io/leaflet/"), ", ",
                                   a("DT",
                                     href = "https://rstudio.github.io/DT/"), " and ",
                                   a("ggvis",
                                     href = "http://ggvis.rstudio.com"), " R packages were used in this ",
                                   a("Shiny",
                                     href = "http://shiny.rstudio.com"), " app. Some of the code for the STATS19_scanner app was adapted from ",
                                   a("Superzip",
                                     href = "http://shiny.rstudio.com/gallery/superzip-example.html"), "by Joe Cheng. The ui was inspired by ",
                                   a("blackspot",
                                     href = "http://blackspot.org.uk"),
                                   " by Ben Moore and ",
                                   a("Twin Cities Buses",
                                     href = "https://gallery.shinyapps.io/086-bus-dashboard/"), " by Aron Atkins."),
                                 strong("Licence"),
                                 p("Contains National Statistics data © Crown copyright and database right [2015] and 
                                   Contains Ordnance Survey data © Crown copyright and database right [2015]."),
                                 br(),
                                 p("Repo here: ",
                                   a(href = "https://github.com/hpartridge/STATS19_scanner", icon("github"), target = "_blank")
                                 ))
                                 ))
  
      )
    )
  )
)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)
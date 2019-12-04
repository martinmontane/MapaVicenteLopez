require(shiny)
require(shinydashboard)
###########################
## @auth: Martin Montane ##
###########################
ui <- dashboardPage(
  dashboardHeader(title = paste0("Mapa interactivo de OSC (",nrow(datos),')')),
  dashboardSidebar(disable=TRUE),
  dashboardBody(print("Hola Mundo")
  )
)

# La segunda parte del código, el server, define
# cómo reaccionar ante eventos del usuario 
server <- function(input, output, session) {
 
}
# Llamada final 
shinyApp(ui = ui, server = server)

require(shiny)
require(shinydashboard)
###########################
## @auth: Martin Montane ##
###########################
ui <- dashboardPage(
  dashboardHeader(title = "Prueba"),
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

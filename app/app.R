###########################
## @auth: Martin Montane ##
###########################

# Carga de librerias
librerias <- c('leaflet','shiny','sf','shinydashboard','shinyWidgets',
               'data.table','gsubfn','dqshiny','shinyjs','magrittr','httpuv')
lapply(librerias, require, character.only=TRUE)

#################################################
## Data wrangling que ya no es necesario hacer ##
## hay que modificarlo cuando se unifique todo ##
## en una sola planilla en junar               ##
#################################################

#   datosSalud <- fread("http://vicentelopez.cloudapi.junar.com/api/v2/datastreams/LISTA-DE-ENTID-22632/data.csv/?auth_key=1cbc9a823e07baae05ab006066a47d4906d8adb9",encoding = 'UTF-8', header=FALSE) %>%
#                 .[,CAT:='Salud']
#   colnames(datosSalud)[1:5] <- c('CATLVL2','Nombre','Direccion','Barrio','ContactoTelefono')
# 
#   datosDiscapacidad <- fread("http://vicentelopez.cloudapi.junar.com/api/v2/datastreams/LISTA-DE-ENTID-94887/data.csv/?auth_key=1cbc9a823e07baae05ab006066a47d4906d8adb9",encoding = 'UTF-8', header=FALSE) %>%
#            .[, CAT:='Discapacidad']
#   colnames(datosDiscapacidad)[1:5] <- c('Nombre','Objetivo','Direccion','Barrio','ContactoTelefono')
#   datosParticipacionSocial <- fread("http://vicentelopez.cloudapi.junar.com/api/v2/datastreams/LISTA-DE-ENTID/data.csv/?auth_key=1cbc9a823e07baae05ab006066a47d4906d8adb9",encoding = 'UTF-8', header=FALSE) %>%
#                               .[,CAT:= 'Participacion Social']
#   colnames(datosParticipacionSocial)[1:5] <- c('CATLVL2','Nombre','Direccion','Barrio','ContactoTelefono')
#   datosAdultosMayores <- fread("http://vicentelopez.cloudapi.junar.com/api/v2/datastreams/LISTA-DE-ENTID-29685/data.csv/?auth_key=1cbc9a823e07baae05ab006066a47d4906d8adb9",encoding = 'UTF-8', header=FALSE) %>%
#                          .[,CAT:= 'Adultos Mayores']
#   colnames(datosAdultosMayores)[1:4] <- c('Nombre','Direccion','Barrio','ContactoTelefono')
# 
#   datosCultoColectividades <- fread("http://vicentelopez.cloudapi.junar.com/api/v2/datastreams/LISTA-DE-ENTID-13756/data.csv/?auth_key=1cbc9a823e07baae05ab006066a47d4906d8adb9",encoding = 'UTF-8', header=FALSE) %>%
#                               .[, CAT:='Culto y Colectividades']
#   colnames(datosCultoColectividades)[1:6] <- c('CATLVL2','Nombre','Direccion','Barrio','ContactoTelefono','ContactoMail')
# 
#   datosCulturaEducacion <- fread("http://vicentelopez.cloudapi.junar.com/api/v2/datastreams/LISTA-DE-ENTID-90402/data.csv/?auth_key=1cbc9a823e07baae05ab006066a47d4906d8adb9",encoding = 'UTF-8', header=FALSE) %>%
#                            .[,CAT:='Cultura y Educacion']
#   colnames(datosCulturaEducacion)[1:5] <- c('CATLVL2','Nombre','Direccion','Barrio','ContactoTelefono')
# 
#   datosDeportesRecreacion <- fread("http://vicentelopez.cloudapi.junar.com/api/v2/datastreams/LISTA-DE-ENTID-58717/data.csv/?auth_key=1cbc9a823e07baae05ab006066a47d4906d8adb9",encoding = 'UTF-8', header=FALSE) %>%
#     .[,CAT:='Deportes y Recreacion']
#   colnames(datosDeportesRecreacion)[1:5] <- c('CATLVL2','Nombre','Direccion','Barrio','ContactoTelefono')
# 
# datos <- rbind(datosAdultosMayores,datosCultoColectividades,datosCulturaEducacion,datosDeportesRecreacion,
#                datosDiscapacidad,datosParticipacionSocial,datosSalud, fill=TRUE)
# datos$Direccion <- ifelse(datos$Direccion %in% 'Rivadavia 2350', 'Bernardino Rivadavia 2350',datos$Direccion)
# 
# require(ggmap)
# latlong <- geocode(paste0(datos$Direccion,', ',datos$Barrio,
#                ", Vicente López, ",
#                "Argentina"))
# datos$lon <- latlong$lon
# datos$lat <- latlong$lat
# write.table(datos,'datosGeolocalizados.csv',sep=';',row.names=FALSE)

# Carga de funciones auxiliares
source('auxiliares.R')
# Carga de datos con data wrangling hecho
datos <- fread('datosGeolocalizados.csv',encoding = 'UTF-8')
# Definición de íconos. Puede o no hacerse una función,
# para mí es bastante claro y es agregarle ruido a a la función
# awesomeIconList que está bastante bien documentada
VLIcons <- awesomeIconList(
  Discapacidad = makeAwesomeIcon(icon = 'fa-wheelchair',library = 'fa',markerColor = 'white',iconColor = 'black'),
  Salud = makeAwesomeIcon(icon = 'ios-medkit',library = 'ion',markerColor = 'white',iconColor = 'black'),
  `Participacion Social` = makeAwesomeIcon(icon = 'ios-people',library = 'ion',markerColor = 'white',iconColor = 'black'),
  `Culto y Colectividades` = makeAwesomeIcon(icon = 'fa-globe',library = 'fa',markerColor = 'white',iconColor = 'black'),
  `Deportes y Recreacion` = makeAwesomeIcon(icon = 'futbol-o',library = 'fa',markerColor = 'white',iconColor = 'black'),
  `Cultura y Educacion` = makeAwesomeIcon(icon = 'fa-graduation-cap',library = 'fa',markerColor = 'white',iconColor = 'black'),
  `Adultos Mayores` = makeAwesomeIcon(icon = 'fa-blind',library = 'fa',markerColor = 'white',iconColor = 'black')
)
# Convierte al Data Table a un objeto sf
datos <- st_as_sf(datos,coords = c('lon','lat'))
# Extra data wrangling
datos$ContactoMail <- ifelse(datos$ContactoMail =='',NA,datos$ContactoMail)
datos$ContactoTelefono <- ifelse(datos$ContactoTelefono =='',NA,datos$ContactoTelefono)
# Crea los popups que se van a ver en el mapa
datos$popup <- createPopups(data = datos,
                            nombre = 'Nombre',
                            tematica = 'CAT',
                            direccion = paste(datos$Direccion,',',datos$Barrio,',Vicente Lopez', sep=''),
                            contactoTel = "ContactoTelefono",
                            contactoMail = "ContactoMail",
                            addWhatsapp = TRUE,
                            captionWhatsapp = "Lo encontré en el Mapa de Organizaciones Sociales de Vicente López")
# Código de ui
ui <- dashboardPage(
  # tags$meta('<meta name="viewport" content="width=device-width, initial-scale=1">'),
  dashboardHeader(title = "Mapa interactivo de OSC"),
  dashboardSidebar(disable=TRUE),
  dashboardBody(
    shinyjs::useShinyjs(),
    includeCSS(path = "Styles/styles2.css"),
    includeCSS(path ="https://fonts.googleapis.com/css?family=Montserrat:400"),
    shiny::includeScript("gomap.js"),
    useSweetAlert(),
    fluidRow(
      column(3,box("",width='100%',
                   autocomplete_input(id = "SeleccionEntidad",
                                      label =  "Buscá por el nombre",
                                      options =  unique(datos$Nombre),
                                      max_options = 1000),
                   pickerInput(
                     inputId = "FiltroBarrios",
                     label = "Filtrar por barrios",
                     choices = (unique(datos$Barrio)),
                     selected = (unique(datos$Barrio)),
                     options = list(
                       size = 5,
                       `actions-box` = TRUE,
                       `select-all-text` = 'Todos',
                       `none-selected-text` = 'Seleccioná al menos uno',
                       `deselect-all-text` = 'Ninguno'),
                     multiple=TRUE
                   ),
                   pickerInput(
                     inputId = "FiltroTematico",
                     label = "Filtrar por temas",
                     choices = unique(datos$CAT),
                     multiple = TRUE,
                     selected = unique(datos$CAT),
                     options = list(
                       size = 5,
                       `actions-box` = TRUE,
                       `select-all-text` = 'Todos',
                       `none-selected-text` = 'Seleccioná al menos uno',
                       `deselect-all-text` = 'Ninguno')
                   ),
                   HTML("<center>"),
                   actionBttn(
                     inputId = "NearMe",
                     label = "Cerca mío",
                     style = "bordered",
                     color = "success",
                     icon = icon(lib = "glyphicon",name = "record")
                   ),
                   HTML("</center>")
      )),
      column(9,leafletOutput("map",height = '100vh')))
  )
)

# Código de server
server <- function(input, output, session) {
  
  inputs_change<-reactive({
    list(input$FiltroBarrios,input$FiltroTematico)
  }) %>% debounce(2000)
  
  
  output$map <- renderLeaflet({
    if(length(inputs_change()[[1]])==0 | length(inputs_change()[[2]])==0) {
      leaflet(data = datos) %>%
        addProviderTiles("CartoDB.Positron",
                         options = providerTileOptions(minZoom = 10, maxZoom = 20)) %>%
      setMaxBounds( lng1 = -(58.5503+0.1)
                    , lat1 = -(34.55554+0.1)
                    , lng2 = -(58.46877-0.1)
                    , lat2 = -(34.49391-0.1 )) %>%
        setView(lng = -58.5,lat = -34.52,zoom = 13)
    } else {
      leaflet(data = datos[datos$Barrio %in% inputs_change()[[1]] & 
                             datos$CAT %in% inputs_change()[[2]],]) %>%
        addProviderTiles("CartoDB.Positron",
                         options = providerTileOptions(minZoom = 10, maxZoom = 20)) %>%
        addAwesomeMarkers(clusterOptions = markerClusterOptions(),
                          popup = ~popup,icon = ~VLIcons[CAT],label = ~Nombre) %>%
        setMaxBounds( lng1 = -(58.5503+0.1)
                      , lat1 = -(34.55554+0.1)
                      , lng2 = -(58.46877-0.1)
                      , lat2 = -(34.49391-0.1 ))
    }
    
  })
  
  observeEvent(input$SeleccionEntidad,{
    if(input$SeleccionEntidad=="") {
      
    } else {
      lng <- (datos[datos$Nombre %in% input$SeleccionEntidad,] %>%
                st_geometry() %>% unlist(.))[1]
      lat <-  (datos[datos$Nombre %in% input$SeleccionEntidad,] %>%
                 st_geometry() %>% unlist(.))[2]
      popupUnico <- datos[datos$Nombre %in% input$SeleccionEntidad,'popup'] %>% unlist() %>% .[1] %>% unname()
      leafletProxy("map") %>%
        setView(lng = lng,lat = lat,zoom = 20) %>%
        addPopups(lng = lng, lat = lat,popup=popupUnico) %>%
        setMaxBounds( lng1 = -(58.5503+0.1)
                      , lat1 = -(34.55554+0.1)
                      , lng2 = -(58.46877-0.1)
                      , lat2 = -(34.49391-0.1 ))
    }                 
  })
  
  observeEvent(input$NearMe,{
    if(!is.null(input$geolocation)){
      leafletProxy("map") %>%
        setView(lng = input$long,
                lat = input$lat,
                zoom = 20)  %>%
        setMaxBounds( lng1 = -(58.5503+0.1)
                      , lat1 = -(34.55554+0.1)
                      , lng2 = -(58.46877-0.1)
                      , lat2 = -(34.49391-0.1 ))
    } else {
      sendSweetAlert(
        session = session,
        title = "Error",
        text = "Para usar esta función tenés que habilitar la opción de compartir tu ubicación",
        type = "error"
      )
    }
  })
}
shinyApp(ui = ui, server = server)
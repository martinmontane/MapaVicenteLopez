  ###########################
  ## @auth: Martin Montane ##
  ###########################
  
  # Carga de librerias
  librerias <- c('leaflet','shiny','sf','shinydashboard','shinyWidgets',
                 'data.table','gsubfn','dqshiny','shinyjs','httpuv')
  lapply(librerias, require, character.only=TRUE)
  
  # Carga de funciones auxiliares
  source('auxiliares.R')
  
  # Carga de datos.
  # El código espera que sea un dataset con las siguientes variables:
  # Nombre: el nombre con el que se presenta a la organización
  # Direccion: dirección (única) donde se encuentra la organización
  # Barrio: unidad geográfica mínima donde se ubica la organización,
  # podría ser barrio o culquier otra medida (por ejemplo, comuna).
  # ContactoTelefono: numero de teléfono para ser contactado
  # Categoria: Categoría según se organizan las instituciones. Esta pensado
  # para que cada una de tenga solo una categoría
  # ContactoMail: mail de contacto
  # Descricipcion: Breve párrafo sobre las actividades que realiza
  # lon: longitud de la coordenada donde se ubica (WGS84)
  # lat: latitud de la coordenada donde se ubica (WGS84)
  datos <- fread('http://vicentelopezdevo.cloudapi.junar.com/api/v2/datastreams/TEST-ENTID/data.csv/?auth_key=f20f529b8190a209f7d8da7987344ce8a5676c7a',
                 encoding = 'UTF-8')
  # Si existen oboservaciones que están vacías, pero son textos, hay que
  # convertirlo
  # Data Wrangling específico para contactos
  datos <- as.data.table(lapply(datos, function(x) ifelse(x=='', NA, x)))
  
 # Definición de íconos.
  # awesomeIconList es una función que nos permite unir a las categorias de las variables
  # con un ícono particular de las librerias de font awesome o ion icons.
  # Por default, los nombres de la lista hacen referencia a las
  # categorías de la variable Categoria
  VLIcons <- awesomeIconList(
    Discapacidad = makeAwesomeIcon(icon = 'fa-wheelchair',library = 'fa',markerColor = 'white',iconColor = 'black'),
    Salud = makeAwesomeIcon(icon = 'ios-medkit',library = 'ion',markerColor = 'white',iconColor = 'black'),
    `Participacion Social` = makeAwesomeIcon(icon = 'ios-people',library = 'ion',markerColor = 'white',iconColor = 'black'),
    `Culto y Colectividades` = makeAwesomeIcon(icon = 'fa-globe',library = 'fa',markerColor = 'white',iconColor = 'black'),
    `Deportes y Recreacion` = makeAwesomeIcon(icon = 'futbol-o',library = 'fa',markerColor = 'white',iconColor = 'black'),
    `Cultura y Educacion` = makeAwesomeIcon(icon = 'fa-graduation-cap',library = 'fa',markerColor = 'white',iconColor = 'black'),
    `Adultos Mayores` = makeAwesomeIcon(icon = 'fa-blind',library = 'fa',markerColor = 'white',iconColor = 'black')
  )
  # Convierte al Data Table a un objeto sf. 
  # Asume que las columnas correspondientes a las coordenadas son lon y lat
  # en el sistema de coordenada de referencia WGS84
  datos <- st_as_sf(datos,coords = c('lon','lat'))
  
  # Crea los popups que se van a ver en el mapa.
  
  # Se basan en una función "createPopups", disponible en el archivo auxiliares.R
  # Algunos parámetros, tales como nombre, tematica, contactoTel y contactoMail
  # solo piden el nombre de la columna. Esto es así porque son campos que
  # en general no necesitan formateo especial para aparecer en el popup.
  # direccion, captionWhatsapp y descripcion deben agregarse
  # vectores con algún tipo de formato para luego mostrarse correctamente en la aplicacion
  # finalmente, addWhatsapp es un parámetro que puede tomar valor
  # TRUE o FALSE y que nos pregunta si queremos agregar la funcionalidad
  # de conectividad para compartir una organización por whatsapp. En caso
  # de poner TRUE, debemos enviar un texto al parámetro captionWhatsapp
  # para que aparezca alguna información específica y genérica al 
  # compartir cualquiera de las organizaciones.
  
  datos$popup <- createPopups(data = datos,
                              nombre = 'Nombre',
                              tematica = 'Categoria',
                              direccion = paste(datos$Direccion,',',datos$Barrio,',Vicente Lopez', sep=''),
                              contactoTel = "ContactoTelefono",
                              contactoMail = "ContactoMail",
                              addWhatsapp = TRUE,
                              captionWhatsapp = "Lo encontré en el Mapa de Organizaciones Sociales de Vicente López",
                              descripcion = datos$Descripcion)
  # Las aplicaciones de shiny tienen dos partes. UI define 
  # cómo se verá la página: qué elementos tendrá, qué estilo, entre otros
  # parámetros. 
  ui <- dashboardPage(
    dashboardHeader(title = paste0("Mapa interactivo de OSC (",nrow(datos),')')),
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
                       choices = unique(datos$Categoria),
                       multiple = TRUE,
                       selected = unique(datos$Categoria),
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
  
  # La segunda parte del código, el server, define
  # cómo reaccionar ante eventos del usuario 
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
                               datos$Categoria %in% inputs_change()[[2]],]) %>%
          addProviderTiles("CartoDB.Positron",
                           options = providerTileOptions(minZoom = 10, maxZoom = 20)) %>%
          addAwesomeMarkers(clusterOptions = markerClusterOptions(),
                            popup = ~popup,icon = ~VLIcons[Categoria],label = ~Nombre) %>%
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
          setView(lng = lng,lat = lat,zoom = 16) %>%
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
                  zoom = 16)  %>%
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
  # Llamada final 
  shinyApp(ui = ui, server = server)

createPopups <- function(data,addWhatsapp =TRUE,nombre,tematica,direccion,contactoTel,contactoMail,captionWhatsapp) {
  # data$geometry <- NULL
  # data <- data.frame(lapply(data, function(x) unicodeConversion(x)),stringsAsFactors = FALSE)
  # captionWhatsapp <- unicodeConversion(captionWhatsapp)
  # direccion <- unicodeConversion(direccion)
  inicioPopup <- "<div class='leaflet-popup-scrolled' style='height:50vh'>"
  nombrePopup <- paste("<b><h3>",data[[nombre]],"</h3></b>", sep='')
  tematicaPopup <- paste("<b>Tem\u00e1tica:</b>",data[[tematica]], sep='')
  queHacemosPopup <- "<h4>\u00bfQu\u00e9 hacemos?</h4> \u00bfPODRIAMOS CONTAR CON UNA MINI BIO DE QU\u00e9 ES LO QUE HACEN?<br>"
  contactoPopup <- "<h4>\u00bfC\u00f3mo pod\u00e9s contactarte?:</h4>"
  contactoTelefonoPopup <- paste("<i class='fa fa-phone' aria-hidden='true'></i>",data[[contactoTel]], sep = "")
  contactoMailPopup <- paste("<i class='fa fa-envelope-open' aria-hidden='true'></i>",data[[contactoMail]], sep ="")
  direccionPopup <- paste("<i class='fas fa-map-marker-alt' aria-hidden='true'></i>",direccion, sep ="")
  finalPopup <- "</div>"
popups<-  ifelse(!is.na(data[[contactoTel]]) & !is.na(data[[contactoMail]]),
    paste(inicioPopup, nombrePopup,tematicaPopup,queHacemosPopup,contactoPopup,direccionPopup,"<br>",contactoTelefonoPopup,'<br>',contactoMailPopup, sep=''),
  ifelse(!is.na(data[[contactoTel]]),
   paste(inicioPopup, nombrePopup,tematicaPopup,queHacemosPopup,contactoPopup,direccionPopup,"<br>",contactoTelefonoPopup, sep=''),
  ifelse(!is.na(data[[contactoMail]]),
   paste(inicioPopup, nombrePopup,tematicaPopup,queHacemosPopup,contactoPopup,direccionPopup,"<br>",contactoMailPopup, sep=''),
   paste(inicioPopup, nombrePopup,tematicaPopup,queHacemosPopup, contactoPopup,direccionPopup, sep=''))))

if(addWhatsapp & !is.null(direccion) & !is.null(captionWhatsapp)) {
  whatsappPopup<- paste("<br> <h4> <center> <a href='https://api.whatsapp.com/send?text=",
                        encodeURI(paste("*",data[[nombre]],"*",sep='')),"%0a",encodeURI(direccion),'%0a',encodeURI(captionWhatsapp),"'target='_blank'><i class='fa fa-whatsapp'></i></a> Compartilo ! </center> </h4>", sep='')
  popups <- paste(popups,whatsappPopup,finalPopup,sep="")
}
  popups <- paste(popups,finalPopup,sep="")
  return(popups)
}

createIcons <- function(iconLibrary=NULL,iconName=NULL,markerColor=NULL,iconColor=NULL) {
  
}
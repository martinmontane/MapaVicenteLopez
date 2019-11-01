createPopups <- function(data,
                         addWhatsapp =TRUE,
                         nombre,
                         tematica,
                         direccion,
                         contactoTel,
                         contactoMail,
                         captionWhatsapp,
                         descripcion) {
  inicioPopup <- "<div class='leaflet-popup-scrolled' style='height:50vh'>"
  nombrePopup <- paste("<b><h3>",data[[nombre]],"</h3></b>", sep='')
  tematicaPopup <- paste("<b>Temática:</b>",data[[tematica]], sep='')
  queHacemosPopup <- ifelse(is.na(descripcion),'',paste("<h4>¿Qué hacemos?</h4>",descripcion))
  contactoPopup <- "<h4>¿Cómo podés contactarte?:</h4>"
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

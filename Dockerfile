FROM openanalytics/r-base
# Install Ubuntu packages
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    software-properties-common \
    curl

RUN sudo add-apt-repository ppa:marutter/c2d4u
RUN sudo add-apt-repository ppa:marutter/c2d4u3.5
RUN sudo apt-get update
RUN sudo apt-get install r-cran-readr -y
RUN sudo apt-get install r-cran-rcpp -y
RUN sudo apt-get install r-cran-ggplot2 -y
RUN sudo apt-get install r-cran-promises -y
RUN sudo apt-get install r-cran-later -y
RUN sudo apt-get install r-cran-httpuv -y
RUN sudo apt-get install r-cran-tidyselect -y
RUN sudo apt-get install r-cran-bindrcpp -y
RUN sudo apt-get install r-cran-dplyr -y
RUN sudo apt-get install r-cran-tidyr -y
RUN sudo apt-get install r-cran-plotly -y
RUN sudo apt-get install r-cran-htmltools -y
RUN sudo apt-get install libgdal-dev -y
RUN sudo apt-get install libudunits2-dev -y
# Install R packages that are required
# TODO: add further package if you need!
RUN R -e "install.packages(c('shiny','glue','rmarkdown','htmlwidgets','DT','shinyWidgets','shinyjs','shinycssloaders','shinydashboard','htmlwidgets','sf','leaflet','data.table','dqshiny','httpuv','stringi'))"

# copy the app to the image
RUN mkdir /root/mapavicentelopez
COPY app /root/mapavicentelopez

COPY Rprofile.site /usr/lib/R/etc/

CMD ["R","-e", "shiny::runApp('/root/mapavicentelopez')"]

EXPOSE 3838

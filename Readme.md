In this repository, I stored the R code I wrote for my COVID-19 interactive choropleth map of the Netherlands, which can be found on my online portfolio.  

In the project, I make use of a dataset on cumulative corona virus cases per municipality in the Netherlands published by the national government on https://data.overheid.nl/dataset/11508-covid-19-aantallen-gemeente-cumulatief.
I also used the following shapefile to draw the Dutch municipality borders required for the choropleth map: https://hub.arcgis.com/datasets/e1f0dd70abcb4fceabbc43412e43ad4b_0.
In this file I included a csv file containing population numbers per Dutch municipality obtained from: https://opendata.cbs.nl/statline/portal.html?_la=nl&_catalog=CBS&tableId=70072ned&_theme=230

In order to run the app, the "COVID Data Manipulation.R" file has to be run before the "COVID app.R" file.
I make use of both shiny and leaflet in order to create the interactive map.
The app has also been deployed on https://chris95.shinyapps.io/COVID19MapsNL/ and can also be accessed through my online portfolio.

# ========================
# VISUALIZACIÓN DE SERVICIOS DE PROVISIÓN
# Autora: Prof. Aline Pingarroni
# Clase: Servicios Ecosistémicos
# Carrera de Ecología FES-Iztacala UNAM
# ========================

# Instalar si es necesario
#install.packages(c("terra", "sf", "ggplot2", "ggspatial", "osmdata", "dplyr", "viridis"))

# Cargar librerías
library(terra)
library(sf)
library(ggplot2)
library(ggspatial)
library(osmdata)
library(dplyr)
library(viridis)

#Directorio de trabajo:
setwd("/Users/aline_nature/raster_resultados")
# 1. Cargar el raster de provisión
r_provision <- rast("PROVISION.tif")

# 2. Convertir a data.frame para ggplot
df_prov <- as.data.frame(r_provision, xy = TRUE, na.rm = TRUE)
names(df_prov)[3] <- "PUNTOS"

# 3. Obtener bounding box del raster y prepararlo para OSM
ext_prov <- ext(r_provision)
poly_prov <- as.polygons(ext_prov)
sf_prov <- st_as_sf(poly_prov)
st_crs(sf_prov) <- 32614  # UTM zona 14N

# Transformar a WGS84 para usar con OpenStreetMap
sf_prov_wgs <- st_transform(sf_prov, 4326)

# Expandir el bbox para que aparezcan calles alrededor
bbox_exp <- st_bbox(sf_prov_wgs)
bbox_exp["xmin"] <- bbox_exp["xmin"] - 0.001
bbox_exp["xmax"] <- bbox_exp["xmax"] + 0.001
bbox_exp["ymin"] <- bbox_exp["ymin"] - 0.001
bbox_exp["ymax"] <- bbox_exp["ymax"] + 0.001

# 4. Descargar calles de OpenStreetMap
osm_streets <- opq(bbox = bbox_exp) %>%
  add_osm_feature(key = "highway") %>%
  osmdata_sf()

# 5. Visualizar el raster sobre fondo OSM
ggplot() +
  geom_sf(data = osm_streets$osm_lines, color = "grey80", size = 0.3) +
  geom_raster(data = df_prov, aes(x = x, y = y, fill = PUNTOS), alpha = 0.8) +
  scale_fill_viridis_c(name = "Valor de Importancia", option = "C") +
  coord_sf(crs = 32614) +
  theme_minimal() +
  labs(title = "Servicios de Provisión en la FES-Iztacala",
       subtitle = "Mapeo participativo") +
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", style = north_arrow_fancy_orienteering())

# Guardar el mapa como imagen PNG (300 dpi)
ggsave("mapa_provision_fes.png",
       width = 10, height = 8, dpi = 300, units = "in")

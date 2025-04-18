# ========================
# SCRIPT PARA TRANSFORMAR Y SUMAR POLIGONO 
# DE CADA SERVICIO
# Autora: Prof. Aline Pingarroni
# Clase: Servicios Ecosistémicos
# Carrera de Ecología FES-Iztacala UNAM
# ========================

#Librerías
library(sf)
library(terra)
library(tidyverse)

# DESACTIVA EL "#" POR TIPO DE SERVICIO. Y CORRE UNA VEZ EL SCRIPT POR CADA TIPO DE SE
#tipo_deseado <- "REGULACION"  # Cambia por "CULTURAL" o "PROVISION"
#tipo_deseado <- "CULTURAL" 
#tipo_deseado <- "PROVISION"

# Cargar shapefiles
#En folder asegurate poner el directorio dónde están guardados los shapes
folder <- "/Users/aline_nature/Documents/Clases_Aline/Clases_2025-2/Servicios_Ecosistemicos_2025/Practica_Mapeo"
shape_files <- list.files(folder, pattern = "\\.shp$", full.names = TRUE)

# Leer y unir
shapes_list <- lapply(shape_files, st_read)
shapes_all <- bind_rows(shapes_list)

# Limpieza
shapes_all <- shapes_all %>%
  mutate(TIPO = str_trim(str_to_upper(TIPO))) %>%
  st_make_valid() %>%
  st_transform(crs = 32614)

# Filtrar por tipo de servicio
shapes_tipo <- shapes_all %>% filter(TIPO == tipo_deseado)

# Verifica si hay datos
if (nrow(shapes_tipo) == 0) stop("No hay geometrías para este tipo de servicio.")

# Convertir a objeto terra
vect_tipo <- vect(shapes_tipo)

# Crear raster base
r_template <- rast(ext(vect_tipo), resolution = 1, crs = crs(vect_tipo))

# Rasterizar con campo PUNTOS
raster_tipo <- rasterize(vect_tipo, r_template, field = "PUNTOS", fun = "sum", background = NA)

# Visualizar
plot(raster_tipo, main = paste("PUNTOS -", tipo_deseado))

# Guardar raster en el directorio principal
#Aquí vuelve asegurar que está tu directorio
setwd("/Users/aline_nature/Documents/Clases_Aline/Clases_2025-2/Servicios_Ecosistemicos_2025/Practica_Mapeo")
writeRaster(
  raster_tipo,
  filename = paste0(tipo_deseado, ".tif"),  # Solo el nombre del archivo, sin ruta
  filetype = "GTiff",
  overwrite = TRUE
)

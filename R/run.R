library(terra)
library(here)
library(R.utils)
library(tibble)
library(tmap)

source("R/source_functions.R")

# Create a helper table for the IUCN typology
IUCN_ecotypo <- define_IUCN_ecotypo(output_dir = here())
IUCN_ecotypo

# Download IUCN Ecosystem Typology data
download_IUCN_ecotypo(type = "raster", output_dir = "Data")

# Load downloaded IUCN data
IUCN_ecotypo_rasters <- load_IUCN_ecotypo(realms = "T",
                                          IUCN_data_dir = "Data/all-maps-raster-geotiff")

# Clean raster names
names(IUCN_ecotypo_rasters) <- clean_names_IUCN_ecotypo_raster(names(IUCN_ecotypo_rasters))

# Visualize the first layer
plot(IUCN_ecotypo_rasters[[1]], main = names(IUCN_ecotypo_rasters[[1]]))

# Create fake data frame with coordinates for multiple regions
coords_df <- fake_data
coords_vect <- vect(coords_df, geom = c("lon","lat"))

# Extract IUCN Ecosystem Typology data
my_IUCN_ecotypo_data <- terra::extract(IUCN_ecotypo_rasters, coords_vect)

# Simplify extracted dataset
my_IUCN_ecotypo_data_simplified <- simplify_IUCN_ecotypo_data(my_IUCN_ecotypo_data)


require(tibble)
require(here)
require(R.utils)
require(xml2)
require(dplyr)

# Download IUCN ecosystem typology
# type = type 
download_IUCN_ecotypo <- function(type = c("raster","shp"),
                                  output_dir = "",
                                  unzip = TRUE,
                                  overwrite = FALSE){
  
  output_dir <- here(output_dir)
  
  dir.create(output_dir, showWarnings = FALSE)
  
  if(all(type==c("raster","shp"))){
    url <- "https://zenodo.org/api/records/10081251/files-archive"
    destfile <- here(output_dir,"zenodo_10081251.zip")
  } else {
    if(type == "raster"){
      url <- "https://zenodo.org/records/10081251/files/all-maps-raster-geotiff.tar.bz2?download=1"
      destfile <- here(output_dir,"all-maps-raster-geotiff.tar.bz2")
    } 
    if(type == "shp"){
      url <- "https://zenodo.org/records/10081251/files/all-maps-vector-geojson.tar.bz2?download=1"
      destfile <- here(output_dir,"all-maps-vector-geojson.tar.bz2")
    } 
  }
  if(overwrite){
    download.file(url, destfile, mode = "wb")
  } else {
    if(!file.exists(destfile)){
      download.file(url, destfile, mode = "wb")
    }
  }
  if(unzip){
    if(all(type == c("raster","shp"))){
      output_dir_unzip <- gsub(".zip","",destfile)
    } else {
      if(type == "raster"){
        output_dir_unzip <- gsub(".tar.bz2","",destfile)
      } 
      if(type == "shp"){
        output_dir_unzip <- gsub(".tar.bz2","",destfile)
      } 
    }
    dir.create(output_dir_unzip, showWarnings = FALSE)
    
    test <- try({
      unzip(destfile, output_dir_unzip)
    })
    if(class(test) == "try-error"){
      tarfile <- sub("\\.bz2$", "", destfile)
      bunzip2(destfile, dest = tarfile, remove = FALSE, skip = TRUE)
      
      untar(tarfile, exdir = output_dir_unzip)
    }
  }
  cat("Files are saved in the folder:", output_dir_unzip)
}


load_IUCN_ecotypo <- function(realms = "all",
                              IUCN_data_dir = ""){
  
  possible_realms <- c("T","M","F","S","MT","SF","SM","TF","FM","MFT","all")
  if(!any(realms %in% possible_realms)){
    stop(cat("Unavailable realm. Realms shoud be one of the following:",
             paste(possible_realms, collapse = ", ")))
  }
  if(realms == "all"){
    realms <- possible_realms
  }
  all_rast <- list.files(IUCN_data_dir)
  
  if(realms == "all"){
    rast(all_rast)
  } else {
    pattern <- paste0("^", realms, "[0-9]") 
    selected_pos <- grep(pattern, all_rast)
    selected_rasters <- list.files(IUCN_data_dir, full.names = TRUE)[selected_pos]
    r_list <- lapply(selected_rasters, rast)
    
    target <- r_list[[1]]  # use first raster as reference
    # make sure rasters align
    r_list_proj <- lapply(r_list, function(r) {
      if(crs(r) == crs(target)){
        r
      } else {
        terra::project(r, target, method = "near")
      }
    })
    
    r_stack <- rast(r_list_proj)
    r_stack
  }
}

clean_names_IUCN_ecotypo_raster <- function(x){
  
  new_names <- sapply(x, function(x){
    tmp <- strsplit(x,".",fixed = TRUE)[[1]]
    paste(tmp[1],tmp[2],sep = ".")
  })
  names(new_names) <- NULL
  new_names
}

fake_data <- data.frame(
  region = c(
    rep("Amazon", 10),
    rep("Africa", 3),
    rep("Europe", 4),
    rep("Australia", 5),
    rep("United States", 2),
    rep("Asia", 3)
  ),
  lon = c(
    runif(10, -70, -50),       # Amazon
    runif(3, 10, 40),          # Africa
    runif(4, -10, 30),         # Europe
    runif(5, 115, 155),        # Australia
    runif(2, -125, -70),       # United States
    runif(3, 70, 140)          # Asia
  ),
  lat = c(
    runif(10, -10, 5),         # Amazon
    runif(3, -5, 15),          # Africa
    runif(4, 40, 60),          # Europe
    runif(5, -45, -10),        # Australia
    runif(2, 25, 50),          # United States
    runif(3, 10, 50)           # Asia
  )
)

define_IUCN_ecotypo <- function(output_dir){
  library(tibble)
  library(dplyr)
  library(stringr)
  
  output_file <- file.path(output_dir, "IUCN_ecotypo_table.csv")
  
  if(!file.exists(output_file)){
    # 1. Download the XML file (actually plain text)
    url <- "https://zenodo.org/records/10081251/files/map-details.xml?download=1"
    tmp <- tempfile(fileext = ".xml")
    download.file(url, tmp, mode = "wb")
    
    xml <- read_xml(tmp)
    
    # Extract Map nodes
    maps <- xml_find_all(xml, ".//Map")
    
    df <- tibble(
      map_code = xml_attr(maps, "map_code"),
      efg_code = xml_attr(maps, "efg_code"),
      Functional_group = xml_text(xml_find_first(maps, "./Functional_group")),
      Description = xml_text(xml_find_first(maps, "Description")),
      Contributors = xml_text(xml_find_first(maps, "Contributors")),
      Dataset_doi = xml_text(xml_find_first(maps, "Dataset-doi"))
    )
    
    write.csv(df, output_file, row.names = FALSE)
  }
  
  tmp <- read.csv(output_file)
  tibble(tmp)
  
}


simplify_IUCN_ecotypo_data <- function(df){
  
  # Identify the ecotypo columns (everything except ID)
  ecocols <- setdiff(names(df), "ID")
  
  # For each row, extract the column name where the value == 1
  df$IUCN_ecotypo <- apply(df[ecocols], 1, function(x) {
    pos <- which(x == 1)
    if (length(pos) == 1) {
      return(ecocols[pos])
    } else {
      return(NA)   # no match or multiple matches
    }
  })
  
  # Return only ID and the new column
  df_out <- df[, c("ID", "IUCN_ecotypo")]
  return(df_out)
  
}
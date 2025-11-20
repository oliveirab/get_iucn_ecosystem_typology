# IUCN Ecosystem Typology in R

This repository provides a collection of R functions to **download**, **load**, and **process** spatial data from the [**IUCN Global Ecosystem Typology**.](https://global-ecosystems.org/) It enables streamlined access to ecosystem maps, metadata tables, and helper tools for spatial analyses.

For full details about the IUCN Ecosystem Typology, visit: [https://global-ecosystems.org/](https://global-ecosystems.org/?utm_source=chatgpt.com)

## 1. Download IUCN Ecosystem Typology data

Use `download_IUCN_ecotypo()` to download ecosystem layers directly from Zenodo (record ID **10081251**).\
You can choose to download raster files, shapefiles or both.

Example:

`download_IUCN_ecotypo(output_dir = "data/", type = "raster")`

## 2. Create a helper table for the IUCN typology

`define_IUCN_ecotypo()` generates a reference table that includes:

-   `map_code`

-   `efg_code`

-   `Functional_group`

-   `Description`

-   `Contributors`

-   `Dataset_doi`

This table is useful for linking raster/shapefile classes to ecosystem descriptions.

## 3. Load downloaded IUCN data

`load_IUCN_ecotypo()` reads the files downloaded via `download_IUCN_ecotypo()` and loads them into R as `terra` objects or spatial dataframes, depending on the file type.

## Additional helper functions

This repository also includes convenience tools for processing and cleaning data:

• `simplify_IUCN_ecotypo_data()`

Simplifies the ecosystem classification (e.g., collapsing classes, focusing on subset of codes).

• `clean_names_IUCN_ecotypo_raster()`

Standardizes and cleans raster layer names for easier use downstream.

## Overview of functions

| Function | Purpose |
|----|----|
| `download_IUCN_ecotypo()` | Download raster/shapefile data from Zenodo |
| `define_IUCN_ecotypo()` | Build helper metadata table |
| `load_IUCN_ecotypo()` | Load data files into R |
| `simplify_IUCN_ecotypo_data()` | Reduce/simplify ecosystem classifications |
| `clean_names_IUCN_ecotypo_raster()` | Clean and standardize raster names |

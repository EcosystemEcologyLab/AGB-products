# library(xml2)
# library(fs)

make_icesat_urls <- 
  function(download_links = "/Volumes/moore/AGB_raw/Boreal_AGB_Density_ICESat2/download_links.html"){
    links <- 
      xml2::read_html(download_links) |> 
      xml2::xml_find_all(".//a") |> 
      xml2::xml_text()
     links <- links[stringr::str_detect(links, "\\.tif$")]
     tile_ids <- stringr::str_extract(links, "(?<=_)\\d+(?=\\.tif$)")
     names(links) <- tile_ids
     links
  }
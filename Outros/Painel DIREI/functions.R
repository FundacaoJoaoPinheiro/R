
dateInput2 <- function(inputId, label, minview = "days", maxview = "decades", ...) {
  d <- shiny::dateInput(inputId, label, ...)
  d$children[[2L]]$attribs[["data-date-min-view-mode"]] <- minview
  d$children[[2L]]$attribs[["data-date-max-view-mode"]] <- maxview
  d
}


get_visualizacoes <- function(user_key, channel_id, videos_id){
  
  key <- user_key
  
  channel_id <- channel_id
  base <- "https://www.googleapis.com/youtube/v3/"

  
  # Construct the API call
  api_params <- 
    paste(paste0("key=", key), 
          paste0("id=", channel_id), 
          #paste0("forUsername=", user_id), 
          "part=snippet,contentDetails,statistics",
          sep = "&")
  api_call <- paste0(base, "channels", "?", api_params)
  api_result <- GET(api_call)
  json_result <- content(api_result, "text", encoding="UTF-8")
  
  # Process the raw data into a data frame
  channel.json <- fromJSON(json_result, flatten = T)
  channel.df <- as.data.frame(channel.json)
  
  playlist_id <- channel.df$items.contentDetails.relatedPlaylists.uploads
  
  # temporary variables
  nextPageToken <- ""
  upload.df <- NULL
  pageInfo <- NULL
  
  # Loop through the playlist while there is still a next page
  while (!is.null(nextPageToken)) {
    # Construct the API call
    api_params <- 
      paste(paste0("key=", key), 
            paste0("playlistId=", playlist_id), 
            "part=snippet,contentDetails,status",
            "maxResults=50",
            sep = "&")
    
    # Add the page token for page 2 onwards
    if (nextPageToken != "") {
      api_params <- paste0(api_params,
                           "&pageToken=",nextPageToken)
    }
    
    api_call <- paste0(base, "playlistItems", "?", api_params)
    api_result <- GET(api_call)
    json_result <- content(api_result, "text", encoding="UTF-8")
    upload.json <- fromJSON(json_result, flatten = T)
    
    nextPageToken <- upload.json$nextPageToken
    pageInfo <- upload.json$pageInfo
    
    curr.df <- as.data.frame(upload.json$items)
    if (is.null(upload.df)) {
      upload.df <- curr.df
    } else {
      upload.df <- bind_rows(upload.df, curr.df)
    }
  }
  
  video.df<- NULL
  # Loop through all uploaded videos
  for (i in c(1:length(videos_id))) {
    # Construct the API call
    video_id <- videos_id[i]
    api_params <- 
      paste(paste0("key=", key), 
            paste0("id=", video_id), 
            "part=id,statistics,contentDetails",
            sep = "&")
    
    api_call <- paste0(base, "videos", "?", api_params)
    api_result <- GET(api_call)
    json_result <- content(api_result, "text", encoding="UTF-8")
    video.json <- fromJSON(json_result, flatten = T)
    
    curr.df <- as.data.frame(video.json$items)
    
    if (is.null(video.df)) {
      video.df <- curr.df
    } else {
      video.df <- bind_rows(video.df, curr.df)
    }
  }  
  
  # Combine all video data frames
  video.df$contentDetails.videoId <- video.df$id
  video_final.df <- merge(x = upload.df, 
                          y = video.df,
                          by = "contentDetails.videoId")
  
  visualizacoes <- video.df |> select(statistics.viewCount, id, ) |> subset( video.df$id %in% videos_id)
  
  visualizacoes
  
}


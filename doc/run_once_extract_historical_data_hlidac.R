# Historical API data extraction to get full dataset for desired dataframe
# We only run this once in order not overwhelm the API
# After that, we run another script to only get the yesterday's results

# EXTRACT FB and YT content with specified search criteria

## 1. Loading the required R libraries

# Package names
packages <- c("httr", "readr", "dplyr", "jsonlite")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))


## 2. Function for the extraction of FB and YT content

get_all_paginated <- function(server, start_date, end_date, dir_name, sort, descending) {

  # We initialize empty dataset to which we add rows with each loop iteration
  all_data <- tibble()

  # We have to create a desired directory, if one does not yet exist
  if (!dir.exists(dir_name)) {
    dir.create(dir_name)
  } else {
    print("Output directory already exists")
  }

  # Construct url call to query the number of pages
  url_call <- paste0(
    "https://www.hlidacstatu.cz/api/v2/datasety/vyjadreni-politiku/hledat?dotaz=server%3A",
    server,
    "%20datum%3A%5B",
    start_date,
    "%20TO%20",
    end_date,
    "%5D&sort=",
    sort,
    "&desc=",
    descending
  )

  # Get total number of pages from the initial result. We divide the number of
  # total posts by 25 (this is the size of one API page) and apply ceiling to get
  # full number
  pages <- ceiling(
    fromJSON(
      content(
        GET(
          url_call,
          add_headers(
            "Authorization" = Sys.getenv("HS_TOKEN")
          )
        ),
        as = "text"
      )
    )[[1]] / 25
  )

  # Unfortunately, Hlidac's API supports an upper limit of 200 pages so we have to
  # set an upper hard limit
  for (i in seq_len(pages)[seq_len(pages) <= 200]) {

    # Formulate url for the GET request for Facebook from all the timeframe
    paginated_url_call <- paste0(url_call, "&strana=", i)

    # Send GET request to the API of Hlidac Statu
    result_raw <- GET(paginated_url_call, add_headers("Authorization" = Sys.getenv("HS_TOKEN")))

    # Transform JSON output to a dataframe
    result_df <- fromJSON(content(result_raw, as = "text"))[[3]]

    all_data <- bind_rows(all_data, result_df)
  }

  saveRDS(object = all_data, file = paste0(dir_name, "/all_data_", tolower(server), ".rds"), compress = FALSE)
}


## 3. Inputs for the function

server <- "Youtube" # Could be "Youtube", "Twitter", Facebook"

start_date <- "2021-01-01" # YYYY-MM-DD or "*" to include everything until the end/beginning

end_date <- "*" # Same as start_date

sort <- "datum" # Which collumn is used for sorting?

descending <- 1 # 1 is descending sort, 0 is ascending

dir_name <- "data" # Specify the folder, where the tables will be saved

## 4. Running the function

get_all_paginated(server, start_date, end_date, dir_name, sort, descending)

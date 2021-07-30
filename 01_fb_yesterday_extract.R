# EXTRACT ALL YESTERDAY'S FB POSTS, ADD IT TO THE FULL LIST

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

fb_posts_yesterday <- function(server, start_date, end_date, dir_name, sort, descending) {

  # We initialize empty dataset to which we add rows with each loop iteration
  yesterday_data <- tibble()

  # We have to create a desired directory, if one does not yet exist
  if (!dir.exists(dir_name)) {
    dir.create(dir_name)
  } else {
    print("Output directory already exists")
  }

  # Construct url call to query the number of pages from yesterday's posts
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

    # Formulate URL for the GET request for Facebook from yesterday
    paginated_url_call <- paste0(url_call, "&strana=", i)

    # Send GET request to the API of Hlidac Statu
    result_raw <- GET(paginated_url_call, add_headers("Authorization" = Sys.getenv("HS_TOKEN")))

    # Transform JSON output to a dataframe
    result_df <- fromJSON(content(result_raw, as = "text"))[[3]]

    yesterday_data <- bind_rows(yesterday_data, result_df)
  }

  # We are saving the merged dataframes with yesterday's data as CSV and RDS file (for speed in R)
  write_excel_csv(x = yesterday_data, file = paste0(dir_name, "/yesterday_data_", tolower(server), ".csv"))
  saveRDS(object = yesterday_data, file = paste0(dir_name, "/yesterday_data_", tolower(server), ".rds"), compress = FALSE)

  # Load in the existing full dataset merge with yesterday's new data
  all_data <- readRDS(paste0(dir_name, "/all_data_", tolower(server), ".rds"))

  # Append the existing dataset with new rows from yesterday and delete duplicates
  all_data <- bind_rows(yesterday_data, all_data) %>% distinct()

  # Save full dataset again both in CSV and RDS
  saveRDS(object = all_data, file = paste0(dir_name, "/all_data_", tolower(server), ".rds"), compress = FALSE)
  write_excel_csv(x = all_data, file = paste0(dir_name, "/all_data_", tolower(server), ".csv"))
}

## 3. Inputs for the FIO scraping function
dir_name <- "data" # Specify the folder, where the tables will be saved

server <- "Facebook" # Could be "Youtube", "Twitter", Facebook"

start_date <- Sys.Date() - 1 # We select yesterday's date in YYYY-MM-DD format

end_date <- Sys.Date() - 1 # Same as start_date - we only want yesterday

sort <- "datum" # Which column is used for sorting? We keep this consistent

descending <- 1 # 1 is descending sort, 0 is ascending. We keep this consistent

## 4. Running the function
fb_posts_yesterday(server, start_date, end_date, dir_name, sort, descending)

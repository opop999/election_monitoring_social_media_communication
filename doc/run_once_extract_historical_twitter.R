# Historical API data extraction to get full dataset for desired dataframe
# We only run this once in order not overwhelm the API
# After that, we run another script to only get the yesterday's results

# EXTRACT FB and YT content with specified search criteria

## 1. Loading the required R libraries

# Package names
packages <- c("data.table", "arrow", "dplyr", "academictwitteR")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Disable scientific notation of numbers
options(scipen = 999)

## 2. Function for the extraction of Twitter content

get_all_twitter <- function(server, users, start_date, end_date, dir_name, upper_limit, token) {

  # We have to create a desired directory, if one does not yet exist

  if (!dir.exists(dir_name)) {
    dir.create(dir_name)
  } else {
    print("Output directory already exists")
  }

  # This function calls the Twitter API and saves the output to JSON
  get_all_tweets(users = users,
                 start_tweets = paste0(start_date, "T00:00:00Z"),
                 end_tweets = paste0(end_date, "T00:00:00Z"),
                 is_retweet	= FALSE,
                 data_path = paste0(dir_name, "/json/"),
                 export_query = FALSE,
                 n = upper_limit,
                 bearer_token = token)

  # This function binds extracted JSONS to a "tidy" dataframe
  all_data <- bind_tweets(paste0(dir_name, "/json/"), output_format = "tidy")

  # Delete unneeded JSON repository
  unlink(paste0(dir_name, "/json/"), recursive = TRUE)

  # Save to CSV and RDS+Feather for speed
  saveRDS(all_data, file = paste0(dir_name, "/all_data_", tolower(server), "_test.rds"), compress = FALSE)
  write_feather(x = all_data, sink = paste0(dir_name, "/all_data_", tolower(server), "_test.feather"))
  fwrite(x = all_data, file = paste0(dir_name, "/all_data_", tolower(server), "_test.csv"))

}

## 3. Inputs for the function

start_date <- "2021-01-01" # YYYY-MM-DD or "*" to include everything until the end/beginning

end_date <- format(Sys.Date(), format = "%Y-%m-%d")  # Same as start_date

dir_name <- "data" # Specify the folder, where the tables will be saved

users <- readRDS("data/twitter_id.rds")

upper_limit <- 1000000

server <- "Twitter" # Could be "Youtube", "Twitter", Facebook"

token <- Sys.getenv("TWITTER_TOKEN")


## 4. Running the function

get_all_twitter(server = server,
                users = users,
                start_date = start_date,
                end_date = end_date,
                dir_name = dir_name,
                upper_limit = upper_limit,
                token = token)

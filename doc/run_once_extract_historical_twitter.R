# Historical API data extraction to get full dataset for desired dataframe
# We only run this once in order not overwhelm the API
# After that, we run another script to only get the yesterday's results

# EXTRACT FB and YT content with specified search criteria

## 1. Loading the required R libraries

# Package names
packages <- c("httr", "data.table", "arrow", "dplyr", "jsonlite", "academictwitteR")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Disable scientific notation of numbers
options(scipen = 999)

# We have to create a desired directory, if one does not yet exist
get_all_twitter <- function(server, start_date, end_date, dir_name, upper_limit, token) {


  if (!dir.exists(dir_name)) {
    dir.create(dir_name)
  } else {
    print("Output directory already exists")
  }

all_data <- get_all_tweets(users = users,
                 start_tweets = paste0(start_date, "T00:00:00Z"),
                 end_tweets = paste0(end_date, "T00:00:00Z"),
                 is_retweet	= FALSE,
                 n = upper_limit,
                 bearer_token = token)

all_data_listless <- all_data %>% select(!any_of(c("entities",
                                            "possibly_sensitive",
                                            "referenced_tweets",
                                            "public_metrics",
                                            "attachments",
                                            "geo",
                                            "lang")))

saveRDS(all_data, file = paste0(dir_name, "/all_data_", tolower(server), ".rds"))

write_feather(x = all_data_listless, sink = paste0(dir_name, "/all_data_", tolower(server), ".feather"))
fwrite(x = all_data_listless, file = paste0(dir_name, "/all_data_", tolower(server), ".csv"))

binded <- bind_rows(all_data_twitter, all_data_twitter)


}


## 3. Inputs for the function

start_date <- "2021-01-01" # YYYY-MM-DD or "*" to include everything until the end/beginning

end_date <- format(Sys.Date(), format = "%Y-%m-%d")  # Same as start_date

dir_name <- "data" # Specify the folder, where the tables will be saved

users <- readRDS("data/twitter_id.rds")

upper_limit <- 100000

server <- "Twitter" # Could be "Youtube", "Twitter", Facebook"

token <- Sys.getenv("TWITTER_TOKEN")



## 4. Running the function

get_all_twitter(server, start_date, end_date, dir_name, upper_limit, token)

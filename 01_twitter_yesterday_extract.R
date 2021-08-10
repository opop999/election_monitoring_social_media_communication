# EXTRACT ALL YESTERDAY'S TWEETS, ADD IT TO THE FULL LIST

## 1. Loading the required R libraries

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

get_yesterday_twitter <- function(server, users, start_date, end_date, dir_name, upper_limit, token) {

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
yesterday_data <- bind_tweets(paste0(dir_name, "/json/"), output_format = "tidy")

	# Delete unneeded JSON repository
	unlink(paste0(dir_name, "/json/"), recursive = TRUE)

	# We are saving the merged dataframes with yesterday's data as CSV and RDS file (for speed in R)
	fwrite(x = yesterday_data, file = paste0(dir_name, "/yesterday_data_", tolower(server), ".csv"))
	saveRDS(object = yesterday_data, file = paste0(dir_name, "/yesterday_data_", tolower(server), ".rds"), compress = FALSE)

	# Load in the existing full dataset merge with yesterday's new data
	all_data <- readRDS(paste0(dir_name, "/all_data_", tolower(server), ".rds"))

	# Append the existing dataset with new rows from yesterday and delete duplicates
	all_data <- bind_rows(yesterday_data, all_data) %>% distinct()

	saveRDS(object = all_data, file = paste0(dir_name, "/all_data_", tolower(server), ".rds"), compress = FALSE)
	write_feather(x = all_data, sink = paste0(dir_name, "/all_data_", tolower(server), ".feather"))
	fwrite(x = all_data, file = paste0(dir_name, "/all_data_", tolower(server), ".csv"))

}

## 3. Inputs for the function

start_date <- format(Sys.Date() - 8, format = "%Y-%m-%d") # YYYY-MM-DD or "*" to include everything until the end/beginning

end_date <- format(Sys.Date() - 1, format = "%Y-%m-%d")  # Same as start_date

dir_name <- "data" # Specify the folder, where the tables will be saved

users <- readRDS("data/twitter_id.rds")

upper_limit <- 1000

server <- "Twitter" # Could be "Youtube", "Twitter", Facebook"

token <- Sys.getenv("TWITTER_TOKEN")


## 4. Running the function

get_yesterday_twitter(server, users, start_date, end_date, dir_name, upper_limit, token)

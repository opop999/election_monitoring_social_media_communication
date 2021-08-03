# EXTRACT ALL YESTERDAY'S TWEETS, ADD IT TO THE FULL LIST

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
get_yesterday_twitter <- function(server, start_date, end_date, dir_name, upper_limit, token) {

	if (!dir.exists(dir_name)) {
		dir.create(dir_name)
	} else {
		print("Output directory already exists")
	}

	yesterday_data <- get_all_tweets(users = users,
														 start_tweets = paste0(start_date, "T00:00:00Z"),
														 end_tweets = paste0(end_date, "T00:00:00Z"),
														 is_retweet	= FALSE,
														 n = upper_limit,
														 bearer_token = token)

	yesterday_data_listless <- yesterday_data %>% select(!any_of(c("entities",
																							"possibly_sensitive",
																							"referenced_tweets",
																							"public_metrics",
																							"attachments",
																							"geo",
																							"lang")))

	# We are saving the merged dataframes with yesterday's data as CSV and RDS file (for speed in R)
	fwrite(x = yesterday_data_listless, file = paste0(dir_name, "/yesterday_data_", tolower(server), ".csv"))
	saveRDS(object = yesterday_data, file = paste0(dir_name, "/yesterday_data_", tolower(server), ".rds"), compress = FALSE)

	# Load in the existing full dataset merge with yesterday's new data
	all_data <- readRDS(paste0(dir_name, "/all_data_", tolower(server), ".rds"))

	# Append the existing dataset with new rows from yesterday and delete duplicates
	all_data <- bind_rows(yesterday_data, all_data) %>% distinct()

	saveRDS(object = all_data, file = paste0(dir_name, "/all_data_", tolower(server), ".rds"), compress = FALSE)


  all_data_listless <- all_data %>% select(!any_of(c("entities",
																							"possibly_sensitive",
																							"referenced_tweets",
																							"public_metrics",
																							"attachments",
  																						"geo",
																							"lang")))


	write_feather(x = all_data_listless, sink = paste0(dir_name, "/all_data_", tolower(server), ".feather"))
	fwrite(x = all_data_listless, file = paste0(dir_name, "/all_data_", tolower(server), ".csv"))



}


## 3. Inputs for the function

start_date <- format(Sys.Date() - 2, format = "%Y-%m-%d") # YYYY-MM-DD or "*" to include everything until the end/beginning

end_date <- format(Sys.Date() - 1, format = "%Y-%m-%d")  # Same as start_date

dir_name <- "data" # Specify the folder, where the tables will be saved

users <- readRDS("data/twitter_id.rds")

upper_limit <- 1000

server <- "Twitter" # Could be "Youtube", "Twitter", Facebook"

token <- Sys.getenv("TWITTER_TOKEN")


## 4. Running the function

get_yesterday_twitter(server, start_date, end_date, dir_name, upper_limit, token)

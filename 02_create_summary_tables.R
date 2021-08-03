## 1. Load the required R libraries

# Package names
packages <- c("dplyr", "data.table", "tidyr")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
	install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))

# Disable scientific notation of numbers
options(scipen = 999)

if (!dir.exists("data/summary_tables")) {
	dir.create("data/summary_tables")
} else {
	print("Output directory already exists")
}


# Load tables created in the previous step
all_data_facebook <- readRDS("data/all_data_facebook.rds")
all_data_youtube <- readRDS("data/all_data_youtube.rds")
# all_data_twitter <- readRDS("data/all_data_twitter.rds")

## 2. Creating a summary table with total activity per page
total_posts_fb <- all_data_facebook %>%
	transmute(entity_name = as.factor(osobaid),
						date = format(as.Date(datum), format = "%Y-%m-%d"),
						words = as.numeric(pocetSlov)) %>%
						group_by(entity_name) %>%
						summarise(total_posts = n(),
											total_thousand_words = round(sum(words)/1000, digits = 1),
											words_per_post = round(mean(words), digits = 0))

total_posts_yt <- all_data_youtube %>%
	transmute(entity_name = as.factor(osobaid),
						date = format(as.Date(datum), format = "%Y-%m-%d")) %>%
						group_by(entity_name) %>%
						summarise(total_posts = n()) %>%
						arrange(desc(total_posts)) %>%
						ungroup()

# total_posts_tw <- all_data_twitter %>%
# 	transmute() %>%
# 	group_by() %>%
# 	summarise())

# 3. Creating a summary table with activity per page throughout time
time_posts_fb <- all_data_facebook %>%
	transmute(entity_name = as.factor(osobaid),
						date = format(as.Date(datum), format = "%Y-%m-%d")) %>%
	group_by(entity_name, date) %>%
	summarise(posts_in_day = n()) %>%
	mutate(cumulative_posts = cumsum(posts_in_day)) %>%
	ungroup() %>%
	arrange(desc(date))

time_posts_yt <- all_data_youtube %>%
	transmute(entity_name = as.factor(osobaid),
						date = format(as.Date(datum), format = "%Y-%m-%d")) %>%
	group_by(entity_name, date) %>%
	summarise(posts_in_day = n()) %>%
	mutate(cumulative_posts = cumsum(posts_in_day)) %>%
	ungroup() %>%
	arrange(desc(date))

# time_posts_tw <- all_data_twitter %>%

# 4. Saving all tables to csv and rds files
fwrite(total_posts_fb, "data/summary_tables/total_summary_fb.csv")
saveRDS(object = total_posts_fb, file = "data/summary_tables/total_summary_fb.rds", compress = FALSE)

fwrite(total_posts_yt, "data/summary_tables/total_summary_yt.csv")
saveRDS(object = total_posts_yt, file = "data/summary_tables/total_summary_yt.rds", compress = FALSE)


fwrite(time_posts_yt, "data/summary_tables/time_summary_yt.csv")
saveRDS(object = time_posts_yt, file = "data/summary_tables/time_summary_yt.rds", compress = FALSE)

fwrite(time_posts_fb, "data/summary_tables/time_summary_fb.csv")
saveRDS(object = time_posts_fb, file = "data/summary_tables/time_summary_fb.rds", compress = FALSE)

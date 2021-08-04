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

# Specify the folder, where the raw tables are read to and where the summary tables will be saved
dir_name <- "data"

if (!dir.exists(paste0(dir_name, "/summary_tables"))) {
  dir.create(paste0(dir_name, "/summary_tables"))
} else {
  print("Output directory already exists")
}


# Where is the dataset from FB Ads repository stored?
fb_ads_url <- "https://github.com/opop999/election_monitoring_fb_ads/raw/master/data/merged_data_lean.rds"

# To find out, what proportion of the posts are sponsored, we import dataset from FB Ads repository
temp <- tempfile()
download.file(fb_ads_url, temp)
all_data_facebook_ads <- readRDS(temp)
unlink(temp)

# Load tables created in the previous step
all_data_facebook <- readRDS(paste0(dir_name, "/all_data_facebook.rds"))
all_data_youtube <- readRDS(paste0(dir_name, "/all_data_youtube.rds"))
all_data_twitter <- readRDS(paste0(dir_name, "/all_data_twitter.rds"))

## 2. Creating a summary table with total activity per page
total_summary_fb <- all_data_facebook %>%
  left_join(all_data_facebook_ads, by = c("text" = "ad_creative_body"), keep = TRUE) %>%
  transmute(
    entity_name = as.factor(osobaid),
    date = format(as.Date(datum), format = "%Y-%m-%d"),
    words = as.numeric(pocetSlov),
    sponsored_post = ifelse(is.na(ad_creative_body) == FALSE, 1, 0)
  ) %>%
  group_by(entity_name) %>%
  summarise(
    total_posts = n(),
    total_sponsored_posts = sum(sponsored_post),
    total_thousand_words = round(sum(words) / 1000, digits = 1),
    words_per_post = round(mean(words), digits = 0),
    proportion_sponsored = total_sponsored_posts/total_posts) %>%
   ungroup() %>%
  arrange(desc(total_posts))

total_summary_yt <- all_data_youtube %>%
  transmute(
    entity_name = as.factor(osobaid),
    date = format(as.Date(datum), format = "%Y-%m-%d")
  ) %>%
  group_by(entity_name) %>%
  summarise(total_posts = n()) %>%
  arrange(desc(total_posts)) %>%
  ungroup()

total_summary_tw <- all_data_twitter %>%
  transmute(
    entity_name = as.factor(user_username),
    entity_id = as.factor(author_id),
    date = format(as.Date(created_at), format = "%Y-%m-%d"),
    interactions = (retweet_count + like_count + quote_count),
    followers_thousands = user_followers_count / 1000,
    source_iphone = ifelse(source == "Twitter for iPhone", 1, 0),
    source_android = ifelse(source == "Twitter for Android", 1, 0),
    source_web = ifelse(source == "Twitter Web App", 1, 0),
    source_tweet_deck = ifelse(source == "TweetDeck", 1, 0),
    source_ipad = ifelse(source == "Twitter for iPad", 1, 0),
    source_media_studio = ifelse(source == "Twitter Media Studio", 1, 0)
  ) %>%
  group_by(entity_name, entity_id) %>%
  summarise(
    total_posts = n(),
    total_followers_thousands = round(max(followers_thousands), digits = 0),
    total_interactions_thousands = round(sum(interactions) / 1000, digits = 0),
    total_source_iphone = sum(source_iphone),
    total_source_android = sum(source_android),
    total_source_web = sum(source_web),
    total_source_tweet_deck = sum(source_tweet_deck),
    total_source_ipad = sum(source_ipad),
    total_source_media_studio = sum(source_media_studio)
  ) %>%
  arrange(desc(total_posts)) %>%
  ungroup()

# 3. Creating a summary table with activity per page throughout time
time_summary_fb <- all_data_facebook %>%
  left_join(all_data_facebook_ads, by = c("text" = "ad_creative_body"), keep = TRUE) %>%
  transmute(
    entity_name = as.factor(osobaid),
    date = format(as.Date(datum), format = "%Y-%m-%d"),
    sponsored_post = ifelse(is.na(ad_creative_body) == FALSE, 1, 0)
  ) %>%
  group_by(entity_name, date) %>%
  summarise(posts_in_day = n(),
            sponsored_posts_in_day = sum(sponsored_post)) %>%
  arrange(date) %>%
  mutate(cumulative_posts = cumsum(posts_in_day),
         cumulative_sponsored_posts = cumsum(sponsored_posts_in_day)) %>%
  ungroup() %>%
  arrange(desc(date))

time_summary_yt <- all_data_youtube %>%
  transmute(
    entity_name = as.factor(osobaid),
    date = format(as.Date(datum), format = "%Y-%m-%d")
  ) %>%
  group_by(entity_name, date) %>%
  summarise(posts_in_day = n()) %>%
  arrange(date) %>%
  mutate(cumulative_posts = cumsum(posts_in_day)) %>%
  ungroup() %>%
  arrange(desc(date))

time_summary_tw <- all_data_twitter %>%
  transmute(
    entity_name = as.factor(user_username),
    entity_id = as.factor(author_id),
    date = format(as.Date(created_at), format = "%Y-%m-%d"),
    interactions = (retweet_count + like_count + quote_count),
    followers_thousands = user_followers_count / 1000
  ) %>%
  group_by(entity_name, date) %>%
  summarise(
    posts_in_day = n(),
    interactions_in_day = sum(interactions)
  ) %>%
  arrange(date) %>%
  mutate(
    cumulative_posts = cumsum(posts_in_day),
    cumulative_interactions_thousands = round(cumsum(interactions_in_day) / 1000, digits = 1)
  ) %>%
  ungroup() %>%
  arrange(desc(date))

# 4. Saving all tables to csv and rds files
# Total summaries
fwrite(x = total_summary_fb, file = paste0(dir_name, "/summary_tables", "/total_summary_fb.csv"))
saveRDS(object = total_summary_fb, file = paste0(dir_name, "/summary_tables", "/total_summary_fb.rds"), compress = FALSE)

fwrite(x = total_summary_yt, file = paste0(dir_name, "/summary_tables", "/total_summary_yt.csv"))
saveRDS(object = total_summary_yt, file = paste0(dir_name, "/summary_tables", "/total_summary_yt.rds"), compress = FALSE)

fwrite(x = total_summary_tw, file = paste0(dir_name, "/summary_tables", "/total_summary_tw.csv"))
saveRDS(object = total_summary_tw, file = paste0(dir_name, "/summary_tables", "/total_summary_tw.rds"), compress = FALSE)

# Time summaries
fwrite(x = time_summary_fb, file = paste0(dir_name, "/summary_tables", "/time_summary_fb.csv"))
saveRDS(object = time_summary_fb, file = paste0(dir_name, "/summary_tables", "/time_summary_fb.rds"), compress = FALSE)

fwrite(x = time_summary_yt, file = paste0(dir_name, "/summary_tables", "/time_summary_yt.csv"))
saveRDS(object = time_summary_yt, file = paste0(dir_name, "/summary_tables", "/time_summary_yt.rds"), compress = FALSE)

fwrite(x = time_summary_tw, file = paste0(dir_name, "/summary_tables", "/time_summary_tw.csv"))
saveRDS(object = time_summary_tw, file = paste0(dir_name, "/summary_tables", "/time_summary_tw.rds"), compress = FALSE)



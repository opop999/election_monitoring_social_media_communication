# To improve readability of the main script and its length, this script is made
# to be modified. We can add and remove the monitored FB pages and than we save
# the list to a rds file, which is then read to the main extraction script.

# See the readme.md for the currently monitored pages

personal_id <- c("karel-havlicek-3",
								 "andrej-babis",
								 "tomio-okamura",
								 "vaclav-klaus-2",
								 "vojtech-filip",
								 "alena-schilerova",
								 "vit-rakusan",
								 "pavel-fischer",
								 "klara-dostalova",
								 "adam-vojtech-1",
								 "mikulas-peksa",
								 "olga-richterova",
								 "vojtech-pikal",
								 "marcel-kolaja",
								 "jan-hamacek",
								 "petr-fiala")

# We have to create a desired directory, if one does not yet exist
if (!dir.exists("data")) {
  dir.create("data")
} else {
  print("Output directory already exists")
}

saveRDS(personal_id, "data/personal_id.rds", compress = FALSE)

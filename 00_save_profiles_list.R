# To improve readability of the main script and its length, this script is made
# to be modified. We can add and remove the monitored FB pages and than we save
# the list to a rds file, which is then read to the main extraction script.

# See the readme.md for the currently monitored pages

# We have to create a desired directory, if one does not yet exist

if (!dir.exists("data")) {
	dir.create("data")
} else {
	print("Output directory already exists")
}


# We are currently extracting all profiles on Hlidac Statu, therefore, we are
# not using the simplification by the profile_id (unlike with Twitter API)

# PROFILES IN HLIDAC STATU DATABASE

# hlidac_id <- c("karel-havlicek-3",
# 								 "andrej-babis",
# 								 "tomio-okamura",
# 								 "vaclav-klaus-2",
# 								 "vojtech-filip",
# 								 "alena-schilerova",
# 								 "vit-rakusan",
# 								 "pavel-fischer",
# 								 "klara-dostalova",
# 								 "adam-vojtech-1",
# 								 "mikulas-peksa",
# 								 "olga-richterova",
# 								 "vojtech-pikal",
# 								 "marcel-kolaja",
# 								 "jan-hamacek",
# 								 "petr-fiala")
#
#
# saveRDS(hlidac_id, "data/hlidac_id.rds", compress = FALSE)

# TWITTER HANDLES FOR TWITTER API
twitter_id <- c("AndrejBabis",
							 "tomio_cz",
								"alenaschillerov",
								"KarelHavlicek_",
								"vojtafilip",
								"Vit_Rakusan",
								"jhamacek",
								"P_Fiala",
								"PiratIvanBartos",
								"PiratskaStrana",
								"ODScz",
								"Zbynek_Stanjura",
								"kducsl",
							  "MJureka",
								"STANcz",
								"MartinBaxa2",
								"TOP09cz",
								"PavelSehnal64",
								"Jan_Skopecek",
								"SpoluKoalice",
								"RobertSlachta",
								"olgarichterova",
								"makupka",
							  "Kuba_Martin",
								"JanLipavsky",
								"volimtrikoloru",
								"czKSCM",
								"jana_cernochova",
								"zeleni_cz",
								"vonpecka",
								"TomasZdechovsky",
								"milionchvilek",
								"general_pavel",
								"market_a",
								"kalousekm",
								"metnarl",
								"TomasCzernin",
								"ZdenekHrib",
						   	"Pospisil_Jiri",
								"VeslavM",
								"honzabartosek")

print(paste("The query lenght is",
						sum(nchar(twitter_id)),
						", maximum query lenght is 1024. The remaining number of characters is",
						1024 - sum(nchar(twitter_id))))

saveRDS(twitter_id, "data/twitter_id.rds", compress = FALSE)



library(DBI)
library(RPostgres)
library(stringdist)

# Veritabanı parametreleri
host <- "127.0.0.1"
user <- "postgres"
password <- "135960"
dbname <- "postgres"

# Veritabanına bağlan
con <- dbConnect(Postgres(), dbname = dbname, host = host, user = user, password = password)

# Tablo isimlerini tanımla
ebebek_tables <- c("ebebek_beslenme", "ebebek_banyo", "ebebek_oyuncak", "ebebek_bebekodasi", "ebebek_aracgerec", "ebebek_guvenlik", "ebebek_emzirme", "ebebek_bezmendil")
civil_tables <- c("madrenino_beslenme", "madrenino_banyobakim", "madrenino_oyuncak", "madrenino_bebekodasi", "madrenino_aracgerec", "madrenino_guvenlik", "madrenino_emzirme", "madrenino_bez")


# Yardımcı fonksiyonlar
extract_brand <- function(text) {
  strsplit(text, " ")[[1]][1]
}

extract_numbers <- function(text) {
  gsub("[^0-9]", "", text)
}

# Eşleştirme işlemi için her tablo çifti üzerinde döngü
for (i in 1:length(ebebek_tables)) {
  ebebek_df <- dbReadTable(con, ebebek_tables[i])
  civil_df <- dbReadTable(con, civil_tables[i])

  # Ürün isimlerini ve fiyatları al
  texts1 <- ebebek_df$Description
  texts2 <- civil_df$Description
  price1 <- ebebek_df$Price
  price2 <- civil_df$Price
  id <- ebebek_df$id

  # Eşleştirme işlemi
  best_match_indices <- rep(NA, length(texts1))
  best_match_scores <- numeric(length(texts1))

  for (j in 1:length(texts1)) {
    brand1 <- extract_brand(texts1[j])
    numbers1 <- extract_numbers(texts1[j])

    for (k in 1:length(texts2)) {
      brand2 <- extract_brand(texts2[k])
      numbers2 <- extract_numbers(texts2[k])

      if (brand1 == brand2 && numbers1 == numbers2) {
        score <- stringsim(texts1[j], texts2[k], method = "jaccard")
        if (!is.na(score) && (is.na(best_match_scores[j]) || score > best_match_scores[j])) {
          if (score > 0.3) {
            best_match_scores[j] <- score
            best_match_indices[j] <- k
          } else {
            best_match_scores[j] <- 0  # Eşik değerin altındaki skorları sıfırla
            best_match_indices[j] <- NA  # Eşik değerin altındaki indeksleri NA olarak ayarla
          }
        }
      }
    }
  }
  # Diğer eşleşme sonuçlarınız...


  # Sonuçları hazırla
  best_matches <- ifelse(is.na(best_match_indices) | best_match_scores < 0.3, NA, texts2[best_match_indices])
  best_match_prices <- ifelse(is.na(best_match_indices) | best_match_scores < 0.3, NA, price2[best_match_indices])

  valid_match_indices <- which(best_match_scores > 0.3)
  results_df <- data.frame(
    id = id[valid_match_indices],
    ebebek = texts1[valid_match_indices],
    ebebekfiyat = price1[valid_match_indices],
    madrenino = texts2[best_match_indices[valid_match_indices]],
    madreninofiyat = price2[best_match_indices[valid_match_indices]],
    similarityscoremadrenino = best_match_scores[valid_match_indices]
  )

  # Veritabanına sonuçları yaz
  results_table_name <- paste("ebebek_madrenino", sub("ebebek_", "", ebebek_tables[i]), sep = "_")
  dbWriteTable(con, results_table_name, results_df, overwrite = TRUE)
}

# Veritabanı bağlantısını kapat
dbDisconnect(con)

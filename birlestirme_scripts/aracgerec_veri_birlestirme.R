library(DBI)
library(RPostgres)
library(dplyr)

# Veritabanı parametreleri
host <- "127.0.0.1"
user <- "postgres"
password <- "135960"
dbname <- "postgres"

# Veritabanına bağlan
con <- dbConnect(Postgres(), dbname = dbname, host = host, user = user, password = password)

# Veritabanından tabloları okuma
ebebek <- dbReadTable(con, "ebebek_aracgerec")
tablo1 <- dbReadTable(con, "ebebek_civil_aracgerec")
tablo2 <- dbReadTable(con, "ebebek_babymall_aracgerec")
tablo3 <- dbReadTable(con, "ebebek_madrenino_aracgerec")
tablo4 <- dbReadTable(con, "ebebek_bebekhouse_aracgerec")
tablo5 <- dbReadTable(con, "ebebek_welcomebaby_aracgerec")

# Tabloları birleştirme
merged_df <- ebebek %>%
  full_join(tablo1, by = "id") %>%
  full_join(tablo2, by = "id") %>%
  full_join(tablo3, by = "id") %>%
  full_join(tablo4, by = "id") %>%
  full_join(tablo5, by = "id")

# Sadece belirli sütunlarda değeri olan satırları filtreleme
merged_df <- merged_df %>%
  filter(!is.na(civilfiyat) | !is.na(babymallfiyat) | !is.na(madreninofiyat) | !is.na(bebekhousefiyat) | !is.na(welcomebabyfiyat))

# Birleştirilmiş veritabanını kaydetme
dbWriteTable(con, "aracgerec_verileri", merged_df, overwrite = TRUE)

# Veritabanı bağlantısını kapat
dbDisconnect(con)

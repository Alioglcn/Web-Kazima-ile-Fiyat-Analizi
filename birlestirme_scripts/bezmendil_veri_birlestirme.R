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
ebebek <- dbReadTable(con, "ebebek_bezmendil")
tablo1 <- dbReadTable(con, "ebebek_civil_bezmendil")
tablo2 <- dbReadTable(con, "ebebek_babymall_bezmendil")
tablo3 <- dbReadTable(con, "ebebek_madrenino_bezmendil")
tablo4 <- dbReadTable(con, "ebebek_bebekhouse_bezmendil")
tablo5 <- dbReadTable(con, "ebebek_welcomebaby_bezmendil")

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
dbWriteTable(con, "bezmendil_verileri", merged_df, overwrite = TRUE)

# Veritabanı bağlantısını kapat
dbDisconnect(con)

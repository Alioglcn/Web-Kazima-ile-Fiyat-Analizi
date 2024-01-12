library(RSelenium)
library(rvest)
library(dplyr)
library(purrr)
library(writexl)
library(DBI)
library(RPostgres)


ebebek <- function(url, tablename) {

  #Veritabanı bağlantıları. Sqlde bir sunucu başlatın ve bilgilerini buraya ekleyerek değiştirin.
  host <- "127.0.0.1"
  user <- "postgres"
  password <- "135960"
  dbname <- "postgres"


  # Belirtilen URL'ye git
  remDr$navigate(url)

  # Sayfa kaydırma ve veri çekme işlemleri
  repeat {
    old_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]
    remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
    Sys.sleep(5)
    new_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]
    if (old_height == new_height) {
      break
    }
  }

  # Sayfanın içeriğini al
  page_source <- remDr$getPageSource()[[1]]
  sayfa <- read_html(page_source)

  # Verileri çek. Ürün isimlerini alıyoruz
  descriptions <- sayfa %>% html_nodes('.product-item__brand') %>% html_text(trim = TRUE)
  descriptions <- gsub("-", "", descriptions) # Ürün isimlerinden - sembolünü kaldırıyoruz.

  prices <- sayfa %>%
    html_nodes('.product-item__new-price') %>% # ürünlerin fiyatını alıp, TL sembolünü kaldırıyoruz.
    html_text(trim = TRUE) %>%
    gsub(" TL", "", .) %>%
    gsub("\\.", "", .) %>%
    gsub(",", ".", .) %>%
    as.numeric()

  prices <- ifelse(is.na(prices), 0, prices)
  rounded_prices <- round(prices) # Fiyatları yuvarla

  products_df <- data.frame(
    id = seq_along(descriptions),
    Description = descriptions,
    Price = rounded_prices, # Yuvarlanmış fiyatları kullan
    stringsAsFactors = FALSE
  ) %>% distinct()

  # Veritabanı bağlantısını aç
  con <- dbConnect(RPostgres::Postgres(), host = host, user = user, password = password, dbname = dbname)

  # Veritabanında tablo yoksa oluştur veya güncelle
  if (!dbExistsTable(con, tablename)) {
    dbWriteTable(con, tablename, products_df, row.names = FALSE)
  } else {
    existing_data <- dbReadTable(con, tablename)
    new_data <- anti_join(products_df, existing_data, by = c("Description", "Price"))

    if (nrow(new_data) > 0) {
      dbWriteTable(con, tablename, new_data, append = TRUE, row.names = FALSE)
    }
  }

}




civil <- function(url, tablename) {

  host <- "127.0.0.1"
  user <- "postgres"
  password <- "135960"
  dbname <- "postgres"


  # Belirtilen URL'ye git
  remDr$navigate(url)


  # Sayfa kaydırma ve veri çekme işlemleri
  repeat {
    old_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]
    remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
    Sys.sleep(10)
    new_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]


    buttons <- remDr$findElements(using = 'css selector', '.btn.btn-lg.btn-stroke-dark.view-more-btn')
    Sys.sleep(10)
    if (length(buttons) > 0) {
      # İlk butona tıkla
      buttons[[1]]$clickElement()
      Sys.sleep(10) # Yeni sayfa açılana kadar bekle
    } else {
      break  # Yeni Next butonu yoksa işlemi bitir
    }

    if (old_height == new_height) {
      break
    }
  }


  page_source <- remDr$getPageSource()[[1]] # sayfa kaynağını alıyoruz
  sayfa <- read_html(page_source)

  # Verileri çek
  descriptions <- sayfa %>% html_nodes('.description') %>% html_text(trim = TRUE)


  prices <- sayfa %>%
    html_nodes('.price-sales') %>% # Fiyatları çek
    html_text(trim = TRUE) %>%
    gsub(" TL", "", .) %>%
    gsub("\\.", "", .) %>%
    gsub(",", ".", .) %>%
    as.numeric()

  prices <- ifelse(is.na(prices), 0, prices)
  rounded_prices <- round(prices)

  # Verileri bir dataframe'e dönüştür
  products_df <- data.frame(
    id = seq_along(descriptions),
    Description = descriptions,
    Price = rounded_prices, # Yuvarlanmış fiyatları kullan
    stringsAsFactors = FALSE
  )

  # Veritabanı bağlantısını aç
  con <- dbConnect(RPostgres::Postgres(), host = host, user = user, password = password, dbname = dbname)

  # Veritabanında tablo yoksa oluştur veya güncelle
  if (!dbExistsTable(con, tablename)) {
    dbWriteTable(con, tablename, products_df, row.names = FALSE)
  } else {
    dbExecute(con, paste0("TRUNCATE TABLE ", tablename))
    dbWriteTable(con, tablename, products_df, append = TRUE, row.names = FALSE)
  }


}




babymall <- function(url, tablename) {

  host <- "127.0.0.1"
  user <- "postgres"
  password <- "135960"
  dbname <- "postgres"


  # Belirtilen URL'ye git
  remDr$navigate(url)

  product_info <- list()

  Sys.sleep(3)



  repeat {
    page_source <- remDr$getPageSource()[[1]]
    sayfa <- read_html(page_source)

    descriptions <- sayfa %>% html_nodes('.productbox-title') %>% html_text(trim = TRUE)
    prices <- sayfa %>% html_nodes('.top-price') %>% html_text(trim = TRUE) %>%
      gsub(" TL", "", .) %>%
      gsub("\\.", "", .) %>%
      gsub(",", ".", .) %>%
      as.numeric()

    prices <- ifelse(is.na(prices), 0, prices)
    rounded_prices <- round(prices)

    product_info <- append(product_info, list(data.frame(Description = descriptions, Price = rounded_prices)))

    sonraki_sayfa_butonlar <- remDr$findElements(using = 'css selector', '.btn.pagination-navbtn.outline.small.next')
    buton_var_ve_tiklanabilir <- length(sonraki_sayfa_butonlar) > 0 && !any(sapply(sonraki_sayfa_butonlar, function(buton) {
      class_attr <- buton$getElementAttribute("class")[[1]]
      grepl("disabled", class_attr)
    }))

    for (buton in sonraki_sayfa_butonlar) {
      class_attr <- buton$getElementAttribute("class")[[1]]
      if (!grepl("disabled", class_attr)) {
        buton_var_ve_tiklanabilir <- TRUE
        buton$clickElement()
        Sys.sleep(3) # Yeni sayfanın yüklenmesini bekle
        break
      }
    }

    if (buton_var_ve_tiklanabilir) {
      sonraki_sayfa_butonlar[[1]]$clickElement()
      Sys.sleep(3) # Yeni sayfanın yüklenmesini bekle
    } else {
      print("Son sayfada, çıkılıyor...")
      break
    }
  }

  products_df <- bind_rows(
    id = seq_along(descriptions),
    product_info)

  # Veritabanı bağlantısını aç
  con <- dbConnect(RPostgres::Postgres(), host = host, user = user, password = password, dbname = dbname)

  # Veritabanında tablo yoksa oluştur veya güncelle
  if (!dbExistsTable(con, tablename)) {
    dbWriteTable(con, tablename, products_df, row.names = FALSE)
  } else {
    dbExecute(con, paste0("TRUNCATE TABLE ", tablename))
    dbWriteTable(con, tablename, products_df, append = TRUE, row.names = FALSE)
  }

  # Veritabanı bağlantısını kapat

}




madrenino <- function(url, tablename) {

  host <- "127.0.0.1"
  user <- "postgres"
  password <- "135960"
  dbname <- "postgres"


  # Belirtilen URL'ye git
  remDr$navigate(url)

  # Sayfa kaydırma ve veri çekme işlemleri
  repeat {
    old_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]
    remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
    Sys.sleep(5)
    new_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]
    if (old_height == new_height) {
      break
    }
  }

  # Sayfanın içeriğini al
  page_source <- remDr$getPageSource()[[1]]
  sayfa <- read_html(page_source)

  # Verileri çek
  descriptions <- sayfa %>% html_nodes('.productName.detailUrl') %>% html_text(trim = TRUE)
  descriptions <- gsub("-", "", descriptions)

  prices <- sayfa %>%
    html_nodes('.discountPrice') %>%
    html_text(trim = TRUE) %>%
    gsub("₺", "", .) %>%
    gsub("\\.", "", .) %>%
    gsub(",", ".", .) %>%
    as.numeric()



  prices <- ifelse(is.na(prices), 0, prices)


  products_df <- data.frame(
    id = seq_along(descriptions),
    Description = descriptions,
    Price = prices, # Yuvarlanmış fiyatları kullan
    stringsAsFactors = FALSE
  ) %>% distinct()

  # Veritabanı bağlantısını aç
  con <- dbConnect(RPostgres::Postgres(), host = host, user = user, password = password, dbname = dbname)

  # Veritabanında tablo yoksa oluştur veya güncelle
  if (!dbExistsTable(con, tablename)) {
    dbWriteTable(con, tablename, products_df, row.names = FALSE)
  } else {
    existing_data <- dbReadTable(con, tablename)
    new_data <- anti_join(products_df, existing_data, by = c("Description", "Price"))

    if (nrow(new_data) > 0) {
      dbWriteTable(con, tablename, new_data, append = TRUE, row.names = FALSE)
    }
  }


}






welcomebaby <- function(url, tablename) {

  host <- "127.0.0.1"
  user <- "postgres"
  password <- "135960"
  dbname <- "postgres"

  # Belirtilen URL'ye git
  remDr$navigate(url)

  # Sayfa kaydırma ve veri çekme işlemleri
  repeat {
    old_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]
    remDr$executeScript("window.scrollTo(0, document.body.scrollHeight);")
    Sys.sleep(5)
    new_height <- remDr$executeScript("return document.body.scrollHeight;")[[1]]
    if (old_height == new_height) {
      break
    }
  }

  # Sayfanın içeriğini al
  page_source <- remDr$getPageSource()[[1]]
  sayfa <- read_html(page_source)

  # Verileri çek
  descriptions <- sayfa %>% html_nodes('.product-card_productTitle__lzOti.product-card_smallText__TGJ7Q.product-card_ellipsis__K3ujx') %>% html_text(trim = TRUE)


  prices <- sayfa %>%
    html_nodes('.product-card_finalPrice__jBNuO') %>%
    html_text(trim = TRUE) %>%
    gsub(" ₺", "", .) %>%
    gsub("\\.", "", .) %>%
    gsub(",", ".", .) %>%
    as.numeric()

  prices <- ifelse(is.na(prices), 0, prices)


  products_df <- data.frame(
    id = seq_along(descriptions),
    Description = descriptions,
    Price = prices, # Yuvarlanmış fiyatları kullan
    stringsAsFactors = FALSE
  ) %>% distinct()

  # Veritabanı bağlantısını aç
  con <- dbConnect(RPostgres::Postgres(), host = host, user = user, password = password, dbname = dbname)

  # Veritabanında tablo yoksa oluştur veya güncelle
  if (!dbExistsTable(con, tablename)) {
    dbWriteTable(con, tablename, products_df, row.names = FALSE)
  } else {
    existing_data <- dbReadTable(con, tablename)
    new_data <- anti_join(products_df, existing_data, by = c("Description", "Price"))

    if (nrow(new_data) > 0) {
      dbWriteTable(con, tablename, new_data, append = TRUE, row.names = FALSE)
    }
  }

}




bebekhouse <- function(url, tablename) {


  host <- "127.0.0.1"
  user <- "postgres"
  password <- "135960"
  dbname <- "postgres"


  # Belirtilen URL'ye git
  remDr$navigate(url)

  product_info <- list()

  Sys.sleep(3)



  repeat {
    page_source <- remDr$getPageSource()[[1]]
    sayfa <- read_html(page_source)

    descriptions <- sayfa %>% html_nodes('.cell-product-name') %>% html_text(trim = TRUE)
    prices <- sayfa %>% html_nodes('.cell-product-price.d-inline-block.float-left.w-100.text-center.mb-0') %>% html_text(trim = TRUE) %>%
      gsub(" TL", "", .) %>%
      gsub("\\.", "", .) %>%
      gsub(",", ".", .) %>%
      as.numeric()

    prices <- ifelse(is.na(prices), 0, prices)
    rounded_prices <- round(prices)

    product_info <- append(product_info, list(data.frame(Description = descriptions, Price = rounded_prices)))

    sonraki_sayfa_butonlar <- remDr$findElements(using = 'css selector', '.next a') # Next butonunu al

    buton_var_ve_tiklanabilir <- length(sonraki_sayfa_butonlar) > 0 # Butonları kontrol ediyoruz




    if (buton_var_ve_tiklanabilir) {
      # Butonun etkin olup olmadığını kontrol ediyoruz
      class_attr <- sonraki_sayfa_butonlar[[1]]$getElementAttribute("class")[[1]]
      if (!grepl("disabled", class_attr)) {
        sonraki_sayfa_butonlar[[1]]$clickElement()
        Sys.sleep(5) # Sayfa yüklenmesini bekle
      } else {
        print("Son sayfada, çıkılıyor...")
        break
      }
    } else {
      print("Son sayfada veya sonraki sayfa butonu bulunamadı, çıkılıyor...")
      break
    }
  }

  products_df <- bind_rows(
    id = seq_along(descriptions),
    product_info)

  # Veritabanı bağlantısını aç
  con <- dbConnect(RPostgres::Postgres(), host = host, user = user, password = password, dbname = dbname)

  # Veritabanında tablo yoksa oluştur veya güncelle
  if (!dbExistsTable(con, tablename)) {
    dbWriteTable(con, tablename, products_df, row.names = FALSE)
  } else {
    dbExecute(con, paste0("TRUNCATE TABLE ", tablename))
    dbWriteTable(con, tablename, products_df, append = TRUE, row.names = FALSE)
  }

  # Veritabanı bağlantısını kapat
  dbDisconnect(con)
}




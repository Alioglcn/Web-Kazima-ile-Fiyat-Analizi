# Kütüphaneler
library(RSelenium)
library(rvest)
library(dplyr)
library(purrr)
library(writexl)
library(DBI)
library(RPostgres)
library(tidyverse)
library(netstat)
library(wdman)

# Veri çekme fonksiyonlarını almak için diğer modülü çağırıyoruz.
source("~/Desktop/Fiyat Analizi/WebKazımaileFiyatAnalizi/veri_cekme_scripts/veri_cekme_fonksiyonlar.R")

# Selenium web driver ayarları. Bu kısmı değiştirmeyelim.
chromePrefs <- list(
  profile.default_content_settings.cookies = 2
)
chromeOptions <- list(
  prefs = chromePrefs,
  args = c('--disable-cookies') # Cookie'leri devre dışı bırak
)

# RSelenium sürücüsünü başlat.
rD <- rsDriver(browser = "chrome",
                            chromever = "105.0.5195.52", # bu sürümü kendi Google tarayıcınızın sürümü ile değiştirmelisiniz.
                            verbose = F,
                            port=free_port(),
                            extraCapabilities = chromeOptions)

remDr <- rD$client
remDr$maxWindowSize()

#ebebek İşlemleri

ebebek("https://www.e-bebek.com/bez-mendil-c3737", "ebebek_bezmendil")
ebebek("https://www.e-bebek.com/arac-gerec-c3733", "ebebek_aracgerec")
ebebek("https://www.e-bebek.com/bebek-odasi-c3771", "ebebek_bebekodasi")
ebebek("https://www.e-bebek.com/banyo-bakim-c3765", "ebebek_banyo")
ebebek("https://www.e-bebek.com/oyuncak-kitap-c3729", "ebebek_oyuncak")
ebebek("https://www.e-bebek.com/beslenme-c3799", "ebebek_beslenme")
ebebek("https://www.e-bebek.com/emzirme-c3787", "ebebek_emzirme")
ebebek("https://www.e-bebek.com/guvenlik-c10100", "ebebek_guvenlik")

# Welcomebaby İşlemleri (veri_cekme_funcs.R sayfasına yönlendiriyoruz)
welcomebaby("https://welcomebaby.com.tr/oyuncak?o=3&page=1", "welcomebaby_oyuncak")
welcomebaby("https://welcomebaby.com.tr/bebek-odasi", "welcomebaby_bebekodasi")
welcomebaby("https://welcomebaby.com.tr/anne-bebek-bakim-saglik", "welcomebaby_banyobakim")
welcomebaby("https://welcomebaby.com.tr/anne-bebek-guvenlik-urunleri", "welcomebaby_guvenlik")
welcomebaby("https://welcomebaby.com.tr/anne-ve-emzirme", "welcomebaby_emzirme")
welcomebaby("https://welcomebaby.com.tr/bebek-cocuk-beslenme-urunleri", "welcomebaby_beslenme")
welcomebaby("https://welcomebaby.com.tr/anne-bebek-arac-gerec", "welcomebaby_aracgerec")


#Civil İşlemleri
civil("https://www.civilim.com/beslenme-ve-aksesuarlari", "civil_beslenme")
civil("https://www.civilim.com/anne-hamile-giyim", "civil_hamile")
civil("https://www.civilim.com/banyo-saglik", "civil_banyo")
civil("https://www.civilim.com/bebek-bezi-ve-islak-mendil", "civil_bez")
civil("https://www.civilim.com/oyuncaklar", "civil_oyuncak")
civil("https://www.civilim.com/bebek-odasi", "civil_bebekodasi")
civil("https://www.civilim.com/urunara?ctrid=16333&srchtxt=güvenlik", "civil_guvenlik")
civil("https://www.civilim.com/arac-gerec", "civil_aracgerec")

#Bebekhouse İşlemleri
bebekhouse("https://www.bebekhouse.com/reyon/beslenme-urunleri?page=1", "bebekhouse_beslenme")
bebekhouse("https://www.bebekhouse.com/reyon/oyuncak-ve-dislikler", "bebekhouse_oyuncak")
bebekhouse("https://www.bebekhouse.com/reyon/banyo-ve-bakim-urunleri", "bebekhouse_banyobakim")
bebekhouse("https://www.bebekhouse.com/reyon/arac-ve-gerecler", "bebekhouse_aracgerec")
bebekhouse("https://www.bebekhouse.com/reyon/anne-ve-emzirme-urunleri", "bebekhouse_emzirme")
bebekhouse("https://www.bebekhouse.com/reyon/bebek-ve-genc-odasi", "bebekhouse_bebekodasi")


#Babymall İşlemleri
babymall("https://www.babymall.com.tr/bebek-mamalari-c-20", "babymall_beslenme")
babymall("https://www.babymall.com.tr/arac-gerec-c-2", "babymall_aracgerec")
babymall("https://www.babymall.com.tr/bez-mendil-c-4", "babymall_bez")
babymall("https://www.babymall.com.tr/banyo-saglik-c-5", "babymall_banyobakim")
babymall("https://www.babymall.com.tr/bebek-guvenlik-c-6", "babymall_guvenlik")
babymall("https://www.babymall.com.tr/oyuncak-c-8", "babymall_oyuncak")
babymall("https://www.babymall.com.tr/bebek-odasi-c-9", "babymall_bebekodasi")
babymall("https://www.babymall.com.tr/anne-hamile-c-1", "babymall_hamile")



#Selenium sürücüsünü kapat.
remDr$close()

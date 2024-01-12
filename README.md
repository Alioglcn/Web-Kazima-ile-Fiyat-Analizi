# Web Kazıma ile Fiyat Analizi 

![Fiyat Analizi Uygulaması](https://github.com/Alioglcn/Web-Kazima-ile-Fiyat-Analizi/blob/main/images/app.jpeg)


R, Pyton ve Selenium teknolojileri ile geliştirilmiş, ebebek firmasının rakipleri arasındaki konumunu tespit eden bir Fiyat Analizi projesi.

## İçindekiler

* Açıklama
* Yükleme
* Kullanım
* Katkıda Bulunma

## Açıklama
Selenium ile internet sitelerinden çekilen ürünler, R ve Python ortamlarında işlenir. ebebek ürünleri, rakip firmaları ile kategorik olarak eşleştirilir ve her ürünün rakiplerdeki fiyatı tespit edilir. 


## Kurulum

Repository'i klonlayın:
    **git clone https://github.com/alioglcn/Web-Kazima_ile_Fiyat_Analizi.git**

'R_requirements.txt' içerisindeki talimatlara göre ilgili R kütüphanelerini, R ortamınızda yükleyin

'Python_Etiketleme/README.txt'içerisindeki talimatlara göre ilgili Python kütüphanelerini, python ortamınızda yükleyin.

## Kullanım

1. Bir veritabanı ortamı hazırlayın. Projemiz boyunca PostgreSql üzerinden ilerleyeceğiz. Kodlarda ilgili veritabanı bağlantılarını kendinize göre düzeltmelisiniz.
2. 'veri_cekme_scripts' içerisindeki 'veri_cekme_ana_script.R' dosyasındaki driver sürümlerini kendi ortamınıza göre değiştirin. (İçerisinde talimatlar mevcut)

3. Cron jobs ayarlama :
   Terminali açın. cd komutu ile projenizin dosya yolunu belirtin.  **0 12 * * * Rscript veri_cekme_scripts/veri_cekme_ana_script.R**  komutunu girin. Her gün veri çekme işlemleri tekrar edecektir.

![Predict Form](https://github.com/Alioglcn/Heart-Disease-Prediction/blob/main/static/assets/img/Screenshot%202023-08-01%20at%2023.40.16.png)


3. 'eslestirme_scripts' içerisindeki her scripti sırayla çalıştırın.
4. 'birlestirme_scrips' içerisindeki her scripti sırayla çalıştırın.
5. 'Python_Etiketleme/versionForExcel.py' adlı dosyayı çalıştırın.
6. 'uygulama/uygulama.R' dosyasını çalıştırın. Artık uygulamanız hazır!

![Details Page 1](https://github.com/Alioglcn/Heart-Disease-Prediction/blob/main/static/assets/img/Screenshot%202023-08-01%20at%2023.41.40.png)

![Details Page 2](https://github.com/Alioglcn/Heart-Disease-Prediction/blob/main/static/assets/img/Screenshot%202023-08-01%20at%2023.42.03.png)

![Details Page 3](https://github.com/Alioglcn/Heart-Disease-Prediction/blob/main/static/assets/img/Screenshot%202023-08-01%20at%2023.42.18.png)



## Technologies Used



## Katkıda Bulunma

Projeye katkıda bulunmak istiyorsanız, lütfen şu adımları izleyin:

  * Projeyi forklayın ve kendi branch'inizi oluşturun.
  * Değişikliklerinizi commit edin ve bir pull request oluşturun.
  * Pull request'inizi açıklamalı ve net bir biçimde yapın.

Mutlu Kodlamalar 😊












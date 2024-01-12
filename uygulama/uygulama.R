# Gerekli kütüphanelerin yüklenmesi (Kütüphaneleri kullanmak için ilk başta paketlerin indirilmesi gerekir.
# İndirilmesi sonrası commentlenebilir.)
# install.packages("shiny")
# install.packages("ggplot2")
# install.packages("readxl")
# install.packages("tidyr")
# install.packages("dplyr")
# install.packages("data.table")
# install.packages("viridis")
# install.packages("reactable")
# install.packages("DBI")
# install.packages("RPostgres")
library(shiny)
library(ggplot2)
library(readxl)
library(tidyr)
library(dplyr)
library(data.table)
# library(hrbrthemes)
library(viridis)
library(highcharter)
library(reactable)
library(DBI)
library(RPostgres)

# Bar grafiği için renk paletinin belirlenmesi
my_palette <- c("#fde724", "#5cc862", "#20908c", "#3b528b", "#440154", "#f15c80")

con <- dbConnect(
  Postgres(),
  dbname = "postgres",
  host = "127.0.0.1",
  user = "postgres",
  password = "135960"
)

# Uygulama ui ve server olmak üzere iki kısımdan oluşmaktadır.
# ui kısmında çıktıların nerede gözükeceğini belirlerken, server kısmında tüm veri manipülasyonları
# ve gereken grafik ve tabloların oluşturulması yapılır.
ui <- fluidPage(
  br(),
  br(),
  column(8,
         fluidRow(
           h2("Ürün Fiyatları Arasındaki Farklar"),
           br(),
           selectInput(
             "kategori",
             "Kategori Seçin",
             choices = unique(tum_veri_kategori$Kategori)
           ),
           plotOutput("violinPlot"),
           br(),
           highchartOutput("Numofmatches")
         )),
  column(4,
         h4("Verilerin Çekilme Tarihi: 04.12.2023",
            style = "float: right;"),
         h2("Eşleşen Ürünler"),
         br(),
         fluidRow(
           selectInput("urunler", "Ürün Seçin", choices = NULL),
           br(),
           reactableOutput("veriTablosu"),
           br(),
           br(),
           br(),
           uiOutput("veriHighchart")
         ))
)


server <- function(input, output, session) {


  # Aktarılan veri setlerini hangi kategoriye ait ise o kategorilere atarız.
    banyobakim <- dbReadTable(con, "banyobakim_verileri")
    bebekodasi <- dbReadTable(con, "bebekodasi_verileri")
    emzirme <- dbReadTable(con, "emzirme_verileri")
    bez <- dbReadTable(con, "bez_verileri")
    guvenlik <- dbReadTable(con, "guvenlik_verileri")
    beslenme <- dbReadTable(con, "beslenme_verileri")
    oyuncak <- dbReadTable(con, "oyuncak_verileri")
    aracgerec <- dbReadTable(con, "aracgerec_verileri")

    # Bir liste oluşturarak veri setinde bulunan kategorileri içeren bir veri yapısı tanımlarız.
    # Listede her bir kategori adını ilgili kategoriye ait veri çerçevesini temsil eden bir nesneye bağlarız.
    kategoriler <- list(
      "Araç Gereç" = aracgerec,
      "Banyo Bakım" = banyobakim,
      "Bebek Odası" = bebekodasi,
      "Emzirme" = emzirme,
      "Bez ve Mendil" = bez,
      "Güvenlik" = guvenlik,
      "Beslenme" = beslenme,
      "Oyuncak" = oyuncak
    )
  # rbindlist() fonksiyonu kullanarak bu kategorileri birleştirip tek bir veri çerçevesine atarız.
  tum_veri_kategori <- rbindlist(kategoriler,
                                 idcol = "Kategori",
                                 fill = TRUE) # "fill" kategoriler arasındaki farklı sütun sayılarını dengelemek için eksik sütunları doldurmayı sağlar.

  # "tum_veri_kategori" verisinden belirli sütunları seçerek fiyat farkları ve yüzdelik farkları hesaplar.
  veri_farklar <- tum_veri_kategori %>%
    select(Kategori, ebebek, ebebekfiyat, civil, welcomebaby, babymall, madrenino, bebekhouse,
           civilfiyat, welcomebabyfiyat, babymallfiyat,
           madreninofiyat, bebekhousefiyat) %>%
    mutate(
      Civil_Fiyat_Fark = ebebekfiyat - as.double(civilfiyat),
      Welcomebaby_Fiyat_Fark = ebebekfiyat - as.double(welcomebabyfiyat),
      Babymall_Fiyat_Fark = ebebekfiyat - as.double(babymallfiyat),
      Madrenino_Fiyat_Fark = ebebekfiyat - as.double(madreninofiyat),
      Bebekhouse_Fiyat_Fark = ebebekfiyat - as.double(bebekhousefiyat),
      Civil_Fiyat_Yuzde = (Civil_Fiyat_Fark / ebebekfiyat) * 100,
      Welcomebaby_Fiyat_Yuzde = (Welcomebaby_Fiyat_Fark / ebebekfiyat) * 100,
      Babymall_Fiyat_Yuzde = (Babymall_Fiyat_Fark / ebebekfiyat) * 100,
      Madrenino_Fiyat_Yuzde = (Madrenino_Fiyat_Fark / ebebekfiyat) * 100,
      Bebekhouse_Fiyat_Yuzde = (Bebekhouse_Fiyat_Fark / ebebekfiyat) * 100)

  # Burada veri_farklar veri setini alarak hesaplanan yüzdelik farkların içinde NA var ise bunlarda filtreleme işlemi yapar.
  # Gerekli sütunları çekip bu sütunları Kategori, Firma ve Fiyat Farkları olarak üç sütun haline pivot_longer() ile uzun formata çevirir.
  veri_long <- veri_farklar %>%
    filter(is.na(Civil_Fiyat_Yuzde) | is.na(Welcomebaby_Fiyat_Yuzde) |
             is.na(Babymall_Fiyat_Yuzde) | is.na(Madrenino_Fiyat_Yuzde) |
             is.na(Bebekhouse_Fiyat_Yuzde)) %>%
    select(Kategori, Civil_Fiyat_Yuzde, Welcomebaby_Fiyat_Yuzde,
           Babymall_Fiyat_Yuzde, Madrenino_Fiyat_Yuzde, Bebekhouse_Fiyat_Yuzde)  %>%
    pivot_longer(cols = c(Civil_Fiyat_Yuzde, Welcomebaby_Fiyat_Yuzde,
                          Babymall_Fiyat_Yuzde, Madrenino_Fiyat_Yuzde, Bebekhouse_Fiyat_Yuzde),
                 names_to = "Firma",
                 values_to = "Fiyat_Fark")


  # Kullanıcının kategori dropdown menüsünden bir kategori seçmesini sağlayıp seçim her seferinde değiştiğinde menünün
  # seçeneklerini günceller.
  observe({
    updateSelectInput(session, "urun", choices = unique(tum_veri_kategori$ebebek[tum_veri_kategori$Kategori == input$kategori]))
  })

  # kullanıcının seçtiği kategoriye göre Firmalara ait değerlerin değişmesini aynı zamanda da bu değerlern firma adı ile
  # her güncellemede değişmesini sağlar.
  selected_data <- reactive({
    veri_long %>%
      filter(
        Kategori == input$kategori,
        Firma %in% c("Civil_Fiyat_Yuzde", "Welcomebaby_Fiyat_Yuzde",
                     "Babymall_Fiyat_Yuzde", "Madrenino_Fiyat_Yuzde",
                     "Bebekhouse_Fiyat_Yuzde")) %>%
      mutate(
        Firma = case_when(
          Firma == "Civil_Fiyat_Yuzde" ~ "Civil",
          Firma == "Welcomebaby_Fiyat_Yuzde" ~ "Welcomebaby",
          Firma == "Babymall_Fiyat_Yuzde" ~ "Babymall",
          Firma == "Madrenino_Fiyat_Yuzde" ~ "Madrenino",
          Firma == "Bebekhouse_Fiyat_Yuzde" ~ "Bebekhouse",
          TRUE ~ Firma
        )
      )
  })

  # Keman grafiği için gerekli işlemlerin yapıldığı yer
  output$violinPlot <- renderPlot({
    ggplot(selected_data(), aes(x = Firma, y = Fiyat_Fark, fill = Firma)) +
      geom_rect(aes(xmin = Inf, xmax = -Inf, ymin = -Inf, ymax = 0), fill = "#ffffff", alpha = 0.01) +
      geom_rect(aes(xmin = Inf, xmax = -Inf, ymin = 0, ymax = Inf), fill = "#c8ccc9", alpha = 0.01) +
      geom_violin(aes(fill = Firma), scale = "width") +
      geom_boxplot(width = 0.1, fill = "white", color = "black") +
      labs(x = "", y = "Fiyat Değişimi (%)", title = paste("Fiyat Değişimleri -", input$kategori)) +
      scale_fill_viridis(discrete = TRUE) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(hjust = 1, size = 20, face = "bold"),
        axis.text.y = element_text(size = 18, face = "bold"),
        axis.title.x = element_text(size = 20, face = "bold"),
        axis.title.y = element_text(size = 20, face = "bold"),
        plot.title = element_text(size = 20, face = "bold")) +
      coord_flip() +
      guides(fill = FALSE)
  })


  # Kategori bazlı eşleşen ürün saylarının veri manipülasyonu
  firma_sayisi <-reactive({
    selected_data() %>%
      group_by(Kategori, Firma) %>%
      summarize(Firma_Sayisi = n_distinct(Fiyat_Fark)) %>%
      filter(Kategori == input$kategori) %>%
      arrange(desc(Firma_Sayisi))
  })

  # Eşleşen ürün sayılarının grafiği
  output$Numofmatches <- renderHighchart({
    firma_sayisi <- firma_sayisi()

    highchart() %>%
      hc_chart(type = "bar") %>%
      hc_title(text = "Her Kategoriye Göre Farklı Firmalar İle Eşleşen Ürün Sayıları",
               style = list(fontWeight = "bold")) %>%
      hc_xAxis(categories = firma_sayisi$Firma,
               style = list(fontSize = "16px")) %>%
      hc_yAxis(
        title = list(
          text = "Eşleşen Ürün Sayısı",
          style = list(fontSize = "18px")
        ),
        labels = list(
          style = list(fontSize = "16px")
        )) %>%
      hc_add_series(name = "Eşleşen Ürün Sayısı", data = firma_sayisi$Firma_Sayisi, color = "#808080") %>%
      hc_tooltip(valueSuffix = " adet") %>%
      hc_legend(enabled = FALSE) %>%
      hc_exporting(enabled = TRUE)

  })


  # Her kategoriye ait ürünleri güncellenecek şekilde seçmemize yardımcı olur.
  observe({
    updateSelectInput(session, "urunler",
                      choices = unique(veri_farklar$ebebek[veri_farklar$Kategori == input$kategori]))
  })

  # Kategorilere ait ürünleri eşler.
  selected_product <- reactive({
    veri_farklar %>%
      filter(Kategori == input$kategori, ebebek == input$urunler)
  })

  # Ürünler için belirli değişkenler seçilip uzun formata  Firma ve Üürnler olacak şekilde ikiye ayrılmıştır.
  data_pivot <- reactive({
    selected_product() %>%
      select(ebebek, ebebekfiyat, civil, welcomebaby, babymall, madrenino, bebekhouse,
             civilfiyat, welcomebabyfiyat, babymallfiyat, madreninofiyat, bebekhousefiyat) %>%
      pivot_longer(cols = c(ebebek, civil, welcomebaby, babymall, madrenino, bebekhouse),
                   names_to = "Firma",
                   values_to = "Ürünler") %>%
      mutate(Firma = ifelse(Firma == "ebebek", "ebebek", # Firmaların isimlerinde düzenleme yapılması
                            ifelse(Firma == "civil", "Civil",
                                   ifelse(Firma == "welcomebaby", "Welcomebaby",
                                          ifelse(Firma == "babymall", "Babymall",
                                                 ifelse(Firma == "madrenino", "Madrenino",
                                                        ifelse(Firma == "bebekhouse", "Bebekhouse", Firma)
                                                 )
                                          )
                                   )
                            )
      ),
      Fiyatlar = case_when(
        Firma == "ebebek" & !is.na(ebebekfiyat) ~ paste0(ebebekfiyat, " TL"), # Fiyatlarında yanında " TL" yazmasını sağlar.
        Firma == "Civil" & !is.na(civilfiyat) ~ paste0(civilfiyat, " TL"),
        Firma == "Welcomebaby" & !is.na(welcomebabyfiyat) ~ paste0(welcomebabyfiyat, " TL"),
        Firma == "Babymall" & !is.na(babymallfiyat) ~ paste0(babymallfiyat, " TL"),
        Firma == "Madrenino" & !is.na(madreninofiyat) ~ paste0(madreninofiyat, " TL"),
        Firma == "Bebekhouse" & !is.na(bebekhousefiyat) ~ paste0(bebekhousefiyat, " TL"),
        TRUE ~ NA_character_
      )) %>%
      select(-c(ebebekfiyat, civilfiyat, welcomebabyfiyat, babymallfiyat, madreninofiyat, bebekhousefiyat)) %>%
      na.omit() %>% # NA değerlerini çıkarır.
      distinct() # Ürünleri eşsizleştirir.
  })

  # Eşleşen ürünlerin tablosunun oluşturulması
  output$veriTablosu <- renderReactable({
    reactable(
      data_pivot(),
      filterable = TRUE,
      sortable = FALSE,
      showSortable = TRUE,
      columns = list(
        Fiyatlar = colDef(filterable = FALSE)
      )
    )
  })


  # Eşleşen ürünler varsa onların grafiğini, yok ise olmadığına dair bir yazı ile bilgi veren bir if-else yapısıdır.
  output$veriHighchart <- renderUI({
    pivoted_data <- data_pivot()

    num_prices <- sapply(pivoted_data$Fiyatlar, function(x) length(unlist(strsplit(x, " "))))
    multiple_prices <- sum(num_prices > 1)

    if (multiple_prices > 1) {
      renderHighchart({
        highchart() %>%
          hc_chart(type = "column") %>%
          hc_xAxis(categories = pivoted_data$Firma) %>%
          hc_add_series(name = "Fiyatlar",
                        data = as.numeric(gsub(" TL", "", pivoted_data$Fiyatlar)),
                        style = list(fontWeight = "bold")) %>%
          hc_plotOptions(column = list(colorByPoint = TRUE,
                                       colors = my_palette,
                                       dataLabels = list(enabled = TRUE,
                                                         format = "{point.y} TL"))) %>%
          hc_yAxis(title = list(text = "Fiyatlar")) %>%
          hc_tooltip(valueSuffix = " TL") %>%
          hc_title(text = "Ürün Fiyatları",
                   style = list(fontWeight = "bold")) %>%
          hc_legend(enabled = FALSE) %>%
          hc_exporting(enabled = TRUE)
      })
    } else {
      div(style = "font-size: 18px; font-weight: bold;",
          "Herhangi bir ürün ile eşleştirme bulunmamaktadır.")
    }
  })

  dbDisconnect(con)

}

shinyApp(ui, server)

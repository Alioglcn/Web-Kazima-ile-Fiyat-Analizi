Kod için gerekli olan modulleri kullanabilmek için öncelikle moduleVersions.txt dosyasının erişilebilir olduğundan emin olun. Ardından aşağıdaki komutu terminalde çalıştırın.

pip install -r moduleVersions.txt

main() içerisinde yer alan excel_file ve keywords_file sırasıyla kullanılacak olan eşleşme veri seti ve etiket veri setine erişir. Güncellenmek istenen kategorinin eşleşme veri seti ve etiket veri seti burada belirtilmelidir.


VersionForDB.py : Verileri databasedan çeker ve işler


# 🚀 GitHub'a Push - Adım Adım

## 📋 YAPILACAKLAR:

### 1. GitHub Repository Oluşturun

1. **https://github.com** → **"New repository"** (sağ üstte + işareti)
2. **Repository name:** `Speedmail`
3. **Public** seçin (ücretsiz için gerekli)
4. **"Create repository"** butonuna tıklayın
5. **Repository URL'ini kopyalayın** (örnek: `https://github.com/YOUR_USERNAME/Speedmail.git`)

---

### 2. Terminal'de Git Komutları

**Terminal'de şu komutları sırayla çalıştırın:**

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail

# Git başlat
git init

# GitHub repository'nizi ekleyin (YOUR_USERNAME yerine kendi kullanıcı adınızı yazın)
git remote add origin https://github.com/YOUR_USERNAME/Speedmail.git

# Dosyaları ekleyin
git add .

# Commit yapın
git commit -m "Initial commit - Speedmail backend"

# GitHub'a push edin
git branch -M main
git push -u origin main
```

**NOT:** Eğer `main` branch hatası alırsanız:
```bash
git push -u origin master
```

---

### 3. GitHub'a Push Ettikten Sonra

GitHub repository'nize gidin ve dosyaların yüklendiğini kontrol edin.

**Sonra Render.com'a deploy edeceğiz!**

---

**GitHub repository oluşturduktan sonra repository URL'ini paylaşın!** 🚀


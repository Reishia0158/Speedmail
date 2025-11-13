# 🔧 Gmail Watch Hata Çözümü

## ❌ HATA:
```
Invalid topicName does not match projects/speedmail-477818/topics/*
```

Topic ve subscription doğru project'te (`speedmail-2e849`) ama hata `speedmail-477818` gösteriyor.

## 🔍 SORUN:

OAuth token'ı **yanlış project'ten** geliyor olabilir veya **Gmail API yanlış project'te enable** olabilir.

## ✅ ÇÖZÜM:

### 1. Gmail API'yi Doğru Project'te Aktif Et:

1. **Gmail API sayfasına gidin:**
   ```
   https://console.cloud.google.com/apis/library/gmail.googleapis.com?project=speedmail-2e849
   ```

2. **"ENABLE" butonuna tıklayın** (eğer aktif değilse)

### 2. OAuth Client ID'yi Kontrol Et:

1. **Credentials sayfasına gidin:**
   ```
   https://console.cloud.google.com/apis/credentials?project=speedmail-2e849
   ```

2. **OAuth 2.0 Client ID'lerinizi kontrol edin:**
   - iOS Client ID: `speedmail-2e849` project'inde olmalı
   - Web Application Client ID: `speedmail-2e849` project'inde olmalı

3. **Eğer yanlış project'teyse:**
   - Doğru project'te (`speedmail-2e849`) yeni OAuth Client ID oluşturun
   - iOS uygulamasında Client ID'yi güncelleyin

### 3. OAuth Consent Screen'i Kontrol Et:

1. **OAuth consent screen sayfasına gidin:**
   ```
   https://console.cloud.google.com/apis/credentials/consent?project=speedmail-2e849
   ```

2. **Project ID'nin `speedmail-2e849` olduğundan emin olun**

### 4. iOS'ta OAuth Client ID'yi Kontrol Et:

1. Xcode'da `GoogleOAuth.swift` dosyasını açın
2. Client ID'nin doğru olduğundan emin olun:
   ```
   941741001921-4k3bf7fucru39jgdtmovdiiap0hi26dk.apps.googleusercontent.com
   ```

### 5. Backend Loglarını Kontrol Et:

Backend'de hangi project ID kullanıldığını kontrol edin:
```bash
fly logs -a speedmail-backend | grep "GOOGLE_PROJECT_ID\|topicName"
```

---

## 🎯 HIZLI KONTROL:

### Topic'in Project'ini Kontrol Et:
1. Subscription detay sayfasında **"Topic name"** linkine tıklayın
2. URL'deki project ID'yi kontrol edin:
   - Doğru: `?project=speedmail-2e849`
   - Yanlış: `?project=speedmail-477818`

### OAuth Token'ın Project'ini Kontrol Et:
1. iOS uygulamasında Gmail hesabını bağlarken hangi OAuth Client ID kullanılıyor?
2. Bu Client ID hangi project'te?

---

## 📝 NOT:

Eğer OAuth token yanlış project'ten geliyorsa:
1. iOS uygulamasından Gmail hesabını çıkarın
2. Doğru project'te (`speedmail-2e849`) OAuth Client ID oluşturun
3. iOS uygulamasında Client ID'yi güncelleyin
4. Gmail hesabını tekrar bağlayın

---

**Topic'in project'ini ve OAuth Client ID'nin project'ini kontrol edin!** 🚀


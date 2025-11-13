# 🔍 OAuth Project ID Kontrolü

## ❌ SORUN:

Gmail Watch hatası: `speedmail-477818` project'i gösteriyor
Backend'de: `GOOGLE_PROJECT_ID = speedmail-2e849` ✅
Topic: `speedmail-2e849` project'inde ✅

**Ama OAuth token yanlış project'ten geliyor olabilir!**

## 🔍 KONTROL:

### 1. OAuth Client ID'nin Project'ini Kontrol Et:

1. **Credentials sayfasına gidin:**
   ```
   https://console.cloud.google.com/apis/credentials?project=speedmail-2e849
   ```

2. **iOS Client ID'yi bulun:**
   - Client ID: `941741001921-4k3bf7fucru39jgdtmovdiiap0hi26dk.apps.googleusercontent.com`
   - Bu Client ID hangi project'te?

3. **Eğer yanlış project'teyse:**
   - Doğru project'te (`speedmail-2e849`) yeni iOS Client ID oluşturun
   - `GoogleService-Info.plist` dosyasını güncelleyin

### 2. GoogleService-Info.plist'i Güncelle:

1. **Doğru project'te (`speedmail-2e849`) iOS Client ID oluşturun:**
   - https://console.cloud.google.com/apis/credentials?project=speedmail-2e849
   - "+ CREATE CREDENTIALS" → "OAuth client ID"
   - Application type: **iOS**
   - Bundle ID: `com.yunuskaynarpinar.Speedmail`
   - CREATE → Client ID'yi kopyalayın

2. **GoogleService-Info.plist'i güncelleyin:**
   - Xcode'da `GoogleService-Info.plist` dosyasını açın
   - `CLIENT_ID` değerini yeni Client ID ile değiştirin
   - `REVERSED_CLIENT_ID` değerini güncelleyin

### 3. Gmail Hesabını Yeniden Bağla:

1. iOS uygulamasından Gmail hesabını çıkarın
2. Uygulamayı yeniden başlatın
3. Gmail hesabını tekrar bağlayın (yeni OAuth token ile)

---

## 🎯 ALTERNATİF ÇÖZÜM:

Eğer OAuth Client ID'yi değiştirmek istemiyorsanız:

**Backend'de topic project ID'sini OAuth token'ın project'inden al:**

Backend kodunu güncelleyebilirim, ama bu daha karmaşık. En kolay çözüm: OAuth Client ID'yi doğru project'te oluşturmak.

---

**OAuth Client ID'nin hangi project'te olduğunu kontrol edin!** 🚀


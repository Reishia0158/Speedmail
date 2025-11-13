# 🔑 Client Secret Güncelleme

## ❌ HATA:
```
❌ Gmail watch hatası: {"error":"invalid_client"}
```

## 🔍 SORUN:

Yeni OAuth Client ID (`334956961779-9eesr67i7gji93iseiul2kld2cmuns1p`) için **Client Secret** eksik veya yanlış.

## ✅ ÇÖZÜM:

### Adım 1: Google Cloud Console'da Client Secret'ı Bulun

1. **Credentials sayfasına gidin:**
   ```
   https://console.cloud.google.com/apis/credentials?project=speedmail-2e849
   ```

2. **OAuth 2.0 Client ID'lerinizi bulun:**
   - Client ID: `334956961779-9eesr67i7gji93iseiul2kld2cmuns1p` (iOS)
   - **Web Application** Client ID'yi bulun (Gmail Watch için gerekli)

3. **Web Application Client ID'yi açın:**
   - Client ID'nin yanındaki **✏️ Edit** (kalem) ikonuna tıklayın
   - **Client secret** değerini kopyalayın
   - Eğer "Reset secret" yazıyorsa, secret'ı görmek için "RESET" butonuna tıklayın

### Adım 2: Client Secret'ı Backend'e Ekleyin

Terminal'de şu komutu çalıştırın (Client Secret'ı kendi değerinizle değiştirin):

```bash
fly secrets set GOOGLE_CLIENT_SECRET="GOCSPX-..." -a speedmail-backend
```

**ÖNEMLİ:** Client Secret'ı **tamamen** kopyalayın (başında `GOCSPX-` ile başlar).

---

## 🎯 ALTERNATİF: Yeni Web Application Client ID Oluşturun

Eğer Web Application Client ID yoksa:

1. **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. **Application type:** **Web application**
3. **Name:** `Speedmail Backend` (veya istediğiniz bir isim)
4. **Authorized redirect URIs:** (boş bırakabilirsiniz, Gmail Watch için gerekli değil)
5. **CREATE** → Client ID ve Client Secret'ı kopyalayın

---

## 📝 NOT:

- **iOS Client ID:** OAuth için kullanılır (zaten güncellendi ✅)
- **Web Application Client ID:** Backend'de Gmail Watch için kullanılır (Client Secret gerekli)

Her ikisi de **aynı project'te** (`speedmail-2e849`) olmalı!

---

**Client Secret'ı bulduktan sonra bana gönderin, backend'e ekleyeyim!** 🚀


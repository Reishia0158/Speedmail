# 🚂 Railway.app Deployment Kılavuzu

## 📋 ADIM ADIM KURULUM:

### 1. Railway.app Hesabı Oluşturun

1. **Railway.app'e gidin:**
   ```
   https://railway.app
   ```

2. **"Start a New Project"** → **"Login"** (GitHub ile giriş yapın)

3. **"New Project"** → **"Deploy from GitHub repo"**

---

### 2. GitHub Repository'yi Bağlayın

1. **GitHub hesabınızı bağlayın** (ilk kez ise)

2. **Repository seçin:**
   - `Speedmail` repository'sini seçin
   - **"Deploy Now"** butonuna tıklayın

3. **Root Directory ayarlayın:**
   - Railway.app otomatik olarak `backend` klasörünü bulamayabilir
   - **Settings** → **Root Directory:** `backend` yazın

---

### 3. Environment Variables Ekleyin

Railway.app dashboard'da **Variables** sekmesine gidin ve şu değişkenleri ekleyin:

#### APNs Configuration:
```
APNS_KEY_BASE64=<base64_encoded_apns_key>
APNS_KEY_ID=HH9Z3X32PQ
APNS_TEAM_ID=<your_team_id>
APNS_BUNDLE_ID=com.yunuskaynarpinar.Speedmail
```

#### Google Cloud Configuration:
```
GOOGLE_PROJECT_ID=speedmail-2e849
GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=YOUR_GOOGLE_CLIENT_SECRET
```

#### Server Configuration:
```
NODE_ENV=production
PORT=3000
```

---

### 4. APNS_KEY_BASE64 Oluşturma

Terminal'de şu komutu çalıştırın:

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail
base64 -i AuthKey_HH9Z3X32PQ.p8 | pbcopy
```

Bu komut base64 encoded key'i clipboard'a kopyalar. Railway.app'de `APNS_KEY_BASE64` değişkenine yapıştırın.

---

### 5. Domain ve URL

1. Railway.app otomatik olarak bir domain oluşturur:
   - Örnek: `speedmail-backend-production.up.railway.app`

2. **Settings** → **Generate Domain** ile özel domain oluşturabilirsiniz

3. **URL'i kopyalayın** (iOS uygulamasında kullanacağız)

---

### 6. iOS Uygulamasını Güncelleyin

Railway.app URL'ini iOS uygulamasına ekleyeceğim.

---

## ✅ KONTROL:

Deployment tamamlandıktan sonra:

1. **Logs** sekmesinde şunu görmelisiniz:
   ```
   🚀 Speedmail Backend çalışıyor: http://0.0.0.0:3000
   📱 APNs: Yapılandırıldı
   🌍 Railway.app: Deployed on Railway
   ```

2. **Health check:**
   ```
   https://your-railway-url.railway.app/health
   ```
   Şunu görmelisiniz: `{"status":"OK","timestamp":"..."}`

---

## 🔧 SORUN GİDERME:

### Root Directory Bulunamıyor:
- **Settings** → **Root Directory:** `backend` yazın

### Port Hatası:
- Railway.app otomatik olarak `PORT` environment variable'ını ayarlar
- Kod zaten `process.env.PORT` kullanıyor ✅

### APNs Key Hatası:
- `APNS_KEY_BASE64` doğru base64 encoded olmalı
- Terminal'de `base64 -i AuthKey_HH9Z3X32PQ.p8` ile kontrol edin

---

**Railway.app'e deploy ettikten sonra URL'i paylaşın, iOS uygulamasını güncelleyeyim!** 🚀


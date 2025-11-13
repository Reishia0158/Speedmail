# 🚂 Railway.app Hızlı Başlangıç

## 📋 YAPILACAKLAR (Sırayla):

### 1. Railway.app Hesabı Oluşturun

1. **https://railway.app** → **"Start a New Project"**
2. **GitHub ile giriş yapın**
3. **"New Project"** → **"Deploy from GitHub repo"**
4. **Speedmail repository'sini seçin**

---

### 2. Root Directory Ayarlayın

1. Railway.app dashboard'da **Settings** sekmesine gidin
2. **Root Directory:** `backend` yazın
3. **Save** butonuna tıklayın

---

### 3. Environment Variables Ekleyin

**Variables** sekmesine gidin ve şu değişkenleri ekleyin:

#### APNs:
- `APNS_KEY_BASE64` = (aşağıdaki komuttan alacaksınız)
- `APNS_KEY_ID` = `HH9Z3X32PQ`
- `APNS_TEAM_ID` = (Apple Developer hesabınızdan)
- `APNS_BUNDLE_ID` = `com.yunuskaynarpinar.Speedmail`

#### Google Cloud:
- `GOOGLE_PROJECT_ID` = `speedmail-2e849`
- `GOOGLE_CLIENT_ID` = `YOUR_GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET` = `YOUR_GOOGLE_CLIENT_SECRET`

#### Server:
- `NODE_ENV` = `production`
- `PORT` = `3000` (Railway.app otomatik ayarlar, ama ekleyebilirsiniz)

---

### 4. APNS_KEY_BASE64 Oluşturun

Terminal'de şu komutu çalıştırın:

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail
base64 -i AuthKey_HH9Z3X32PQ.p8
```

Çıkan uzun metni kopyalayın ve Railway.app'de `APNS_KEY_BASE64` değişkenine yapıştırın.

---

### 5. Deployment Bekleyin

Railway.app otomatik olarak:
- ✅ Dependencies yükler
- ✅ Backend'i başlatır
- ✅ URL oluşturur

**Logs** sekmesinde şunu görmelisiniz:
```
🚀 Speedmail Backend çalışıyor: http://0.0.0.0:3000
📱 APNs: Yapılandırıldı
🌍 Railway.app: Deployed on Railway
```

---

### 6. URL'i Kopyalayın

Railway.app otomatik olarak bir URL oluşturur:
- Örnek: `speedmail-backend-production.up.railway.app`

**Settings** → **Generate Domain** ile özel domain oluşturabilirsiniz.

**URL'i kopyalayın ve bana gönderin, iOS uygulamasını güncelleyeyim!**

---

## ✅ KONTROL:

Deployment tamamlandıktan sonra:

1. **Health check:**
   ```
   https://your-railway-url.railway.app/health
   ```
   Şunu görmelisiniz: `{"status":"OK","timestamp":"..."}`

2. **Logs kontrol:**
   - Hata yoksa ✅
   - APNs yapılandırıldı mesajı görünmeli ✅

---

**Railway.app'e deploy ettikten sonra URL'i paylaşın!** 🚀


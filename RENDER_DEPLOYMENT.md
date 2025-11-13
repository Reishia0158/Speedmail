# 🎨 Render.com Free Tier Deployment

## ✅ AVANTAJLAR:

- ✅ **Tamamen ücretsiz**
- ✅ **Kolay deployment** (GitHub bağlantısı)
- ✅ **Otomatik HTTPS**
- ✅ **Node.js desteği**
- ⚠️ Sleep olabilir ama **Gmail Watch webhook'ları uyandırır**

---

## 📋 ADIM ADIM KURULUM:

### 1. Render.com Hesabı Oluşturun

1. **https://render.com** → **"Get Started for Free"**
2. **GitHub ile giriş yapın**
3. **"New +"** → **"Web Service"**

---

### 2. GitHub Repository'yi Bağlayın

1. **"Connect GitHub"** → **Speedmail repository'sini seçin**
2. **Settings:**
   - **Name:** `speedmail-backend`
   - **Root Directory:** `backend`
   - **Environment:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`

---

### 3. Environment Variables Ekleyin

**Environment** sekmesine gidin ve şu değişkenleri ekleyin:

#### APNs:
```
APNS_KEY_BASE64=LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZzBRbHYwd09YZlZKUzRCbTAKaEU5UW9YaHhxSzJsMzQycTJGNG1HZUs3Q2s2Z0NnWUlLb1pJemowREFRZWhSQU5DQUFSUDgrcWp0U0F2Z2lHOQphNTdSbmsyTUIvWjRvbnkyeWtvYXJJT0E4K2ROMlYxUkt6U3QxM01EQVpHc2RSa3FCalBobnBWQmp1VHI4emNKCkptUGo5YkVPCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=
APNS_KEY_ID=HH9Z3X32PQ
APNS_TEAM_ID=<your_team_id>
APNS_BUNDLE_ID=com.yunuskaynarpinar.Speedmail
```

#### Google Cloud:
```
GOOGLE_PROJECT_ID=speedmail-2e849
GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=YOUR_GOOGLE_CLIENT_SECRET
```

#### Server:
```
NODE_ENV=production
PORT=3000
```

---

### 4. Deploy Edin

1. **"Create Web Service"** butonuna tıklayın
2. Render.com otomatik olarak:
   - ✅ Dependencies yükler
   - ✅ Backend'i başlatır
   - ✅ URL oluşturur

---

### 5. URL'i Kopyalayın

Render.com otomatik olarak bir URL oluşturur:
- Örnek: `speedmail-backend.onrender.com`

**URL'i kopyalayın ve bana gönderin, iOS uygulamasını güncelleyeyim!**

---

## ⚠️ SLEEP DURUMU:

Render.com free tier **15 dakika kullanılmazsa sleep olur**.

**AMA:**
- ✅ **Gmail Watch webhook'ları** backend'i uyandırır
- ✅ İlk istekte 30 saniye uyanma süresi var
- ✅ Bildirimler için yeterli olabilir

**Eğer sorun olursa:**
- Oracle Cloud Free Tier'a geçeriz (tamamen ücretsiz, always-on)

---

## ✅ KONTROL:

Deployment tamamlandıktan sonra:

1. **Logs** sekmesinde şunu görmelisiniz:
   ```
   🚀 Speedmail Backend çalışıyor: http://0.0.0.0:3000
   📱 APNs: Yapılandırıldı
   ```

2. **Health check:**
   ```
   https://speedmail-backend.onrender.com/health
   ```
   Şunu görmelisiniz: `{"status":"OK","timestamp":"..."}`

---

**Render.com'a deploy ettikten sonra URL'i paylaşın!** 🚀


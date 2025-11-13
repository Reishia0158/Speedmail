# 🎨 Render.com - Adım Adım Kurulum

## 📋 ŞU AN YAPILACAKLAR:

### 1. Repository Seçimi

**Eğer Speedmail repository'si listede görünüyorsa:**
- ✅ **Speedmail** repository'sine tıklayın

**Eğer Speedmail repository'si listede görünmüyorsa:**
- ✅ **"Public Git Repository"** sekmesine tıklayın
- ✅ GitHub repository URL'ini girin:
  ```
  https://github.com/YOUR_USERNAME/Speedmail
  ```
  (YOUR_USERNAME yerine kendi GitHub kullanıcı adınızı yazın)

---

### 2. Service Type

- **"Select a service type"** → **"Web Service"** seçili olmalı ✅
- (Zaten seçili görünüyor)

---

### 3. Name

- **"Name"** alanına yazın:
  ```
  speedmail-backend
  ```

---

### 4. Settings (ÖNEMLİ!)

**"Advanced"** butonuna tıklayın ve şunları ayarlayın:

- **Root Directory:** `backend`
- **Environment:** `Node`
- **Build Command:** `npm install`
- **Start Command:** `npm start`

---

### 5. Environment Variables

**"Environment"** sekmesine gidin ve şu değişkenleri ekleyin:

#### APNs:
```
APNS_KEY_BASE64=LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZzBRbHYwd09YZlZKUzRCbTAKaEU5UW9YaHhxSzJsMzQycTJGNG1HZUs3Q2s2Z0NnWUlLb1pJemowREFRZWhSQU5DQUFSUDgrcWp0U0F2Z2lHOQphNTdSbmsyTUIvWjRvbnkyeWtvYXJJT0E4K2ROMlYxUkt6U3QxM01EQVpHc2RSa3FCalBobnBWQmp1VHI4emNKCkptUGo5YkVPCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=
APNS_KEY_ID=HH9Z3X32PQ
APNS_TEAM_ID=YOUR_TEAM_ID
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

### 6. Deploy

- **"Create Web Service"** butonuna tıklayın
- Render.com otomatik olarak deploy edecek (2-3 dakika)

---

## ✅ KONTROL:

Deployment tamamlandıktan sonra:

1. **Logs** sekmesinde şunu görmelisiniz:
   ```
   🚀 Speedmail Backend çalışıyor: http://0.0.0.0:3000
   📱 APNs: Yapılandırıldı
   ```

2. **URL'i kopyalayın:**
   - Örnek: `speedmail-backend.onrender.com`
   - **Bu URL'i bana gönderin, iOS uygulamasını güncelleyeyim!**

---

**Speedmail repository'sini seçin veya "Public Git Repository" sekmesine geçin!** 🚀


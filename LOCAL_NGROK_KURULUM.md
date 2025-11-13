# 🏠 Local Backend + ngrok Kurulumu

## ✅ AVANTAJLAR:

- ✅ **Tamamen ücretsiz**
- ✅ **GitHub'a push etmeye gerek yok**
- ✅ **Always-on** (bilgisayar açıkken)
- ✅ **Kolay kurulum** (5 dakika)

---

## 📋 ADIM ADIM KURULUM:

### 1. ngrok Kurulumu

#### macOS için:

```bash
# Homebrew ile kurulum
brew install ngrok/ngrok/ngrok

# Veya manuel kurulum
# https://ngrok.com/download → macOS indirin
# ZIP'i açın, ngrok'u /usr/local/bin/ klasörüne taşıyın
```

#### Kurulum Kontrolü:

```bash
ngrok version
```

✅ `ngrok version 3.x.x` görmelisiniz.

---

### 2. ngrok Hesabı Oluşturun

1. **https://ngrok.com** → **"Sign up"** (ücretsiz)
2. **Email ile kayıt olun**
3. **Dashboard'a gidin** → **"Your Authtoken"** kopyalayın

---

### 3. ngrok Authtoken Ayarlayın

Terminal'de:

```bash
ngrok config add-authtoken YOUR_AUTHTOKEN
```

(YOUR_AUTHTOKEN yerine kopyaladığınız token'ı yazın)

---

### 4. Backend'i Local'de Çalıştırın

Terminal'de (backend klasöründe):

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail/backend

# Environment variables ayarlayın
export APNS_KEY_BASE64="LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZzBRbHYwd09YZlZKUzRCbTAKaEU5UW9YaHhxSzJsMzQycTJGNG1HZUs3Q2s2Z0NnWUlLb1pJemowREFRZWhSQU5DQUFSUDgrcWp0U0F2Z2lHOQphNTdSbmsyTUIvWjRvbnkyeWtvYXJJT0E4K2ROMlYxUkt6U3QxM01EQVpHc2RSa3FCalBobnBWQmp1VHI4emNKCkptUGo5YkVPCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0="
export APNS_KEY_ID="HH9Z3X32PQ"
export APNS_TEAM_ID="YOUR_TEAM_ID"
export APNS_BUNDLE_ID="com.yunuskaynarpinar.Speedmail"
export GOOGLE_PROJECT_ID="speedmail-2e849"
export GOOGLE_CLIENT_ID="YOUR_GOOGLE_CLIENT_ID"
export GOOGLE_CLIENT_SECRET="YOUR_GOOGLE_CLIENT_SECRET"
export NODE_ENV="production"
export PORT="3000"

# Backend'i başlatın
npm install
node server.js
```

✅ Şunu görmelisiniz:
```
🚀 Speedmail Backend çalışıyor: http://0.0.0.0:3000
📱 APNs: Yapılandırıldı
```

**Bu terminal penceresini açık bırakın!**

---

### 5. ngrok ile Public URL Oluşturun

**Yeni bir terminal penceresi açın** ve:

```bash
ngrok http 3000
```

✅ Şunu görmelisiniz:
```
Forwarding  https://xxxx-xx-xxx-xxx-xx.ngrok-free.app -> http://localhost:3000
```

**Bu URL'i kopyalayın!** (Örnek: `https://abc123.ngrok-free.app`)

**Bu terminal penceresini de açık bırakın!**

---

### 6. iOS Uygulamasını Güncelleyin

ngrok URL'ini iOS uygulamasında kullanacağız.

---

## ⚠️ ÖNEMLİ NOTLAR:

### ngrok Free Tier Sınırlamaları:

- ⚠️ **Her restart'ta URL değişir**
- ⚠️ **8 saat session limiti** (ücretsiz tier)
- ⚠️ **Connection limiti** (40 connection/dakika)

### Çözüm:

1. **ngrok URL'i değiştiğinde:**
   - iOS uygulamasındaki backend URL'ini güncelleyin

2. **Session limiti:**
   - 8 saatte bir ngrok'u yeniden başlatın

3. **Daha stabil için:**
   - ngrok paid plan ($8/ay) - sabit domain
   - Veya Render.com'a geçin (GitHub'a push edin)

---

## ✅ KONTROL:

1. **Backend çalışıyor mu?**
   ```
   http://localhost:3000/health
   ```
   Şunu görmelisiniz: `{"status":"OK","timestamp":"..."}`

2. **ngrok URL çalışıyor mu?**
   ```
   https://xxxx.ngrok-free.app/health
   ```
   Şunu görmelisiniz: `{"status":"OK","timestamp":"..."}`

---

## 🚀 BAŞLATMA SCRIPTİ:

Daha kolay için bir script oluşturabilirim:

```bash
#!/bin/bash
# start-backend.sh

cd /Users/yunuskaynarpinar/Desktop/Speedmail/backend

# Environment variables
export APNS_KEY_BASE64="..."
export APNS_KEY_ID="HH9Z3X32PQ"
# ... diğerleri

# Backend'i başlat
node server.js
```

---

**ngrok'u kurduktan sonra URL'i paylaşın, iOS uygulamasını güncelleyeyim!** 🚀


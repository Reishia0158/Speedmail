# 🚀 Backend + ngrok Başlatma

## ✅ Team ID Eklendi: B79NG6JX9A

Şimdi backend'i başlatıp ngrok ile expose edeceğiz.

---

## 📋 ADIM ADIM:

### 1. Backend'i Başlatın (Terminal 1)

**Yeni bir terminal penceresi açın** ve:

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail
./start-backend.sh
```

**VEYA manuel olarak:**

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail/backend

export APNS_KEY_BASE64="LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZzBRbHYwd09YZlZKUzRCbTAKaEU5UW9YaHhxSzJsMzQycTJGNG1HZUs3Q2s2Z0NnWUlLb1pJemowREFRZWhSQU5DQUFSUDgrcWp0U0F2Z2lHOQphNTdSbmsyTUIvWjRvbnkyeWtvYXJJT0E4K2ROMlYxUkt6U3QxM01EQVpHc2RSa3FCalBobnBWQmp1VHI4emNKCkptUGo5YkVPCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0="
export APNS_KEY_ID="HH9Z3X32PQ"
export APNS_TEAM_ID="B79NG6JX9A"
export APNS_BUNDLE_ID="com.yunuskaynarpinar.Speedmail"
export GOOGLE_PROJECT_ID="speedmail-2e849"
export GOOGLE_CLIENT_ID="YOUR_GOOGLE_CLIENT_ID"
export GOOGLE_CLIENT_SECRET="YOUR_GOOGLE_CLIENT_SECRET"
export NODE_ENV="production"
export PORT="3000"

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

### 2. ngrok Başlatın (Terminal 2)

**Yeni bir terminal penceresi açın** ve:

```bash
ngrok http 3000
```

✅ Şunu görmelisiniz:
```
Session Status                online
Account                       YOUR_EMAIL (Plan: Free)
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://xxxx-xx-xxx-xxx-xx.ngrok-free.app -> http://localhost:3000
```

**"Forwarding" satırındaki URL'i kopyalayın!** (Örnek: `https://abc123.ngrok-free.app`)

**Bu terminal penceresini de açık bırakın!**

---

### 3. Test Edin

Tarayıcıda şu URL'i açın:

```
https://YOUR_NGROK_URL.ngrok-free.app/health
```

✅ Şunu görmelisiniz: `{"status":"OK","timestamp":"..."}`

---

### 4. ngrok URL'ini Paylaşın

ngrok URL'ini paylaşın, iOS uygulamasını güncelleyeyim!

---

## ⚠️ ÖNEMLİ NOTLAR:

### ngrok URL Değişikliği:

- ⚠️ **Her restart'ta URL değişir**
- ⚠️ **8 saat session limiti** (ücretsiz tier)

**Çözüm:**
- URL değiştiğinde iOS uygulamasındaki backend URL'ini güncelleyin

### Backend Çalışırken:

- ✅ **Backend terminal penceresini açık bırakın**
- ✅ **ngrok terminal penceresini açık bırakın**
- ✅ **Bilgisayarınız açık olmalı**

---

**Backend ve ngrok'u başlattıktan sonra ngrok URL'ini paylaşın!** 🚀


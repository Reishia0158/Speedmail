# Speedmail Backend - APNs Push Notifications

## 🚀 Kurulum

### 1. Bağımlılıkları yükle:
```bash
cd backend
npm install
```

### 2. APNs Key'i ekle:
- `AuthKey_XXXXXXXXXX.p8` dosyasını bu klasöre kopyalayın

### 3. Environment değişkenlerini ayarla:
```bash
cp env.example .env
# .env dosyasını düzenleyin
```

### 4. Lokal test:
```bash
npm run dev
```

## 📦 Railway'e Deploy

### 1. Railway hesabı oluştur:
```
https://railway.app
```

### 2. GitHub ile bağlan ve projeyi deploy et

### 3. Environment değişkenlerini ekle:
- Railway dashboard'dan tüm .env değişkenlerini ekleyin
- `AuthKey_XXXXXXXXXX.p8` dosyasını Railway'e yükleyin

## 🔗 Endpoints

- `POST /gmail-webhook` - Gmail Pub/Sub webhook
- `POST /register-device` - iOS device token kaydet
- `POST /setup-gmail-watch` - Gmail watch başlat
- `GET /health` - Health check


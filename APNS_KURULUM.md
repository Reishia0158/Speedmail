# 🚀 APNs Gerçek Zamanlı Bildirim Kurulumu

## ✅ HAZIRLIK (Tamamlandı)
- ✅ iOS kodu hazır (`APNsManager.swift`, `AppDelegate.swift`)
- ✅ Backend kodu hazır (`backend/server.js`)
- ✅ Info.plist yapılandırıldı

---

## 📋 ADIM 1: Apple Developer Portal - APNs Key (5 dakika)

### 1. APNs Key Oluştur:

1. **Apple Developer Portal'a gidin:**
   ```
   https://developer.apple.com/account/resources/authkeys/list
   ```

2. **"+" butonuna tıklayın** (Create a Key)

3. **Key Name:** `Speedmail APNs Key`

4. **Apple Push Notifications service (APNs)** ✅ işaretleyin

5. **Continue** → **Register** → **Download**
   - `AuthKey_XXXXXXXXXX.p8` dosyasını indirin
   - ⚠️ **ÖNEMLİ:** Bu dosyayı **kaydedin**, bir daha indiremezsiniz!

6. **Notları alın:**
   - **Key ID:** İndirme sayfasında (10 karakter, ör: `AB12CD34EF`)
   - **Team ID:** Sağ üst köşede (10 karakter, ör: `1234567890`)

---

## 📋 ADIM 2: Xcode - Push Notification Capability (2 dakika)

### 1. Xcode'da Projeyi Açın:
- `Speedmail.xcodeproj` dosyasını açın

### 2. Capability Ekle:
1. Sol panelde **Speedmail** projesini seçin
2. **TARGETS** → **Speedmail** seçin
3. **Signing & Capabilities** sekmesine gidin
4. **+ Capability** butonuna tıklayın
5. **Push Notifications** seçin

### 3. Bundle ID'yi Kontrol Edin:
- **General** sekmesinde **Bundle Identifier** notunu alın
- Örnek: `com.yunuskaynarpinar.Speedmail`

---

## 📋 ADIM 3: Backend Sunucu Kurulumu (10 dakika)

### Railway'e Deploy:

1. **Railway hesabı oluştur:**
   ```
   https://railway.app
   ```
   - GitHub ile giriş yapın (ücretsiz, kredi kartı gerekmez)

2. **New Project** → **Deploy from GitHub repo**
   - Speedmail repository'sini seçin
   - `backend` klasörünü seçin

3. **Environment Variables ekle:**
   Railway dashboard'da **Variables** sekmesine gidin:

   ```env
   APNS_KEY_ID=AB12CD34EF
   APNS_TEAM_ID=1234567890
   GOOGLE_PROJECT_ID=speedmail-2e849
   GOOGLE_CLIENT_ID=941741001921-4k3bf7fucru39jgdtmovdiiap0hi26dk.apps.googleusercontent.com
   GOOGLE_CLIENT_SECRET=(Google Cloud Console'dan alın)
   PORT=3000
   NODE_ENV=production
   ```

4. **APNs Key dosyasını yükle:**
   - Railway dashboard'da **Files** sekmesine gidin
   - `AuthKey_XXXXXXXXXX.p8` dosyasını yükleyin
   - Path: `/app/AuthKey_XXXXXXXXXX.p8`
   
   Environment variable ekle:
   ```env
   APNS_KEY_PATH=/app/AuthKey_XXXXXXXXXX.p8
   ```

5. **Deploy URL'ini kopyalayın:**
   - Örnek: `https://speedmail-backend-production.up.railway.app`

---

## 📋 ADIM 4: iOS Kodunu Güncelle (1 dakika)

### APNsManager.swift'i güncelle:

1. Xcode'da `APNsManager.swift` dosyasını açın

2. **Railway URL'inizi yazın:**
   ```swift
   private let backendURL = "https://speedmail-backend-production.up.railway.app"
   ```

3. **Bundle ID'yi kontrol edin:**
   - `server.js` dosyasında:
   ```javascript
   topic: 'com.yunuskaynarpinar.Speedmail', // Bundle ID'niz
   ```

---

## 📋 ADIM 5: Google Cloud - Pub/Sub Kurulumu (5 dakika)

### 1. Pub/Sub API'yi Aktif Et:

```
https://console.cloud.google.com/apis/library/pubsub.googleapis.com?project=speedmail-2e849
```
- **Enable** butonuna tıklayın

### 2. Pub/Sub Topic Oluştur:

```bash
# Google Cloud Console'da Cloud Shell'i açın veya local'de gcloud CLI kullanın
gcloud pubsub topics create gmail-notifications --project=speedmail-2e849
```

### 3. Pub/Sub Subscription Oluştur:

```bash
gcloud pubsub subscriptions create gmail-notifications-sub \
  --topic=gmail-notifications \
  --push-endpoint=https://speedmail-backend-production.up.railway.app/gmail-webhook \
  --project=speedmail-2e849
```

### 4. Gmail API'ye İzin Ver:

1. **IAM & Admin** → **Service Accounts** gidin:
   ```
   https://console.cloud.google.com/iam-admin/serviceaccounts?project=speedmail-2e849
   ```

2. Gmail API için service account oluşturun veya mevcut olanı kullanın

3. **Pub/Sub Publisher** rolünü verin

---

## 📋 ADIM 6: Test (5 dakika)

### 1. Uygulamayı Build ve Run:

```bash
# Xcode'da:
⌘B (Build)
⌘R (Run)
```

### 2. Gmail Hesabı Bağla:

- Uygulamada **Gmail ile Giriş Yap** butonuna tıklayın
- Google hesabınızla giriş yapın
- İzinleri onaylayın

### 3. Bildirim İzni Ver:

- iOS bildirim izni isteğini **Allow** ile onaylayın

### 4. Test Mail Gönderin:

- Başka bir cihazdan veya web'den Gmail hesabınıza mail gönderin
- **0-2 saniye içinde** bildirim almalısınız! 🎉

---

## 🔍 Sorun Giderme

### Backend Loglarını Kontrol:

Railway dashboard'da **Logs** sekmesine gidin:

```
✅ Speedmail Backend çalışıyor: http://localhost:3000
📱 APNs: Yapılandırıldı
📬 Gmail push alındı: your@email.com, historyId: 12345
✅ APNs bildirimi gönderildi: device-token
```

### iOS Loglarını Kontrol:

Xcode Console'da:

```
✅ APNs device token alındı
✅ Device token backend'e kaydedildi
✅ Gmail watch başlatıldı: your@email.com
📬 Push notification alındı
```

### Yaygın Hatalar:

1. **"APNs kayıt hatası"**
   - Xcode'da Push Notifications capability eklenmiş mi?
   - Gerçek cihaz kullanıyor musunuz? (Simulator çalışmaz)

2. **"Device token backend'e kaydedilemedi"**
   - Railway URL'i doğru mu?
   - Backend çalışıyor mu? (Railway logs kontrol edin)

3. **"Gmail watch hatası"**
   - Pub/Sub topic oluşturulmuş mu?
   - Gmail API izinleri doğru mu?

---

## 🎯 SONUÇ

✅ **Gerçek zamanlı bildirimler aktif!**
- iPhone Mail gibi anında bildirim
- Batarya dostu
- Backend ücretsiz (Railway free tier)
- APNs ücretsiz (Apple Developer hesabı ile)

---

## 💰 Maliyetler

- **Apple Developer:** $99/yıl (zaten var)
- **Railway Backend:** $0-5/ay (free tier yeterli)
- **Google Cloud Pub/Sub:** İlk 10GB ücretsiz
- **APNs:** Ücretsiz (sınırsız)

**Toplam:** ~$0-5/ay 🎉


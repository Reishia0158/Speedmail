# 🔔 Firebase Push Notification Kurulum Kılavuzu

Bu kılavuz, Speedmail için ücretsiz Firebase Functions ile push notification sistemini kurmanızı sağlar.

## 📋 Gereksinimler

1. Firebase projesi (ücretsiz)
2. Google Cloud Console erişimi
3. Node.js 18+ (Firebase CLI için)

## 🚀 Adım Adım Kurulum

### 1. Firebase Projesi Oluşturma

1. [Firebase Console](https://console.firebase.google.com/)'a gidin
2. "Add project" ile yeni proje oluşturun
3. Proje adını girin (örn: `speedmail-push`)
4. Google Analytics'i isteğe bağlı olarak etkinleştirin

### 2. iOS App'i Firebase'e Ekleme

1. Firebase Console'da "Add app" > iOS seçin
2. Bundle ID'nizi girin (Xcode'da görüntüleyebilirsiniz)
3. `GoogleService-Info.plist` dosyasını indirin
4. Dosyayı Xcode projenize ekleyin (zaten var olabilir)

### 3. Google Cloud Pub/Sub Topic Oluşturma

Gmail Watch API için Pub/Sub topic gereklidir:

```bash
# Google Cloud CLI ile (veya Console'dan)
gcloud pubsub topics create gmail-notifications
```

**VEYA** Firebase Console'dan:
1. Firebase Console > Project Settings > Cloud Messaging
2. Cloud Messaging API (Legacy) etkinleştirin
3. Google Cloud Console'a gidin
4. Pub/Sub > Topics > Create Topic
5. Topic adı: `gmail-notifications`

### 4. Firebase Functions Deployment

```bash
cd firebase-backend
npm install
firebase login
firebase use --add  # Projenizi seçin
firebase deploy --only functions
```

### 5. Gmail API OAuth Consent Screen

1. [Google Cloud Console](https://console.cloud.google.com/) > APIs & Services > OAuth consent screen
2. External user type seçin
3. Gerekli bilgileri doldurun
4. Scopes ekleyin:
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/gmail.modify`
5. Test users ekleyin (geliştirme için)

### 6. Gmail API Etkinleştirme

1. Google Cloud Console > APIs & Services > Library
2. "Gmail API" arayın ve etkinleştirin
3. "Cloud Pub/Sub API" arayın ve etkinleştirin

## ✅ Test Etme

1. Uygulamayı çalıştırın
2. Gmail hesabınızı bağlayın
3. Firebase Console > Functions > Logs'dan logları kontrol edin
4. Test bildirimi göndermek için:
   ```swift
   // AppViewModel'de test fonksiyonu çağırın
   ```

## 💰 Maliyet

Firebase Functions **ÜCRETSİZ TIER**:
- ✅ 2M invocations/ay
- ✅ 400K GB-s/ay
- ✅ 5GB egress/ay

Bu limitler çoğu kullanıcı için yeterlidir.

## 🔧 Sorun Giderme

### "Topic not found" hatası
- Pub/Sub topic'in oluşturulduğundan emin olun
- Topic adının `gmail-notifications` olduğunu kontrol edin

### "Permission denied" hatası
- Firebase Functions'ın Pub/Sub'a erişim izni olduğundan emin olun
- Google Cloud IAM'de `roles/pubsub.publisher` rolü verin

### FCM token alınamıyor
- `GoogleService-Info.plist` dosyasının doğru eklendiğinden emin olun
- APNs sertifikalarının Firebase'e yüklendiğinden emin olun

## 📝 Notlar

- Gmail Watch API 7 günde bir yenilenmelidir (otomatik)
- Token'lar Firestore'da saklanır (şifreleme önerilir)
- IMAP IDLE backup olarak çalışmaya devam eder


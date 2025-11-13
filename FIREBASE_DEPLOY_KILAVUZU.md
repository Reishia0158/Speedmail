# 🔥 FIREBASE DEPLOY KILAVUZU

## ✅ HAZIRLIK TAMAMLANDI!

Artık uygulamanız **anlık bildirimler** için hazır! Son adım Cloud Functions'ları deploy etmek.

---

## 📋 DEPLOY ADIMLARI (15 Dakika)

### ADIM 1: Firebase CLI Kurun (5 dk)

Terminal'i açın ve şu komutları çalıştırın:

```bash
# Node.js kurulu mu kontrol edin
node --version

# Eğer Node.js kurulu değilse:
# https://nodejs.org adresinden indirin ve kurun

# Firebase CLI'yi kurun
npm install -g firebase-tools

# Kurulumu kontrol edin
firebase --version
```

✅ **KONTROL:** `firebase --version` komutu bir versiyon numarası göstermeli (örn: 13.0.0)

---

### ADIM 2: Firebase'e Giriş Yapın (2 dk)

```bash
# Firebase'e giriş yapın
firebase login

# Tarayıcı açılacak, Google hesabınızla giriş yapın
# İzinleri verin
# Terminal'e dönün
```

✅ **KONTROL:** "Success! Logged in as..." mesajı görmelisiniz

---

### ADIM 3: Firebase Proje ID'sini Alın (1 dk)

1. https://console.firebase.google.com adresine gidin
2. Projenizi açın
3. Ayarlar (⚙️) → Proje Ayarları
4. "Proje Kimliği" (Project ID) kopyalayın

Örnek: `speedmail-a1b2c` gibi bir şey olacak

---

### ADIM 4: Proje ID'sini Ayarlayın (1 dk)

Terminal'de:

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail/firebase-backend

# Proje ID'nizi değiştirin (KENDİ PROJE ID'NİZİ YAZIN!)
firebase use speedmail-a1b2c
```

⚠️ **ÖNEMLİ:** `speedmail-a1b2c` yerine KENDİ proje ID'nizi yazın!

Alternatif olarak `.firebaserc` dosyasını düzenleyin:

```bash
# Dosyayı açın
nano /Users/yunuskaynarpinar/Desktop/Speedmail/firebase-backend/.firebaserc

# "speedmail-proje-id" yazan yeri değiştirin
# Kaydedin: Ctrl+O, Enter, Ctrl+X
```

---

### ADIM 5: Cloud Functions Bağımlılıklarını Kurun (2 dk)

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail/firebase-backend/functions

# NPM paketlerini kurun
npm install

# Kurulumu bekleyin (30 saniye - 1 dakika)
```

✅ **KONTROL:** `node_modules` klasörü oluşmalı

---

### ADIM 6: Cloud Functions'ı Deploy Edin (3 dk)

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail/firebase-backend

# Deploy işlemini başlatın
firebase deploy --only functions

# İlk deploy 2-3 dakika sürebilir
# Sabırla bekleyin...
```

✅ **BAŞARILI ÇIKTI:**

```
✔  functions: Finished running predeploy script.
i  functions: preparing codebase default for deployment
i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...
i  functions: ensuring required API cloudbuild.googleapis.com is enabled...
✔  functions: required API cloudfunctions.googleapis.com is enabled
✔  functions: required API cloudbuild.googleapis.com is enabled
i  functions: uploading functions to Firebase...
✔  functions: upload complete!
i  functions: creating Node.js 18 function setupGmailWatch(us-central1)...
i  functions: creating Node.js 18 function handleGmailPush(us-central1)...
i  functions: creating Node.js 18 function saveFCMToken(us-central1)...
i  functions: creating Node.js 18 function sendTestNotification(us-central1)...
✔  functions[setupGmailWatch(us-central1)] Successful create operation.
✔  functions[handleGmailPush(us-central1)] Successful create operation.
✔  functions[saveFCMToken(us-central1)] Successful create operation.
✔  functions[sendTestNotification(us-central1)] Successful create operation.

✔  Deploy complete!
```

---

### ADIM 7: Pub/Sub Topic Oluşturun (2 dk)

Gmail bildirimleri için bir topic oluşturmanız gerekiyor:

```bash
# Google Cloud SDK kurulu değilse:
# https://cloud.google.com/sdk/docs/install

# Cloud'a giriş yapın
gcloud auth login

# Projenizi seçin (KENDİ PROJE ID'NİZİ YAZIN!)
gcloud config set project speedmail-a1b2c

# Pub/Sub topic oluşturun
gcloud pubsub topics create gmail-notifications

# Gmail'e izin verin
gcloud pubsub topics add-iam-policy-binding gmail-notifications \
  --member=serviceAccount:gmail-api-push@system.gserviceaccount.com \
  --role=roles/pubsub.publisher
```

✅ **KONTROL:** "Updated IAM policy" mesajı görmelisiniz

---

## 📱 XCODE AYARLARI (10 Dakika)

### ADIM 8: Firebase SDK'yı Ekleyin

1. Xcode'da projenizi açın
2. File → Add Package Dependencies
3. URL girin: `https://github.com/firebase/firebase-ios-sdk.git`
4. Version: "Up to Next Major Version" → 10.0.0
5. Şu paketleri seçin:
   - ✅ FirebaseMessaging
   - ✅ FirebaseAuth (opsiyonel, daha sonra için)
6. "Add Package" tıklayın
7. Bekleyin (1-2 dakika)

### ADIM 9: Yeni Dosyaları Projeye Ekleyin

Xcode'da sol tarafta "Services" klasörüne SAĞ TIK:

1. "Add Files to Speedmail" seçin
2. Şu dosyaları seçin:
   - ✅ FCMManager.swift
   - ✅ AppDelegate.swift
3. "Copy items if needed" ✓ işaretli olsun
4. "Add" tıklayın

### ADIM 10: GoogleService-Info.plist Kontrolü

1. Xcode'da sol tarafta "GoogleService-Info.plist" dosyasını bulun
2. Sağ tıklayın → "Show in Finder"
3. Dosyanın **Speedmail** klasörü içinde olduğundan emin olun
4. Xcode'da "Target Membership" kontrol edin:
   - Dosyaya tıklayın
   - Sağ panelde "Target Membership"
   - ✅ "Speedmail" işaretli olmalı

---

## 🧪 TEST (5 Dakika)

### Test 1: Uygulama Başlatma

```
1. iPhone'u Mac'e bağlayın
2. Xcode'da cihazınızı seçin
3. ▶️ (Play) butonuna tıklayın
4. Uygulama açılsın
```

✅ **KONTROL:** Xcode Console'da şu mesajlar gözükmeli:

```
✅ Firebase yapılandırıldı
✅ APNS Device Token alındı
✅ FCM Token alındı: [uzun bir string]
```

### Test 2: FCM Token Kontrolü

Uygulamada:

```
1. Uygulama açılınca bildirim izni verin
2. Gmail hesabınızı bağlayın
3. 10 saniye bekleyin
```

Xcode Console'da:

```
✅ FCM Token alındı: [token]
📤 FCM Token backend'e gönderildi: [token]
```

### Test 3: Manuel Test Bildirimi

Firebase Console'da:

```
1. https://console.firebase.google.com
2. Projenizi açın
3. Cloud Messaging sekmesine gidin
4. "Send your first message" tıklayın
5. Notification title: "Test"
6. Notification text: "Speedmail test bildirimi"
7. "Send test message" tıklayın
8. FCM token'ınızı yapıştırın
9. "Test" butonuna tıklayın
```

✅ **BAŞARILI:** iPhone'unuzda bildirim görmelisiniz!

---

## 🎊 TAMAMLANDI!

Artık sisteminiz hazır! Ama **bir önemli adım daha var:**

### Gmail Watch API'yi Aktifleştirin

⚠️ **ÖNEMLİ:** Gmail'den anlık bildirim almak için her hesap için "watch" başlatmanız gerekiyor.

Bu adım şu anda **iOS uygulamasından otomatik yapılamıyor**. İki seçenek:

#### Seçenek A: Backend'den Manuel (Basit)

Firebase Console → Functions → `setupGmailWatch` fonksiyonunu test edin.

#### Seçenek B: iOS'tan Çağır (Gelişmiş)

iOS uygulamasında Gmail hesabı eklendiğinde otomatik çağrılacak kodu ekleyelim mi?

---

## ⚙️ NASIL ÇALIŞIYOR?

### Sistem Akışı:

```
1. Gmail'e yeni mail gelir
     ↓
2. Gmail → Google Pub/Sub'a bildirim gönderir
     ↓
3. Cloud Function (handleGmailPush) tetiklenir
     ↓
4. Cloud Function → FCM token'ı bulur
     ↓
5. FCM → iPhone'a anlık bildirim gönderir
     ↓
6. iPhone → Bildirim gösterir (1-3 saniye içinde!)
```

---

## 🆘 SORUN GİDERME

### Firebase CLI kurulamıyor

```bash
# Sudo ile deneyin
sudo npm install -g firebase-tools
```

### Deploy hatası: "Permission denied"

```bash
# Tekrar giriş yapın
firebase logout
firebase login
```

### Deploy hatası: "Project not found"

```bash
# Proje listesini kontrol edin
firebase projects:list

# Doğru projeyi seçin
firebase use [proje-id]
```

### Xcode'da "Cannot find 'FirebaseMessaging'"

1. File → Packages → Resolve Package Versions
2. Clean Build (Shift+⌘K)
3. Rebuild (⌘B)

### FCM Token alınamıyor

1. GoogleService-Info.plist doğru yerde mi?
2. Bildirim izni verildi mi?
3. Gerçek iPhone'da mı test ediyorsunuz?
4. Push Notifications capability eklendi mi?

---

## 💰 MALİYET

### Firebase Ücretsiz Plan Limitleri:

- ✅ Cloud Functions: **2M çağrı/ay** (fazlasıyla yeter)
- ✅ Cloud Messaging: **Sınırsız** bildirim
- ✅ Firestore: **1 GB depolama**
- ✅ Pub/Sub: **10 GB mesaj/ay**

**Sonuç:** Kişisel kullanım için **TAMAMEN ÜCRETSIZ!** 🎉

---

## 📚 SONRAKİ ADIMLAR

1. ✅ Gmail Watch API'yi her hesap için aktifleştirin
2. ✅ Gerçek Gmail hesabınızla test edin
3. ✅ Bildirimlerin anlık geldiğini doğrulayın

---

## 🎯 ÖZET: ŞİMDİ NE YAPMALIYIM?

Terminal'de bu komutları çalıştırın:

```bash
# 1. Firebase CLI kur
npm install -g firebase-tools

# 2. Giriş yap
firebase login

# 3. Klasöre git
cd /Users/yunuskaynarpinar/Desktop/Speedmail/firebase-backend

# 4. Proje seç (KENDİ PROJE ID'NİZİ YAZIN!)
firebase use BURAYA-PROJE-ID-YAZIN

# 5. Bağımlılıkları kur
cd functions
npm install
cd ..

# 6. Deploy et
firebase deploy --only functions
```

Sonra Xcode'da:

1. Firebase SDK ekleyin (Add Package Dependencies)
2. FCMManager.swift ve AppDelegate.swift dosyalarını projeye ekleyin
3. Build ve Run yapın
4. Test edin!

---

**Başarılar!** 🚀

**Sorularınız olursa bildirin!**


# ⚡ HIZLI DEPLOY REHBERİ

## 🎯 SİZİN YAPMANIZ GEREKENLER (15 Dakika)

### 1️⃣ Terminal Komutları (10 dk)

Terminal'i açın ve **SATıR SATIR** kopyalayıp çalıştırın:

```bash
# Firebase CLI kur
npm install -g firebase-tools

# Firebase'e giriş yap (tarayıcı açılacak)
firebase login

# Klasöre git
cd /Users/yunuskaynarpinar/Desktop/Speedmail/firebase-backend
```

⚠️ **ŞİMDİ DUR!** Firebase Console'a gidin:
- https://console.firebase.google.com
- Projenizi açın
- Ayarlar ⚙️ → Proje Ayarları
- **"Proje Kimliği"** kopyalayın (örn: `speedmail-a1b2c`)

Terminal'e devam edin (**PROJE-ID yazan yere kendinizinkini yazın!**):

```bash
# Proje seç (KENDİ PROJE ID'NİZİ YAZIN!)
firebase use PROJE-ID

# Bağımlılıkları kur
cd functions
npm install

# Üst klasöre dön
cd ..

# DEPLOY ET! (2-3 dakika sürer)
firebase deploy --only functions
```

✅ **BAŞARILI!** "Deploy complete!" mesajını görmelisiniz.

---

### 2️⃣ Xcode Ayarları (5 dk)

#### A) Firebase SDK Ekle:

1. Xcode'da: **File → Add Package Dependencies**
2. URL: `https://github.com/firebase/firebase-ios-sdk.git`
3. Version: **10.0.0** seçin
4. Paketler:
   - ✅ **FirebaseMessaging** (MUTLAKA SEÇİN!)
   - ✅ FirebaseAuth (opsiyonel)
5. **Add Package** tıklayın
6. Bekleyin (1-2 dk)

#### B) Yeni Dosyaları Ekle:

1. Sol tarafta **"Services"** klasörüne **SAĞ TIK**
2. **"Add Files to Speedmail"** seçin
3. Şu dosyaları seçin:
   - ✅ **FCMManager.swift**
   - ✅ **AppDelegate.swift**
4. **"Copy items if needed"** ✓ işaretli olsun
5. **Add** tıklayın

#### C) Build ve Çalıştır:

```
1. iPhone'u Mac'e bağlayın
2. Cihazınızı seçin
3. ▶️ butonuna tıklayın
4. İlk build 2-3 dakika sürebilir
```

---

## ✅ TEST EDİN

### Xcode Console'da Şu Mesajları Görmeli:

```
✅ Firebase yapılandırıldı
✅ APNS Device Token alındı
✅ FCM Token alındı: [uzun bir string]
📤 FCM Token backend'e gönderildi
```

### Test Bildirimi Gönderin:

1. https://console.firebase.google.com → Projeniz
2. **Cloud Messaging** sekmesi
3. **"Send your first message"**
4. Başlık: "Test"
5. Metin: "Speedmail çalışıyor!"
6. **"Send test message"**
7. Console'daki FCM token'ı yapıştırın
8. **Test** tıklayın

✅ iPhone'unuzda bildirim görmelisiniz!

---

## 🎉 BAŞARILI!

Artık uygulamanız **anlık bildirimler** için hazır!

**ÖNEMLİ NOT:** Gmail'den otomatik bildirim almak için birkaç ek adım daha var (Pub/Sub ayarları). Detaylar için **FIREBASE_DEPLOY_KILAVUZU.md** dosyasına bakın.

---

## ❓ SORUN ÇIKTI MI?

### "npm: command not found"
→ Node.js kurun: https://nodejs.org

### Deploy hatası
→ Proje ID'nizi doğru yazdınız mı?
→ `firebase projects:list` ile kontrol edin

### Xcode'da "Cannot find FirebaseMessaging"
→ File → Packages → Resolve Package Versions
→ Clean Build (Shift+⌘K) → Rebuild (⌘B)

---

**Detaylı kılavuz:** `FIREBASE_DEPLOY_KILAVUZU.md`


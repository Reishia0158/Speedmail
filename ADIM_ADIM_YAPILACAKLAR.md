# 🎯 ADIM ADIM YAPMANIZ GEREKENLER

## 👋 Merhaba!

Kodlama bilginiz olmadığı için bu dökümanı sizin için hazırladım. Her adımı **TAKİP EDİN**, hiçbir adımı atlamayın.

---

## 📱 HAZIRLIK (5 Dakika)

### 1️⃣ iPhone'unuzu Mac'e Bağlayın
- Lightning/USB-C kablosuyla iPhone'u Mac'e bağlayın
- iPhone'da "Bu bilgisayara güven?" sorusuna **Güven** deyin

### 2️⃣ Xcode'u Açın
```
1. Mac'te "Launchpad" açın (F4)
2. "Xcode" uygulamasını bulun ve açın
3. Xcode ilk açılışta "Install Additional Components" isteyebilir → "Install" deyin
```

### 3️⃣ Projeyi Açın
```
1. Xcode menüsünden: File → Open
2. Şu klasörü bulun: Desktop → Speedmail
3. "Speedmail.xcodeproj" dosyasını seçin
4. "Open" butonuna tıklayın
```

✅ **KONTROL:** Xcode'da sol tarafta dosya listesi gözüküyor mu?

---

## 🔧 XCODE AYARLARI (10 Dakika)

### 4️⃣ Yeni Dosyaları Projeye Ekleyin

Sol taraftaki dosya listesinde:
```
1. "Speedmail" klasörünü genişletin
2. "Services" klasörüne SAĞ TIKLAYIN
3. "Add Files to Speedmail" seçin
4. Açılan pencerede şu dosyaları seçin:
   - NotificationManager.swift
   - BackgroundTaskManager.swift
5. "Copy items if needed" işaretli olsun ✓
6. "Add" butonuna tıklayın
```

✅ **KONTROL:** Services klasörü altında 5 dosya var mı?
- GoogleOAuth.swift
- GmailMailboxService.swift
- GmailProfileService.swift
- **NotificationManager.swift** ← YENİ
- **BackgroundTaskManager.swift** ← YENİ
- MailboxService.swift

### 5️⃣ Apple Developer Hesabı Ekleyin

```
1. Xcode menüsünden: Xcode → Settings (veya Preferences)
2. "Accounts" sekmesine tıklayın
3. Sol altta "+" butonuna tıklayın
4. "Apple ID" seçin
5. Apple ID ve şifrenizi girin
6. "Next" tıklayın
```

⚠️ **ÖNEMLİ:** Apple Developer Program üyeliğiniz yoksa:
- https://developer.apple.com adresine gidin
- "Join" butonuna tıklayın
- 99$ ödeme yapın (yıllık)
- Onaylanması 1-2 gün sürebilir

### 6️⃣ Signing (İmzalama) Ayarları

Sol taraftaki dosya listesinde:
```
1. En üstteki MAVİ "Speedmail" projesine tıklayın
2. Ortada "TARGETS" altında "Speedmail" seçin
3. Üstte "Signing & Capabilities" sekmesine tıklayın
4. "Team" yazan yerde Apple ID'nizi seçin
5. "Automatically manage signing" işaretli olsun ✓
```

✅ **KONTROL:** Sarı uyarı var mı? Yoksa devam edin.

### 7️⃣ Push Notifications Ekleyin

Hala "Signing & Capabilities" ekranında:
```
1. Sol üstteki "+ Capability" butonuna tıklayın
2. Listeden "Push Notifications" bulun ve çift tıklayın
3. Eklendiğini göreceksiniz
```

### 8️⃣ Background Modes Ekleyin

Hala aynı ekranda:
```
1. Tekrar "+ Capability" butonuna tıklayın
2. "Background Modes" bulun ve çift tıklayın
3. Açılan kutucuklarda şunları işaretleyin:
   ✓ Background fetch
   ✓ Background processing
   ✓ Remote notifications
```

✅ **KONTROL:** "Signing & Capabilities" ekranında şunlar gözüküyor mu?
- Signing → Team: [Sizin Apple ID'niz]
- Push Notifications
- Background Modes
  - ✓ Background fetch
  - ✓ Background processing
  - ✓ Remote notifications

---

## 🚀 ÇALIŞTIRMA (5 Dakika)

### 9️⃣ Cihaz Seçimi

Xcode'un üst ortasında:
```
1. Cihaz seçici var (iPhone 15 Pro gibi yazıyor)
2. Ona tıklayın
3. Açılan listeden KABLOLU BAĞLI iPhone'unuzu seçin
   (Örn: "Yunus'un iPhone'u")
```

⚠️ **DİKKAT:** "Any iOS Device (arm64)" SEÇMEYİN, gerçek cihazınızı seçin!

### 🔟 Build (Derleme)

```
1. Xcode menüsünden: Product → Build
   (veya klavyeden: ⌘B)
2. Üstte ilerlemE çubuğu gözükecek
3. "Build Succeeded" yazısını bekleyin (30 saniye - 1 dakika)
```

❌ **HATA OLURSA:**
```
1. Product → Clean Build Folder (Shift+⌘K)
2. 10 saniye bekleyin
3. Tekrar Product → Build (⌘B)
```

### 1️⃣1️⃣ Run (Çalıştırma)

```
1. Xcode menüsünden: Product → Run
   (veya klavyeden: ⌘R)
   (veya sol üstteki ▶️ Play butonuna tıklayın)
2. İlk seferde "Codesign wants to access key" diyebilir → Şifrenizi girin
3. iPhone'unuzda "Untrusted Developer" hatası gelirse:
   - iPhone → Ayarlar → Genel → VPN ve Cihaz Yönetimi
   - Apple ID'nizi bulun ve "Güven" deyin
4. Tekrar Xcode'da Run yapın
```

✅ **BAŞARILI:** iPhone'unuzda Speedmail uygulaması açıldı!

---

## 🎉 İLK KULLANIM (5 Dakika)

### 1️⃣2️⃣ Bildirim İzni Verin

Uygulama açılınca:
```
1. "Speedmail would like to send you notifications" uyarısı gelecek
2. "Allow" (İzin Ver) butonuna tıklayın
```

❌ Yanlışlıkla "Don't Allow" dediyseniz:
```
1. iPhone → Ayarlar → Speedmail → Notifications
2. "Allow Notifications" açın
```

### 1️⃣3️⃣ Gmail Hesabı Bağlayın

Uygulamada:
```
1. Sağ üstteki ZARF İKONU (✉️) tıklayın
2. Gmail giriş sayfası açılacak
3. Gmail adresinizi girin
4. Şifrenizi girin
5. İzin ekranında "Allow" deyin
6. Uygulamaya döneceksiniz
```

✅ **BAŞARILI:** Gmail hesabınız eklendi, mailleriniz yükleniyor!

### 1️⃣4️⃣ Daha Fazla Gmail Hesabı Ekleyin (İsteğe Bağlı)

```
1. Tekrar sağ üstteki ZARF İKONU (✉️) tıklayın
2. Başka bir Gmail hesabıyla giriş yapın
3. İstediğiniz kadar hesap ekleyebilirsiniz
```

---

## ✅ TEST (10 Dakika)

### TEST 1: Manuel Yenileme

```
1. Başka bir cihazdan Gmail hesabınıza test maili gönderin
2. Uygulamada sağ üstteki YENİLE İKONU (⟳) tıklayın
3. Yeni mail gözükecek + bildirim gelecek
```

### TEST 2: Otomatik Kontrol

```
1. Uygulamayı açık bırakın
2. 5 dakika bekleyin
3. Gmail'e test maili gönderin
4. 5 dakika içinde bildirim gelecek
```

### TEST 3: Arka Plan Bildirimi

```
1. Uygulamayı açın
2. Home butonuna basıp kapatın
3. Gmail'e test maili gönderin
4. 15-30 dakika bekleyin
5. Bildirim gelmesini bekleyin (iOS'a bağlı, garanti değil)
```

---

## 🎯 ARTIK NE OLABİLİR?

### Uygulama Açıkken:
- ✅ Her 5 dakikada bir otomatik mail kontrol eder
- ✅ Yeni mail gelince bildirim gösterir
- ✅ Mail listesi otomatik güncellenir

### Uygulama Kapalıyken:
- ✅ iOS izin verdiğinde arka plan kontrolü yapar (15-30dk aralıklarla)
- ✅ Yeni mail bulunca bildirim gönderir
- ⚠️ Garanti edilmiş süre yok (iOS'un kararı)

### Uygulamayı Tekrar Açınca:
- ✅ Otomatik yenilenir
- ✅ Tüm mailleriniz güncellenir

---

## ❓ SORUN ÇÖZÜMLEME

### "Build Failed" Hatası
```
1. Product → Clean Build Folder (Shift+⌘K)
2. Xcode'u kapatın
3. iPhone'u çıkarıp tekrar takın
4. Xcode'u açın
5. Tekrar build edin
```

### "Signing for Speedmail requires a development team"
```
1. Apple Developer hesabınız var mı? (99$/yıl)
2. Yoksa üye olun: https://developer.apple.com
3. Varsa: Signing & Capabilities → Team → Hesabınızı seçin
```

### "Untrusted Developer"
```
1. iPhone → Ayarlar → Genel → VPN ve Cihaz Yönetimi
2. Apple ID'nizi bulun
3. "Güven" deyin
```

### Bildirim Gelmiyor
```
1. Bildirim izni verdim mi?
   → Ayarlar → Speedmail → Notifications → Açık olmalı
2. Gerçek iPhone'da mı test ediyorum?
   → Simulator'da bildirim çalışmaz
3. 5 dakika bekledim mi?
   → Otomatik kontrol 5 dakikada bir çalışır
```

### Arka Plan Çalışmıyor
```
Bu normal! iOS arka plan görevlerini sınırlı çalıştırır.
- İlk birkaç gün geç çalışabilir
- Batarya durumu etkiler
- Kullanım alışkanlıkları etkiler
- Garanti edilmiş süre yoktur
```

---

## 📞 YARDIM GEREKİRSE

Xcode'da alttaki "Debug Area"ya bakın (View → Debug Area → Show Debug Area):

**Şu mesajları arayın:**
- ✅ "Uygulama aktif - Mailbox yenileniyor"
- ✅ "Arka plan görevi planlandı"
- ✅ "Bildirimler açıldı"
- ❌ "Mail kontrolü başarısız"

Bu mesajları bana gösterin, yardımcı olabilirim.

---

## 🎊 TEBRİKLER!

Artık maillerinizi **Speedmail** ile takip edebilirsiniz! 🚀

**Keyifli kullanımlar!** 📬

---

**HATIRLAYINIZ:**
- ✅ Uygulama açıkken → Her 5 dakikada kontrol
- ✅ Bildirimler aktif → Yeni mail gelince haber verir
- ✅ Çoklu hesap → İstediğiniz kadar Gmail ekleyebilirsiniz
- ⚠️ Arka plan → iOS'a bağlı, garanti edilmiş süre yok

---

**Son Güncelleme:** 11 Kasım 2025
**Hazırlayan:** AI Assistant


# 📱 SPEEDMAIL KULLANIM KILAVUZU

## 🎉 Hoş Geldiniz!

Speedmail uygulamanız artık **otomatik mail senkronizasyonu** ve **anlık bildirim** desteğine sahip!

---

## ✅ YAPILAN DEĞİŞİKLİKLER

### 1. **Otomatik Mail Kontrolü** ✉️
- ✅ Uygulama açıkken **her 5 dakikada bir** otomatik olarak maillerinizi kontrol eder
- ✅ Yeni mail geldiğinde **anında bildirim** gelir
- ✅ Tüm Gmail hesaplarınız **aynı anda** kontrol edilir

### 2. **Bildirim Sistemi** 🔔
- ✅ Yeni mail geldiğinde **push notification** alırsınız
- ✅ Bildirimde **gönderen, konu ve önizleme** görünür
- ✅ Birden fazla mail gelirse **toplu bildirim** gelir
- ✅ Bildirime tıklayarak **uygulamayı açabilirsiniz**

### 3. **Arka Plan Yenileme** 🌙
- ✅ Uygulama kapalıyken bile **iOS sisteminin izin verdiği aralıklarla** mail kontrol edilir
- ⚠️ **ÖNEMLİ:** iOS arka plan görevlerini **15-30 dakikada bir** sınırlı şekilde çalıştırır
- ✅ Uygulama ön plana geldiğinde **otomatik yenilenir**

### 4. **Çoklu Hesap Desteği** 👥
- ✅ İstediğiniz kadar **Gmail hesabı** ekleyebilirsiniz
- ✅ Her hesap **bağımsız olarak** kontrol edilir
- ✅ Her hesap için **ayrı bildirimler** gelir

---

## 🚀 NASIL KULLANILIR?

### ADIM 1: Uygulamayı Xcode'da Açın

```bash
# Terminal'de şu komutu çalıştırın:
cd /Users/yunuskaynarpinar/Desktop/Speedmail
open Speedmail.xcodeproj
```

### ADIM 2: Yeni Dosyaları Projeye Ekleyin

Xcode'da soldaki dosya listesinde **Services** klasörüne sağ tıklayıp "Add Files to Speedmail" seçin ve şu dosyaları ekleyin:

- ✅ `NotificationManager.swift`
- ✅ `BackgroundTaskManager.swift`

**VEYA** Xcode'u kapatıp tekrar açın, otomatik bulacaktır.

### ADIM 3: Projeyi Derleyin

1. Xcode'da üst menüden **Product > Build** (⌘B)
2. Hata yoksa devam edin

### ADIM 4: Gerçek iPhone'unuza Kurun

⚠️ **ÖNEMLİ:** Simulator'da bildirimler ve arka plan görevleri tam çalışmaz!

1. iPhone'unuzu Mac'e bağlayın
2. Xcode'da üst ortadaki cihaz seçiciden **iPhone'unuzu seçin**
3. **Product > Run** (⌘R) ile uygulamayı başlatın

### ADIM 5: İlk Açılış Ayarları

Uygulama açıldığında:

1. ✅ **Bildirim izni** sorulacak → **"İzin Ver"** seçin
2. ✅ Sağ üstteki **zil (🔔) ikonuna** tıklayarak bildirim iznini kontrol edebilirsiniz
3. ✅ **Gmail hesabınızı bağlayın:**
   - Sağ üstteki **mail (✉️) ikonuna** tıklayın
   - Gmail ile giriş yapın
   - İzinleri kabul edin

---

## 📋 ÖZELLİKLER VE NASIL ÇALIŞIR?

### 🔄 Otomatik Mail Kontrolü

```
Uygulama Açık → Her 5 dakikada bir tüm hesapları kontrol eder
Yeni mail var mı? → Evet → Bildirim gönder + Liste güncelle
                 → Hayır → Sessizce devam et
```

**Test Etmek İçin:**
1. Gmail hesabınıza başka bir cihazdan mail gönderin
2. 5 dakika içinde bildirim gelecek
3. Veya uygulamada **manuel yenileme** (⟳) butonuna basın

### 🔔 Bildirimler

**Tek Mail Geldiğinde:**
```
📬 Yeni Mail - ornek@gmail.com
Gönderen: Ahmet Yılmaz
Konu: Toplantı Daveti
Yarın saat 14:00'te görüşelim mi?
```

**Çoklu Mail Geldiğinde:**
```
📬 3 Yeni Mail
ornek@gmail.com hesabınıza 3 yeni mesaj geldi
```

### 🌙 Arka Plan Çalışma

**iOS Limitleri:**
- iOS **en az 15 dakikada bir** arka plan görevi çalıştırır
- Batarya durumu, kullanım alışkanlıkları vs. etkilenir
- Garanti edilmiş bir süre **YOKTUR** (iOS'un kararı)

**Arka Plan Çalışmasını Test Etmek:**
1. Uygulamayı açın
2. Home butonuna basıp kapatın
3. 15-30 dakika bekleyin
4. Gmail'e mail gönderin
5. Bildirim gelmesini bekleyin

⚠️ **NOT:** İlk birkaç günde iOS alışkana kadar geç bildirim gelebilir.

---

## 🛠️ XCODE AYARLARI (YAPMANIZ GEREKENLER)

### 1. Signing & Capabilities

1. Xcode'da projenizi seçin
2. **Targets** → **Speedmail** seçin
3. **Signing & Capabilities** sekmesine gidin
4. **+ Capability** butonuna tıklayın
5. Şunları ekleyin:
   - ✅ **Push Notifications**
   - ✅ **Background Modes**
     - ✅ "Background fetch" işaretli olsun
     - ✅ "Background processing" işaretli olsun
     - ✅ "Remote notifications" işaretli olsun

**Görsel Yardım:**
```
Signing & Capabilities
├── + Capability
├── Push Notifications ✓
└── Background Modes ✓
    ├── Background fetch ✓
    ├── Background processing ✓
    └── Remote notifications ✓
```

### 2. Developer Hesabı (Gerekli)

⚠️ **ZORUNLU:** Bildirimler için Apple Developer Program üyeliği gerekli (99$/yıl)

**Nasıl Yapılır:**
1. https://developer.apple.com adresine gidin
2. Apple ID ile giriş yapın
3. "Join the Apple Developer Program" tıklayın
4. Ödemeyi yapın (yıllık 99$)
5. Xcode'da **Signing & Capabilities** → **Team** kısmına hesabınızı seçin

---

## 🧪 TEST SENARYOLARI

### Test 1: Otomatik Mail Kontrolü
```
1. Uygulamayı açın
2. 5 dakika bekleyin
3. Gmail'e test maili gönderin
4. Bildirimin gelmesini bekleyin
BEKLENEN: 5 dakika sonraki kontrolde bildirim gelecek
```

### Test 2: Manuel Yenileme
```
1. Uygulamayı açın
2. Gmail'e test maili gönderin
3. Uygulamada yenile (⟳) butonuna basın
BEKLENEN: Hemen yeni mail görünecek + bildirim gelecek
```

### Test 3: Arka Plan Bildirimi
```
1. Uygulamayı açın
2. Home butonuna basıp arka plana atın
3. Gmail'e test maili gönderin
4. 15-30 dakika bekleyin
BEKLENEN: iOS izin verirse bildirim gelecek (garanti değil)
```

### Test 4: Çoklu Hesap
```
1. 2-3 Gmail hesabı bağlayın
2. Her hesaba ayrı mail gönderin
3. Bekleyin
BEKLENEN: Her hesap için ayrı bildirim gelecek
```

---

## ❓ SIK SORULAN SORULAR

### Bildirim gelmiyor?
**Kontrol Listesi:**
- [ ] Bildirim izni verildi mi? (Ayarlar → Speedmail → Bildirimler)
- [ ] Developer hesabı aktif mi?
- [ ] Push Notifications capability eklendi mi?
- [ ] Gerçek cihazda mı test ediyorsunuz? (Simulator'da çalışmaz)
- [ ] 5 dakika beklediniz mi?

### Arka plan çalışmıyor?
**Normal:** iOS arka plan görevlerini sınırlı çalıştırır. Garanti edilmiş bir süre yoktur. İlk birkaç gün alışma süresidir.

### Her dakika kontrol eder mi?
**Hayır:** Uygulama açıkken 5 dakikada bir, kapalıyken iOS'un izin verdiği aralıklarla (15-30dk) kontrol eder.

### Batarya tüketimi?
**Minimal:** Sadece kontrol sırasında kısa süreli network isteği yapılır. iOS optimize eder.

### Ticari kullanım?
Bu uygulama **kişisel kullanım** için tasarlandı. AppStore'a yüklemek isterseniz:
- Privacy Policy gerekir
- Terms of Service gerekir
- App Store Review Guidelines uyumluluğu gerekir

---

## 🐛 SORUN GİDERME

### Xcode Build Hatası
```bash
# Temiz build için:
Product > Clean Build Folder (Shift+⌘K)
# Sonra tekrar build:
Product > Build (⌘B)
```

### "Developer App certificate not found" Hatası
```
1. Xcode → Preferences → Accounts
2. Apple ID ekleyin
3. Download Manual Profiles tıklayın
4. Project Settings → Signing → Team seçin
```

### Uygulama Açılmıyor
```
1. iPhone'u yeniden başlatın
2. Xcode'u kapatıp açın
3. Clean Build yapın
4. Tekrar çalıştırın
```

### Bildirim İzni Reddedildi
```
1. iPhone Ayarlar açın
2. Speedmail uygulamasını bulun
3. Bildirimler → Açık yapın
4. Uygulamayı tekrar açın
```

---

## 📞 DESTEK

Sorun yaşarsanız:

1. **Xcode Console Loglarına** bakın (View → Debug Area → Show Debug Area)
2. Şu mesajları arayın:
   - ✅ "Arka plan görevi planlandı"
   - ✅ "Bildirimler açıldı"
   - ❌ "Mail kontrolü başarısız"

3. **Test için terminal komutları:**
```bash
# Arka plan görevini zorla çalıştır (simulator'da):
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.yunuskaynarpinar.Speedmail.mailRefresh"]
```

---

## 🎯 SONRAKİ ADIMLAR

Uygulamanızı geliştirmek için:

1. ✅ **Mail gönderme** özelliği eklenebilir
2. ✅ **Mail arama** iyileştirilebilir
3. ✅ **Kategorize etme** (iş, kişisel vs.)
4. ✅ **Widget** desteği eklenebilir
5. ✅ **Apple Watch** desteği eklenebilir

---

## 📝 YASAL UYARI

- Gmail API kullanımı için Google'ın Terms of Service geçerlidir
- Kişisel verilerin güvenliği sizin sorumluluğunuzdadır
- Bu uygulama "as-is" sunulmuştur
- Ticari kullanım için ek izinler gerekebilir

---

## ✨ BAŞARILAR!

Artık mail adreslerinizi **Speedmail** üzerinden kolayca takip edebilirsiniz! 🚀

**Keyifli kullanımlar!** 📬

---

**Son Güncelleme:** 11 Kasım 2025
**Versiyon:** 1.0
**Platform:** iOS 16.0+


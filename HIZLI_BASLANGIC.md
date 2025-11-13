# ⚡ HIZLI BAŞLANGIÇ - 5 DAKİKA!

## 🎯 ÖZETİN ÖZETİ

Speedmail uygulamanız artık:
- ✅ **Her 5 dakikada** otomatik mail kontrol eder
- ✅ **Yeni mail** gelince bildirim gönderir
- ✅ **Arka planda** çalışır (iOS izin verirse)
- ✅ **Çoklu Gmail** hesabı destekler

---

## 🚀 3 ADIMDA ÇALIŞTIRIN

### ADIM 1: Xcode'u Açın (1 dk)
```
1. Desktop → Speedmail klasörüne gidin
2. "Speedmail.xcodeproj" dosyasına çift tıklayın
3. Xcode açılacak, bekleyin
```

### ADIM 2: iPhone'u Bağlayın (1 dk)
```
1. iPhone'u Mac'e bağlayın (kablo ile)
2. iPhone'da "Bu bilgisayara güven?" → Güven deyin
3. Xcode'da üstte cihaz seçiciden iPhone'unuzu seçin
```

### ADIM 3: Çalıştırın (3 dk)
```
1. Xcode'da sol üstteki ▶️ (Play) butonuna tıklayın
2. İlk seferde şifrenizi isteyebilir → Girin
3. iPhone'da "Untrusted Developer" hatası gelirse:
   • iPhone → Ayarlar → Genel → VPN ve Cihaz Yönetimi
   • Apple ID'nizi bulun → Güven deyin
   • Tekrar Xcode'da ▶️ basın
4. Uygulama açılacak!
```

---

## ✅ İLK AÇILIŞ AYARLARI (2 dk)

### 1. Bildirim İzni
```
"Allow Notifications" sorusuna → İzin Ver deyin
```

### 2. Gmail Hesabı Bağlayın
```
1. Sağ üstteki ZARF İKONU (✉️) tıklayın
2. Gmail ile giriş yapın
3. İzinleri onaylayın
4. Mailleriniz yüklenecek!
```

---

## 🎉 TAMAM, ARTIK ÇALIŞIYOR!

Uygulamanız şimdi:
- ✅ Her 5 dakikada maillerinizi kontrol eder
- ✅ Yeni mail gelince bildirim gösterir
- ✅ Tüm Gmail hesaplarınızı takip eder

---

## ⚠️ ÖNEMLİ NOTLAR

### Apple Developer Hesabı Gerekli
- Bildirimler için **99$/yıl** Apple Developer Program üyeliği gerekli
- https://developer.apple.com → "Join" → Üye olun
- Onaylanması 1-2 gün sürebilir

### Xcode Ayarları (İlk Seferden Sonra)
```
1. Xcode → Settings → Accounts → Apple ID ekleyin
2. Proje → Signing & Capabilities:
   • Team: Apple ID seçin
   • + Capability → Push Notifications ekleyin
   • + Capability → Background Modes ekleyin
     ✓ Background fetch
     ✓ Background processing
     ✓ Remote notifications
```

### Yeni Dosyalar
Eğer "File not found" hatası alırsanız:
```
1. Xcode'da sol tarafta "Services" klasörüne SAĞ TIK
2. "Add Files to Speedmail" seçin
3. Şu dosyaları ekleyin:
   • NotificationManager.swift
   • BackgroundTaskManager.swift
4. "Copy items if needed" işaretli olsun
5. "Add" tıklayın
```

---

## 📚 DETAYLI DÖKÜMANTASYON

Tüm detaylar için:
- 📖 **KULLANIM_KILAVUZU.md** - Eksiksiz özellikler ve açıklamalar
- 📋 **ADIM_ADIM_YAPILACAKLAR.md** - Adım adım tüm işlemler

---

## 🆘 SORUN MU VAR?

### Build Hatası
```
Product → Clean Build Folder → Tekrar Build
```

### Bildirim Gelmiyor
```
• Gerçek iPhone'da mı test ediyorsunuz? (Simulator çalışmaz)
• Bildirim izni verdiniz mi?
• 5 dakika beklediniz mi?
```

### Signing Hatası
```
• Apple Developer hesabınız var mı?
• Xcode → Settings → Accounts → Apple ID eklediniz mi?
• Signing & Capabilities → Team seçtiniz mi?
```

---

## 🎊 İYİ KULANIMLAR!

Artık mailleriniz **Speedmail** ile güvende! 📬

**En önemli şey:** Gerçek iPhone'da test edin, simulator'da bildirimler çalışmaz!

---

**Hazırlayan:** AI Assistant
**Tarih:** 11 Kasım 2025
**Versiyon:** 1.0


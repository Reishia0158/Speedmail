# 📱 Speedmail Nasıl Çalışır?

## 🔐 GİRİŞ SİSTEMİ

### Tek Seferlik Giriş (Kalıcı)

```
1. Gmail ile giriş yap
   ↓
2. Google OAuth token'ları al
   ↓
3. Keychain'e güvenli şekilde kaydet
   ↓
4. Uygulama her açıldığında Keychain'den yükle
```

### Oturum Kapanır mı?

**HAYIR!** Oturum sonsuza kadar kalıcı:

- ✅ Uygulamayı kapatıp açsanız bile → **Oturum açık**
- ✅ Telefonu yeniden başlatsanız bile → **Oturum açık**
- ✅ Haftalarca kullanmasanız bile → **Oturum açık**
- ❌ Sadece **"Hesabı Kaldır"** ile kapanır

### Token Yenileme (Otomatik)

Gmail token'ları 1 saat sonra geçersiz olur, ama:

```swift
// GmailMailboxService.swift
private func ensureToken() async throws {
    if credentials.expiresAt < Date() {
        // Token süresi doldu, otomatik yenile!
        credentials = try await GoogleOAuthManager.shared.refresh(using: credentials.refreshToken)
    }
}
```

**Sonuç:** Token süresi dolsa bile, otomatik yenilenir ve giriş yapmaya gerek kalmaz!

---

## 📬 BİLDİRİM SİSTEMİ

### Uygulama Kapalıyken Bildirim Gelir mi?

**EVET! iOS Background App Refresh sayesinde:**

### Nasıl Çalışır:

```
SENARYO 1: Uygulama Açık
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Her 5 dakikada bir otomatik kontrol
    ↓
Yeni mail varsa → Anlık göster
```

```
SENARYO 2: Uygulama Kapalı (Arka Planda)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. iOS, arka planda uygulamayı başlatır (15-30 dakika)
    ↓
2. Speedmail mailleri kontrol eder (25 mail)
    ↓
3. Yeni mail varsa → Bildirim gönderir
    ↓
4. Uygulama kapanır
    ↓
5. iOS tekrar başlatır (15-30 dakika sonra)
```

### Background App Refresh Koşulları:

iOS şu durumlarda arka plan yenilemesi yapar:

✅ **Aktif:**
- Telefon şarjda
- WiFi'ye bağlı
- Uygulama son 7 gün içinde kullanıldı
- Düşük Güç Modu kapalı

⚠️ **Yavaş:**
- Batarya düşük
- Mobil veri
- Düşük Güç Modu açık

❌ **Pasif:**
- Uygulama son 30 gündür kullanılmadı
- Kullanıcı Background App Refresh'i manuel olarak kapattı

---

## 🔄 MAİL YENİLEME SİSTEMİ

### 3 Farklı Yenileme Modu:

#### 1. Uygulama Açıkken (5 dakika)

```swift
// AppViewModel.swift
private let autoRefreshInterval: TimeInterval = 300 // 5 dakika

// Her 5 dakikada bir:
await checkAllAccountsForNewMail()
```

#### 2. Arka Planda (15-30 dakika)

```swift
// BackgroundTaskManager.swift
BGTaskScheduler.shared.register(forTaskWithIdentifier: "mailRefresh")

// iOS karar verir ne zaman çalıştıracağına
// Genellikle 15-30 dakika
```

#### 3. Manuel Yenileme

```swift
// Kullanıcı pull-to-refresh yaptığında:
viewModel.refreshActiveMailbox(force: true)
```

---

## 📊 ÖRNEK SENARYO

### Sabah 9:00 - Uygulamayı Açtınız

```
09:00 → Giriş yaptınız (Gmail)
09:00 → Keychain'e kaydedildi
09:00 → Mailler yüklendi (25 mail)
09:05 → Otomatik kontrol #1
09:10 → Otomatik kontrol #2
09:15 → Uygulamayı kapattınız
```

### 09:30 - Yeni Mail Geldi

```
09:30 → Gmail'e mail geldi
09:35 → iOS uygulamayı arka planda başlattı
09:35 → Speedmail mailleri kontrol etti
09:35 → Yeni mail bulundu!
09:35 → 📬 Bildirim gösterildi: "Yeni Mail"
09:35 → Uygulama kapandı
```

### 18:00 - Uygulamayı Tekrar Açtınız

```
18:00 → Uygulamayı açtınız
18:00 → Keychain'den hesap yüklendi (GİRİŞ YAPMAYA GEREK YOK!)
18:00 → Token otomatik yenilendi (gerekirse)
18:00 → Mailler yüklendi
```

---

## ⚙️ AYARLAR

### Bildirim İzni

İlk açılışta iOS sorar:

```
"Speedmail would like to send you notifications"
[Don't Allow] [Allow]
```

**Mutlaka "Allow" seçin!**

### Background App Refresh

iOS Ayarları → Genel → Background App Refresh:

- ✅ **Background App Refresh:** Açık
- ✅ **Speedmail:** Açık

### Düşük Güç Modu

Düşük Güç Modu aktifse:
- Background refresh YAVAŞlar
- Ama tamamen durMAZ

---

## 🔒 GÜVENLİK

### Keychain Nedir?

Apple'ın şifreli depolama sistemi:

- ✅ Şifreleri ve token'ları güvenli saklar
- ✅ Face ID/Touch ID ile korunur
- ✅ Sandboxed (diğer uygulamalar erişemez)
- ✅ iCloud yedeklenir (şifreli)

### Ne Saklanıyor?

```swift
struct GoogleCredentials {
    let accessToken: String      // Gmail API erişimi
    let refreshToken: String     // Token yenileme
    let expiresAt: Date         // Geçerlilik süresi
}
```

**ÖNEMLİ:** Şifreniz SAKLANMıyor! Sadece OAuth token'ları.

---

## 📱 KULLANIM SENARYOLARı

### Senaryo 1: Her Gün Kullanan Kullanıcı

```
✅ Uygulama açık (5 dakika)
✅ Uygulama kapalı (15-30 dakika)
✅ Bildirimler anında
✅ Batarya tüketimi minimal
```

### Senaryo 2: Ara Sıra Kullanan Kullanıcı

```
✅ Son 7 gün içinde kullandı
✅ Background refresh aktif (30 dakika)
✅ Bildirimler yavaş ama geliyor
⚠️ iOS optimize eder
```

### Senaryo 3: 30+ Gün Kullanmadı

```
❌ iOS background refresh'i durdurur
❌ Bildirim gelmez
✅ Ama uygulamayı açınca oturum açık!
✅ Mailler hemen yüklenir
```

---

## 🎯 ÖZET

### GİRİŞ:
- ✅ **Tek seferlik** (Keychain'de kalıcı)
- ✅ **Otomatik token yenileme**
- ✅ **Sonsuza kadar açık**

### BİLDİRİM:
- ✅ **Uygulama açıkken:** 5 dakika
- ✅ **Uygulama kapalıyken:** 15-30 dakika
- ✅ **iOS otomatik yönetir**

### GÜVENLİK:
- ✅ **Keychain şifrelemesi**
- ✅ **OAuth token'ları**
- ✅ **Şifre saklanmaz**

---

## ❓ SORU - CEVAP

**S: Uygulamayı silersem oturum kapanır mı?**  
C: Evet, uygulamayı sildiğinizde Keychain'deki veriler de silinir.

**S: Telefonu değiştirirsem?**  
C: iCloud Keychain aktifse → Yeni telefonda otomatik yüklenir!  
   iCloud Keychain kapalıysa → Tekrar giriş yapmanız gerekir.

**S: Background refresh çalışmıyorsa?**  
C: iOS Ayarları → Genel → Background App Refresh → Açık yapın.

**S: Gmail şifremi değiştirirsem?**  
C: Token otomatik yenilendiği için sorun olmaz!

**S: Internet yoksa?**  
C: Uygulama son yüklenen mailleri gösterir (offline mod yok henüz).

---

## 🚀 EN İYİ PERFORMANS İÇİN

1. ✅ **Background App Refresh:** Açık
2. ✅ **Bildirimlere izin ver**
3. ✅ **Uygulamayı haftada en az 1 kez açın**
4. ✅ **Düşük Güç Modunu sadece gerektiğinde kullanın**
5. ✅ **WiFi'ye bağlı tutun (şarjda değilken)**


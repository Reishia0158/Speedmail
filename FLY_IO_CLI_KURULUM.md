# 🚀 Fly.io CLI Kurulum Kılavuzu - Adım Adım

Bu kılavuz, Fly.io'yu terminal üzerinden kurmanızı sağlar.

---

## 📋 ADIM 1: Fly.io CLI Kurulumu

### macOS için:

**Yöntem 1: Install Script (Önerilen)**
```bash
curl -L https://fly.io/install.sh | sh
```

Kurulumdan sonra terminal'i yeniden başlatın veya:
```bash
export FLYCTL_INSTALL="/Users/$USER/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
```

**Yöntem 2: Homebrew**
```bash
brew install flyctl
```

### Kurulumu Kontrol Et:
```bash
fly version
```
Çıktı: `fly vX.X.X` şeklinde bir versiyon numarası görmelisiniz.

---

## 📋 ADIM 2: Fly.io Hesabı Oluşturma ve Giriş

### 1. Hesap Oluşturma:
```bash
fly auth signup
```

Bu komut:
- Tarayıcıyı açacak
- Fly.io kayıt sayfasına yönlendirecek
- GitHub, Google veya Email ile kayıt olabilirsiniz

**VEYA** önce web'den kayıt olun:
```
https://fly.io → Sign Up
```

### 2. Giriş Yapma:
```bash
fly auth login
```

Bu komut:
- Tarayıcıyı açacak
- Fly.io giriş sayfasına yönlendirecek
- Giriş yaptıktan sonra terminal'e dönün

### 3. Giriş Durumunu Kontrol Et:
```bash
fly auth whoami
```

Çıktı: Email adresinizi görmelisiniz.

---

## 📋 ADIM 3: Proje Klasörüne Git

```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail/backend
```

Kontrol et:
```bash
ls -la
```

Görmeniz gerekenler:
- `package.json`
- `server.js`
- `Dockerfile` ✅
- `fly.toml` ✅

---

## 📋 ADIM 4: Fly.io App Oluşturma

```bash
fly launch
```

Bu komut size sorular soracak:

### Soru 1: "An app name (or leave blank to generate one)"
```
speedmail-backend
```
(Enter'a basın)

### Soru 2: "Select Organization"
```
Personal
```
(Enter'a basın - eğer sadece kişisel hesabınız varsa)

### Soru 3: "Select region"
```
iad
```
(Washington DC - en yakın bölge, veya size yakın bir bölge seçin)

### Soru 4: "Would you like to set up a Postgresql database now?"
```
n
```
(Şimdilik hayır, basit storage kullanıyoruz)

### Soru 5: "Would you like to set up a Redis database now?"
```
n
```
(Hayır)

### Soru 6: "Would you like to deploy now?"
```
n
```
(Önce environment variables ayarlayacağız, sonra deploy edeceğiz)

---

## 📋 ADIM 5: Environment Variables Ayarlama

### 1. Google OAuth Bilgileri:

```bash
fly secrets set GOOGLE_CLIENT_ID="your-client-id-here"
```

**Örnek:**
```bash
fly secrets set GOOGLE_CLIENT_ID="941741001921-4k3bf7fucru39jgdtmovdiiap0hi26dk.apps.googleusercontent.com"
```

```bash
fly secrets set GOOGLE_CLIENT_SECRET="your-client-secret-here"
```

```bash
fly secrets set GOOGLE_PROJECT_ID="speedmail-2e849"
```

### 2. APNs Bilgileri (iOS Bildirimleri):

**APNs Key ID ve Team ID'yi bulun:**
- Apple Developer Portal → Keys → APNs Key'iniz
- Key ID: 10 karakter (örn: `AB12CD34EF`)
- Team ID: Sağ üst köşede (örn: `1234567890`)

```bash
fly secrets set APNS_KEY_ID="AB12CD34EF"
```

```bash
fly secrets set APNS_TEAM_ID="1234567890"
```

```bash
fly secrets set APNS_BUNDLE_ID="com.yunuskaynarpinar.Speedmail"
```

### 3. APNs Key (.p8 Dosyası) - Base64 Encode:

**Önce .p8 dosyasının yerini bulun:**
```bash
# Eğer Desktop'ta ise:
ls ~/Desktop/AuthKey_*.p8

# VEYA başka bir yerde:
find ~ -name "AuthKey_*.p8" 2>/dev/null
```

**Base64 encode edip secret olarak kaydedin:**
```bash
cat ~/Desktop/AuthKey_XXXXX.p8 | base64 | fly secrets set APNS_KEY_BASE64="$(cat)"
```

**VEYA manuel olarak:**
```bash
# Önce base64 encode edin:
base64 -i ~/Desktop/AuthKey_XXXXX.p8 > /tmp/apns_key_base64.txt

# Sonra secret olarak kaydedin:
fly secrets set APNS_KEY_BASE64="$(cat /tmp/apns_key_base64.txt)"
```

### 4. Secret'ları Kontrol Et:
```bash
fly secrets list
```

Görmeniz gerekenler:
- `GOOGLE_CLIENT_ID`
- `GOOGLE_CLIENT_SECRET`
- `GOOGLE_PROJECT_ID`
- `APNS_KEY_ID`
- `APNS_TEAM_ID`
- `APNS_BUNDLE_ID`
- `APNS_KEY_BASE64`

---

## 📋 ADIM 6: Deployment (Deploy)

```bash
fly deploy
```

Bu komut:
1. Docker image'ı oluşturacak
2. Fly.io'ya yükleyecek
3. App'i başlatacak

**İlk deployment 5-10 dakika sürebilir.**

Çıktıda göreceksiniz:
```
==> Building image
==> Pushing image to fly
==> Creating release
==> Monitoring deployment
```

---

## 📋 ADIM 7: App URL'ini Kontrol Etme

### App durumunu kontrol et:
```bash
fly status
```

Çıktı:
```
App
  Name     = speedmail-backend
  Owner    = personal
  Hostname = speedmail-backend.fly.dev
  Status   = running
```

### App URL'ini not edin:
```
https://speedmail-backend.fly.dev
```

### Health check:
```bash
curl https://speedmail-backend.fly.dev/health
```

Çıktı:
```json
{"status":"OK","timestamp":"2024-..."}
```

---

## 📋 ADIM 8: Logları İzleme

### Canlı logları görüntüle:
```bash
fly logs
```

### Son 100 satır log:
```bash
fly logs --limit 100
```

---

## 📋 ADIM 9: iOS'ta Backend URL'ini Güncelleme

### 1. Xcode'da `APNsManager.swift` dosyasını açın:
```
Speedmail/Services/APNsManager.swift
```

### 2. Backend URL'ini güncelleyin:
```swift
private let backendURL = "https://speedmail-backend.fly.dev"
```

**ÖNEMLİ:** `speedmail-backend.fly.dev` yerine kendi app URL'inizi yazın!

---

## 📋 ADIM 10: Google Cloud Pub/Sub Kurulumu

### 1. Pub/Sub Topic Oluştur:
```bash
gcloud pubsub topics create gmail-notifications --project=speedmail-2e849
```

### 2. Pub/Sub Subscription Oluştur:
```bash
gcloud pubsub subscriptions create gmail-notifications-sub \
  --topic=gmail-notifications \
  --push-endpoint=https://speedmail-backend.fly.dev/gmail-webhook \
  --project=speedmail-2e849
```

**ÖNEMLİ:** `speedmail-backend.fly.dev` yerine kendi app URL'inizi yazın!

---

## 🔧 SORUN GİDERME

### "App not found" hatası:
```bash
fly apps list  # App'inizi kontrol edin
fly launch     # Tekrar app oluşturun
```

### "Secrets not found" hatası:
```bash
fly secrets list  # Secret'ları kontrol edin
fly secrets set KEY="value"  # Eksik secret'ları ekleyin
```

### "Deployment failed" hatası:
```bash
fly logs  # Hata mesajlarını kontrol edin
fly status  # App durumunu kontrol edin
```

### App'i yeniden başlatma:
```bash
fly apps restart speedmail-backend
```

### App'i silme (baştan başlamak için):
```bash
fly apps destroy speedmail-backend
```

---

## ✅ KONTROL LİSTESİ

- [ ] Fly.io CLI kuruldu (`fly version`)
- [ ] Fly.io'ya giriş yapıldı (`fly auth whoami`)
- [ ] App oluşturuldu (`fly launch`)
- [ ] Tüm secret'lar ayarlandı (`fly secrets list`)
- [ ] Deployment tamamlandı (`fly deploy`)
- [ ] Health check çalışıyor (`curl https://.../health`)
- [ ] iOS'ta backend URL güncellendi
- [ ] Google Cloud Pub/Sub kuruldu

---

## 🎯 SONRAKI ADIMLAR

1. iOS uygulamasını çalıştırın
2. Gmail hesabını bağlayın
3. Test maili gönderin
4. Bildirim gelip gelmediğini kontrol edin

---

## 📝 FAYDALI KOMUTLAR

```bash
# App durumu
fly status

# Logları izle
fly logs

# Secret'ları listele
fly secrets list

# Secret sil
fly secrets unset KEY_NAME

# App'i yeniden başlat
fly apps restart speedmail-backend

# App'i durdur
fly apps suspend speedmail-backend

# App'i başlat
fly apps resume speedmail-backend

# App bilgilerini görüntüle
fly info
```

---

## 💡 İPUÇLARI

1. **Secret'ları güncellemek için:**
   ```bash
   fly secrets set KEY="new-value"
   ```
   (Eski değer otomatik olarak güncellenir)

2. **Deployment sonrası otomatik restart:**
   Secret güncellemesi sonrası app otomatik olarak yeniden başlar.

3. **Logları filtreleme:**
   ```bash
   fly logs | grep "ERROR"
   ```

4. **App URL'ini öğrenme:**
   ```bash
   fly status | grep Hostname
   ```

---

**Hazırsınız! Adım adım takip edin ve sorun olursa bana sorun.** 🚀


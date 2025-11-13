# 🚀 Fly.io Kurulum Kılavuzu

Bu kılavuz, Speedmail backend'ini Fly.io'ya deploy etmenizi sağlar.

## 📋 SİZİN YAPMANIZ GEREKENLER

### 1. Fly.io Hesabı Oluşturma

1. [Fly.io](https://fly.io) sitesine gidin
2. "Sign Up" ile hesap oluşturun (GitHub ile hızlı giriş yapabilirsiniz)
3. Email doğrulamasını tamamlayın

### 2. Fly.io CLI Kurulumu

**macOS:**
```bash
curl -L https://fly.io/install.sh | sh
```

**VEYA Homebrew ile:**
```bash
brew install flyctl
```

Kurulumdan sonra terminal'i yeniden başlatın veya:
```bash
export FLYCTL_INSTALL="/Users/$USER/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
```

### 3. Fly.io'ya Giriş Yapma

```bash
fly auth login
```

Tarayıcı açılacak, Fly.io hesabınızla giriş yapın.

### 4. Fly.io App Oluşturma

```bash
cd backend
fly launch
```

Sorular:
- **App name:** `speedmail-backend` (veya istediğiniz isim)
- **Region:** `iad` (Washington DC - en yakın) veya size yakın bir bölge
- **PostgreSQL:** Şimdilik `No` (basit storage kullanıyoruz)
- **Redis:** `No`

### 5. Environment Variables Ayarlama

Fly.io'da environment variables ayarlayın:

**Yöntem 1: CLI ile (Önerilen):**

```bash
# Google OAuth bilgileri
fly secrets set GOOGLE_CLIENT_ID="your-client-id"
fly secrets set GOOGLE_CLIENT_SECRET="your-client-secret"
fly secrets set GOOGLE_PROJECT_ID="your-project-id"

# APNs bilgileri (iOS bildirimleri için)
fly secrets set APNS_KEY_ID="your-key-id"
fly secrets set APNS_TEAM_ID="your-team-id"
fly secrets set APNS_BUNDLE_ID="com.yunuskaynarpinar.Speedmail"

# APNs Key (.p8 dosyası) - Base64 encode edilmiş
cat AuthKey_XXXXX.p8 | base64 | fly secrets set APNS_KEY_BASE64="$(cat)"
```

**Yöntem 2: Dashboard ile:**
1. Fly.io Dashboard > Your App > Secrets
2. Her bir secret'ı ekleyin:
   - `GOOGLE_CLIENT_ID`
   - `GOOGLE_CLIENT_SECRET`
   - `GOOGLE_PROJECT_ID`
   - `APNS_KEY_ID`
   - `APNS_TEAM_ID`
   - `APNS_BUNDLE_ID`
   - `APNS_KEY_BASE64` (base64 encoded .p8 dosyası)

### 6. Deployment

```bash
fly deploy
```

İlk deployment biraz zaman alabilir (5-10 dakika).

### 7. App URL'ini Kontrol Etme

```bash
fly status
```

Çıktıda `Hostname` göreceksiniz, örn: `speedmail-backend.fly.dev`

### 8. Health Check

Tarayıcıda açın:
```
https://speedmail-backend.fly.dev/health
```

`{"status":"OK","timestamp":"..."}` görmelisiniz.

## ✅ BENİM YAPTIĞIM DEĞİŞİKLİKLER

1. ✅ `Dockerfile` - Fly.io için container image
2. ✅ `fly.toml` - Fly.io configuration
3. ✅ `.dockerignore` - Build optimizasyonu
4. ✅ `server.js` - Fly.io için optimize edildi
5. ✅ iOS entegrasyonu - Fly.io backend'e bağlanacak

## 🔧 SORUN GİDERME

### "App not found" hatası
```bash
fly apps list  # App'inizi kontrol edin
fly launch     # Tekrar app oluşturun
```

### "Secrets not found" hatası
```bash
fly secrets list  # Secret'ları kontrol edin
fly secrets set KEY="value"  # Eksik secret'ları ekleyin
```

### Logları görüntüleme
```bash
fly logs
```

### App'i yeniden başlatma
```bash
fly apps restart speedmail-backend
```

## 📝 NOTLAR

- Fly.io free tier: 3 shared-cpu-1x machines
- Always-on: Evet (sürekli çalışır)
- Gmail Watch API: Desteklenir
- Uygulama kapalıyken: Evet, bildirimler gelir

## 🎯 SONRAKI ADIMLAR

Deployment tamamlandıktan sonra:
1. iOS tarafında backend URL'ini güncelleyeceğim
2. Test bildirimi göndereceğiz
3. Gmail Watch API'yi başlatacağız


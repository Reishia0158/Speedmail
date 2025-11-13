# ☁️ Oracle Cloud Free Tier - Tam Kılavuz

## 🎯 HEDEF:

Oracle Cloud'da **ücretsiz VPS** oluşturup backend'i deploy edeceğiz.

---

## 📋 ADIM 1: Oracle Cloud Hesabı Oluşturun

### 1.1. Hesap Oluşturma

1. **https://www.oracle.com/cloud/free/** → **"Start for Free"**
2. **Kişisel bilgilerinizi girin:**
   - Email
   - Ülke
   - Telefon (doğrulama için)
3. **Kredi kartı bilgisi istenir:**
   - ⚠️ **ÜCRET ALINMAZ** (sadece doğrulama için)
   - Free Tier için ücret alınmaz
4. **Email doğrulaması yapın**

### 1.2. Tenancy Oluşturma

1. Oracle Cloud'a giriş yapın
2. **Tenancy** (organizasyon) oluşturun
3. **Home Region** seçin (en yakın bölgeyi seçin)

---

## 📋 ADIM 2: VPS (Compute Instance) Oluşturun

### 2.1. Compute Instance Oluşturma

1. **Oracle Cloud Console** → **"Create a VM Instance"**
2. **Instance Details:**
   - **Name:** `speedmail-backend`
   - **Image:** **Canonical Ubuntu 22.04** (veya 20.04)
   - **Shape:** **VM.Standard.A1.Flex** (Free Tier)
   - **OCPUs:** `1`
   - **Memory:** `1 GB`
3. **Networking:**
   - **VCN:** Yeni VCN oluşturun (otomatik)
   - **Subnet:** Public subnet
   - **Public IP:** **Assign a public IPv4 address** ✅
4. **SSH Keys:**
   - **"Generate a key pair for me"** seçin
   - **Private key'i indirin** (çok önemli!)
   - **Public key otomatik eklenir**
5. **"Create"** butonuna tıklayın

### 2.2. Public IP'yi Not Edin

1. Instance oluşturulduktan sonra **Public IP** adresini kopyalayın
2. Örnek: `123.45.67.89`

---

## 📋 ADIM 3: SSH ile Bağlanın

### 3.1. SSH Key'i Hazırlayın

1. İndirdiğiniz **private key** dosyasını bulun
2. Terminal'de şu komutu çalıştırın:

```bash
chmod 400 /path/to/your/private-key.key
```

### 3.2. SSH Bağlantısı

Terminal'de şu komutu çalıştırın (Public IP'yi kendi IP'nizle değiştirin):

```bash
ssh -i /path/to/your/private-key.key ubuntu@YOUR_PUBLIC_IP
```

**Örnek:**
```bash
ssh -i ~/Downloads/ssh-key-2024-01-01.key ubuntu@123.45.67.89
```

✅ Bağlantı başarılı olursa terminal'de `ubuntu@instance-name:~$` göreceksiniz.

---

## 📋 ADIM 4: Node.js Kurulumu

SSH bağlantısında şu komutları sırayla çalıştırın:

### 4.1. Sistem Güncellemesi

```bash
sudo apt update
sudo apt upgrade -y
```

### 4.2. Node.js Kurulumu

```bash
# Node.js 18.x kurulumu
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### 4.3. Doğrulama

```bash
node --version  # v18.x.x görmeli
npm --version  # 9.x.x görmeli
```

### 4.4. PM2 Kurulumu (Always-on için)

```bash
sudo npm install -g pm2
```

---

## 📋 ADIM 5: Backend Kodunu Yükleyin

### 5.1. Git Kurulumu

```bash
sudo apt install -y git
```

### 5.2. Backend Klasörü Oluşturun

```bash
mkdir -p ~/speedmail-backend
cd ~/speedmail-backend
```

### 5.3. Backend Dosyalarını Yükleyin

**Seçenek 1: GitHub'dan Clone (Önerilen)**

Eğer backend'i GitHub'a push ettiyseniz:

```bash
git clone https://github.com/YOUR_USERNAME/Speedmail.git .
cd backend
```

**Seçenek 2: Manuel Yükleme**

Backend dosyalarını SCP ile yükleyin (local terminal'de):

```bash
# Local terminal'de (SSH bağlantısından çıkın)
scp -i /path/to/your/private-key.key -r backend/* ubuntu@YOUR_PUBLIC_IP:~/speedmail-backend/
```

### 5.4. Dependencies Yükleyin

```bash
cd ~/speedmail-backend
npm install --production
```

---

## 📋 ADIM 6: Environment Variables Ayarlayın

### 6.1. .env Dosyası Oluşturun

```bash
nano ~/speedmail-backend/.env
```

### 6.2. Environment Variables Ekleyin

Aşağıdaki içeriği ekleyin (değerleri kendi değerlerinizle değiştirin):

```env
# APNs Configuration
APNS_KEY_BASE64=LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZzBRbHYwd09YZlZKUzRCbTAKaEU5UW9YaHhxSzJsMzQycTJGNG1HZUs3Q2s2Z0NnWUlLb1pJemowREFRZWhSQU5DQUFSUDgrcWp0U0F2Z2lHOQphNTdSbmsyTUIvWjRvbnkyeWtvYXJJT0E4K2ROMlYxUkt6U3QxM01EQVpHc2RSa3FCalBobnBWQmp1VHI4emNKCkptUGo5YkVPCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0=
APNS_KEY_ID=HH9Z3X32PQ
APNS_TEAM_ID=YOUR_TEAM_ID
APNS_BUNDLE_ID=com.yunuskaynarpinar.Speedmail

# Google Cloud Configuration
GOOGLE_PROJECT_ID=speedmail-2e849
GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET=YOUR_GOOGLE_CLIENT_SECRET

# Server Configuration
NODE_ENV=production
PORT=3000
```

**Kaydetmek için:**
- `Ctrl + O` → `Enter` → `Ctrl + X`

---

## 📋 ADIM 7: PM2 ile Backend'i Başlatın

### 7.1. PM2 ile Başlatma

```bash
cd ~/speedmail-backend
pm2 start server.js --name speedmail-backend
```

### 7.2. PM2 Startup (Otomatik Başlatma)

```bash
pm2 startup
# Çıkan komutu kopyalayıp çalıştırın (sudo ile)
pm2 save
```

### 7.3. Durum Kontrolü

```bash
pm2 status
pm2 logs speedmail-backend
```

✅ Şunu görmelisiniz:
```
🚀 Speedmail Backend çalışıyor: http://0.0.0.0:3000
📱 APNs: Yapılandırıldı
```

---

## 📋 ADIM 8: Firewall Ayarları

### 8.1. Port 3000'i Açın

```bash
sudo ufw allow 3000/tcp
sudo ufw enable
sudo ufw status
```

### 8.2. Oracle Cloud Security List

1. **Oracle Cloud Console** → **Networking** → **Virtual Cloud Networks**
2. VCN'inizi seçin → **Security Lists**
3. **Default Security List** → **Ingress Rules** → **Add Ingress Rule**
4. **Source:** `0.0.0.0/0`
5. **Destination Port Range:** `3000`
6. **Protocol:** `TCP`
7. **"Add Ingress Rule"**

---

## 📋 ADIM 9: Test Edin

### 9.1. Health Check

Tarayıcıda şu URL'i açın:

```
http://YOUR_PUBLIC_IP:3000/health
```

✅ Şunu görmelisiniz: `{"status":"OK","timestamp":"..."}`

### 9.2. Backend URL'i

Backend URL'iniz:
```
http://YOUR_PUBLIC_IP:3000
```

**Bu URL'i iOS uygulamasında kullanacağız!**

---

## 📋 ADIM 10: Domain (Opsiyonel)

### 10.1. Ücretsiz Domain

- **Freenom** (https://www.freenom.com) - Ücretsiz .tk, .ml domain
- **No-IP** (https://www.noip.com) - Ücretsiz dynamic DNS

### 10.2. Nginx Reverse Proxy (Opsiyonel)

HTTPS için Nginx kurabilirsiniz (Let's Encrypt ile ücretsiz SSL).

---

## ✅ KONTROL LİSTESİ:

- [ ] Oracle Cloud hesabı oluşturuldu
- [ ] VPS (Compute Instance) oluşturuldu
- [ ] SSH ile bağlanıldı
- [ ] Node.js kuruldu
- [ ] PM2 kuruldu
- [ ] Backend kodu yüklendi
- [ ] Environment variables ayarlandı
- [ ] PM2 ile backend başlatıldı
- [ ] Firewall ayarları yapıldı
- [ ] Health check başarılı
- [ ] Backend URL alındı

---

## 🔧 SORUN GİDERME:

### SSH Bağlantı Hatası:
```bash
# Permission denied hatası
chmod 400 /path/to/your/private-key.key
```

### Port Erişim Hatası:
- Oracle Cloud Security List'te port 3000 açık olmalı
- `sudo ufw status` ile firewall kontrol edin

### PM2 Logları:
```bash
pm2 logs speedmail-backend
pm2 restart speedmail-backend
```

---

**Oracle Cloud VPS oluşturduktan sonra Public IP'yi paylaşın, adım adım ilerleyelim!** 🚀


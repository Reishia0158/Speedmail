# ☁️ Oracle Cloud - Hızlı Başlangıç

## 🎯 5 ADIMDA KURULUM:

### 1️⃣ Oracle Cloud Hesabı
- https://www.oracle.com/cloud/free/ → "Start for Free"
- Kredi kartı gerekli (ücret alınmaz)

### 2️⃣ VPS Oluştur
- "Create a VM Instance"
- Ubuntu 22.04
- VM.Standard.A1.Flex (Free Tier)
- 1 OCPU, 1GB RAM
- Public IP: ✅
- SSH Key: Generate (indirin!)

### 3️⃣ SSH Bağlan
```bash
chmod 400 /path/to/private-key.key
ssh -i /path/to/private-key.key ubuntu@YOUR_PUBLIC_IP
```

### 4️⃣ Node.js + PM2 Kur
```bash
sudo apt update
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2
```

### 5️⃣ Backend Deploy
```bash
# Backend dosyalarını yükleyin (GitHub veya SCP ile)
cd ~/speedmail-backend
npm install --production
nano .env  # Environment variables ekleyin
pm2 start server.js --name speedmail-backend
pm2 startup
pm2 save
```

---

## 🔥 FIREWALL:

```bash
sudo ufw allow 3000/tcp
sudo ufw enable
```

**Oracle Cloud Console'da:**
- Security Lists → Ingress Rule → Port 3000 açın

---

## ✅ TEST:

```
http://YOUR_PUBLIC_IP:3000/health
```

**Backend URL:** `http://YOUR_PUBLIC_IP:3000`

---

**VPS oluşturduktan sonra Public IP'yi paylaşın!** 🚀


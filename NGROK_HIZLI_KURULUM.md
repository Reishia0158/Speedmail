# 🚀 ngrok Hızlı Kurulum

## 📋 ADIM ADIM:

### 1. ngrok Kurulumu

**Homebrew ile (en kolay):**

```bash
brew install ngrok/ngrok/ngrok
```

**Veya manuel:**
1. https://ngrok.com/download → macOS indirin
2. ZIP'i açın
3. Terminal'de:
```bash
sudo mv ngrok /usr/local/bin/
```

---

### 2. ngrok Hesabı Oluşturun

1. **https://ngrok.com** → **"Sign up"** (ücretsiz)
2. **Email ile kayıt olun**
3. **Dashboard** → **"Your Authtoken"** kopyalayın

---

### 3. Authtoken Ayarlayın

Terminal'de:

```bash
ngrok config add-authtoken YOUR_AUTHTOKEN
```

---

### 4. Backend'i Başlatın

**Terminal 1:**
```bash
cd /Users/yunuskaynarpinar/Desktop/Speedmail/backend
npm install
node server.js
```

---

### 5. ngrok Başlatın

**Terminal 2 (yeni pencere):**
```bash
ngrok http 3000
```

**URL'i kopyalayın!** (Örnek: `https://abc123.ngrok-free.app`)

---

**ngrok kurulumunu yaptıktan sonra URL'i paylaşın!** 🚀


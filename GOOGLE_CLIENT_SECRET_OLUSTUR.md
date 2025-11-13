# 🔑 Google Client Secret Oluşturma

iOS OAuth client'larının **secret'ı yoktur**. Gmail Watch API için backend'den kullanmak için **Web Application** OAuth client oluşturmanız gerekiyor.

## 📋 ADIM ADIM:

### 1. Google Cloud Console'a gidin:
```
https://console.cloud.google.com/apis/credentials?project=speedmail-2e849
```

### 2. "OAuth 2.0 Client IDs" bölümünde **"+ CREATE CREDENTIALS"** butonuna tıklayın

### 3. "OAuth client ID" seçin

### 4. Application type seçin:
- **Application type:** `Web application` seçin (iOS değil!)

### 5. Bilgileri doldurun:
- **Name:** `Speedmail Backend` (veya istediğiniz isim)
- **Authorized JavaScript origins:** Boş bırakabilirsiniz
- **Authorized redirect URIs:** Boş bırakabilirsiniz (Gmail Watch için gerekli değil)

### 6. "CREATE" butonuna tıklayın

### 7. Secret'ı kopyalayın:
- Açılan popup'ta **"Client ID"** ve **"Client secret"** göreceksiniz
- **Client secret'ı kopyalayın** (bir daha gösterilmez!)

### 8. Fly.io'ya ekleyin:
```bash
fly secrets set GOOGLE_CLIENT_SECRET="kopyaladığınız-secret" -a speedmail-backend
```

---

## ⚠️ ÖNEMLİ:

- **iOS Client ID'yi kullanmayın** - Secret'ı yok
- **Web Application Client ID oluşturun** - Secret'ı var
- Backend'de hem iOS hem Web client ID'lerini kullanabilirsiniz

---

## 🔄 ALTERNATİF:

Eğer zaten bir Web Application client'ınız varsa:
1. OAuth 2.0 Client IDs listesinde bulun
2. Üzerine tıklayın
3. "Client secret" bölümünde "Show" butonuna tıklayın
4. Secret'ı kopyalayın


# 📬 Google Cloud Pub/Sub Kurulumu (Gmail Watch için)

Gmail Watch API'nin çalışması için Google Cloud Pub/Sub kurulumu gerekiyor.

## 📋 ADIM ADIM:

### 1. Google Cloud Console'a gidin:
```
https://console.cloud.google.com/cloudpubsub/topic/list?project=speedmail-2e849
```

### 2. Pub/Sub API'yi Aktif Et (Eğer aktif değilse):

**Yöntem 1: Console'dan:**
1. https://console.cloud.google.com/apis/library/pubsub.googleapis.com?project=speedmail-2e849
2. **"ENABLE"** butonuna tıklayın

**Yöntem 2: Terminal'den (gcloud kuruluysa):**
```bash
gcloud services enable pubsub.googleapis.com --project=speedmail-2e849
```

---

### 3. Pub/Sub Topic Oluştur:

**Yöntem 1: Console'dan (Önerilen):**
1. https://console.cloud.google.com/cloudpubsub/topic/list?project=speedmail-2e849
2. **"+ CREATE TOPIC"** butonuna tıklayın
3. **Topic ID:** `gmail-notifications` yazın
4. **"CREATE TOPIC"** butonuna tıklayın

**Yöntem 2: Terminal'den:**
```bash
gcloud pubsub topics create gmail-notifications --project=speedmail-2e849
```

---

### 4. Pub/Sub Subscription Oluştur:

**Yöntem 1: Console'dan (Önerilen):**
1. Oluşturduğunuz `gmail-notifications` topic'ine tıklayın
2. **"CREATE SUBSCRIPTION"** butonuna tıklayın
3. **Subscription ID:** `gmail-notifications-sub` yazın
4. **Delivery type:** `Push` seçin
5. **Endpoint URL:** `https://speedmail-backend.fly.dev/gmail-webhook` yazın
6. **"CREATE"** butonuna tıklayın

**Yöntem 2: Terminal'den:**
```bash
gcloud pubsub subscriptions create gmail-notifications-sub \
  --topic=gmail-notifications \
  --push-endpoint=https://speedmail-backend.fly.dev/gmail-webhook \
  --project=speedmail-2e849
```

---

### 5. Gmail API'ye İzin Ver:

1. https://console.cloud.google.com/apis/library/gmail.googleapis.com?project=speedmail-2e849
2. **"ENABLE"** butonuna tıklayın (eğer aktif değilse)

---

### 6. Service Account Oluştur (Gmail Watch için):

**Yöntem 1: Console'dan:**
1. https://console.cloud.google.com/iam-admin/serviceaccounts?project=speedmail-2e849
2. **"+ CREATE SERVICE ACCOUNT"** butonuna tıklayın
3. **Service account name:** `gmail-watch-service`
4. **"CREATE AND CONTINUE"** butonuna tıklayın
5. **Role:** `Pub/Sub Publisher` seçin
6. **"CONTINUE"** → **"DONE"** butonuna tıklayın

**Yöntem 2: Terminal'den:**
```bash
gcloud iam service-accounts create gmail-watch-service \
  --display-name="Gmail Watch Service" \
  --project=speedmail-2e849

gcloud projects add-iam-policy-binding speedmail-2e849 \
  --member="serviceAccount:gmail-watch-service@speedmail-2e849.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher"
```

---

## ✅ KONTROL LİSTESİ:

- [ ] Pub/Sub API aktif
- [ ] `gmail-notifications` topic oluşturuldu
- [ ] `gmail-notifications-sub` subscription oluşturuldu (Push endpoint: `https://speedmail-backend.fly.dev/gmail-webhook`)
- [ ] Gmail API aktif
- [ ] Service Account oluşturuldu (opsiyonel, Gmail Watch için gerekli değil)

---

## 🔍 KONTROL ETME:

### Topic'i kontrol et:
```
https://console.cloud.google.com/cloudpubsub/topic/detail/gmail-notifications?project=speedmail-2e849
```

### Subscription'ı kontrol et:
```
https://console.cloud.google.com/cloudpubsub/subscription/detail/gmail-notifications-sub?project=speedmail-2e849
```

---

## 📝 NOTLAR:

- **Push Endpoint:** Fly.io backend URL'iniz (`https://speedmail-backend.fly.dev/gmail-webhook`)
- **Topic Name:** Backend kodunda kullanılan topic adı (`gmail-notifications`)
- **Project ID:** `speedmail-2e849`

---

## 🎯 SONRAKI ADIMLAR:

Pub/Sub kurulumu tamamlandıktan sonra:
1. iOS uygulamasını çalıştırın
2. Gmail hesabını bağlayın
3. Gmail Watch otomatik olarak başlayacak
4. Test maili gönderin
5. Bildirim gelip gelmediğini kontrol edin

---

**Hazırsınız! Adım adım takip edin.** 🚀


# 🔧 Pub/Sub Project ID Hatası Çözümü

## ❌ HATA:
```
Invalid topicName does not match projects/speedmail-477818/topics/*
```

Backend'de `GOOGLE_PROJECT_ID = speedmail-2e849` ama hata `speedmail-477818` gösteriyor.

## 🔍 SORUN:

Pub/Sub topic'i **yanlış project'te** oluşturulmuş olabilir.

## ✅ ÇÖZÜM:

### Seçenek 1: Topic'i Doğru Project'te Oluştur (Önerilen)

1. **Google Cloud Console'a gidin:**
   ```
   https://console.cloud.google.com/cloudpubsub/topic/list?project=speedmail-2e849
   ```

2. **Eğer topic yoksa:**
   - **"+ CREATE TOPIC"** butonuna tıklayın
   - **Topic ID:** `gmail-notifications`
   - **"CREATE TOPIC"** butonuna tıklayın

3. **Eğer topic varsa ama yanlış project'teyse:**
   - Yanlış project'teki topic'i silin
   - Doğru project'te (`speedmail-2e849`) yeniden oluşturun

### Seçenek 2: Topic'in Project'ini Kontrol Et

1. **Topic detay sayfasına gidin:**
   ```
   https://console.cloud.google.com/cloudpubsub/topic/detail/gmail-notifications
   ```

2. **URL'deki project ID'yi kontrol edin:**
   - Doğru: `?project=speedmail-2e849`
   - Yanlış: `?project=speedmail-477818`

3. **Eğer yanlış project'teyse:**
   - Topic'i silin
   - Doğru project'te (`speedmail-2e849`) yeniden oluşturun

---

## 📋 ADIM ADIM:

### 1. Topic'i Kontrol Et:
```
https://console.cloud.google.com/cloudpubsub/topic/list?project=speedmail-2e849
```

### 2. Eğer Topic Yoksa veya Yanlış Project'teyse:

**Doğru Project'te Topic Oluştur:**
1. Üstteki project seçiciden **`speedmail-2e849`** seçin
2. **"+ CREATE TOPIC"** butonuna tıklayın
3. **Topic ID:** `gmail-notifications`
4. **"CREATE TOPIC"** butonuna tıklayın

### 3. Subscription'ı da Kontrol Et:
```
https://console.cloud.google.com/cloudpubsub/subscription/list?project=speedmail-2e849
```

**Eğer subscription yoksa veya yanlış project'teyse:**
1. Doğru project'te (`speedmail-2e849`) subscription oluşturun
2. **Subscription ID:** `gmail-notifications-sub`
3. **Topic:** `gmail-notifications`
4. **Push endpoint:** `https://speedmail-backend.fly.dev/gmail-webhook`

---

## 🎯 ÖNEMLİ:

- **Topic ve Subscription'ın AYNI project'te olması gerekiyor**
- **Project ID:** `speedmail-2e849` (backend'deki ile aynı)
- **Topic ID:** `gmail-notifications`
- **Subscription ID:** `gmail-notifications-sub`

---

**Topic'i doğru project'te (`speedmail-2e849`) oluşturduktan sonra tekrar deneyin!** 🚀


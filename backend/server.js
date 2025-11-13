const express = require('express');
const apn = require('apn');
const { google } = require('googleapis');
require('dotenv').config();

const app = express();
app.use(express.json());

// APNs Provider oluştur
// Fly.io'da .p8 dosyası base64 encoded secret olarak saklanır
let apnProvider = null;
if (process.env.APNS_KEY_BASE64 && process.env.APNS_KEY_ID && process.env.APNS_TEAM_ID) {
  // Base64 encoded key'i decode et
  const keyBuffer = Buffer.from(process.env.APNS_KEY_BASE64, 'base64');
  const keyPath = '/tmp/apns-key.p8';
  require('fs').writeFileSync(keyPath, keyBuffer);
  
  apnProvider = new apn.Provider({
    token: {
      key: keyPath,
      keyId: process.env.APNS_KEY_ID,
      teamId: process.env.APNS_TEAM_ID
    },
    production: process.env.NODE_ENV === 'production'
  });
  console.log('✅ APNs Provider yapılandırıldı');
} else if (process.env.APNS_KEY_PATH && process.env.APNS_KEY_ID && process.env.APNS_TEAM_ID) {
  // Local development için .p8 dosya yolu
  apnProvider = new apn.Provider({
    token: {
      key: process.env.APNS_KEY_PATH,
      keyId: process.env.APNS_KEY_ID,
      teamId: process.env.APNS_TEAM_ID
    },
    production: false
  });
  console.log('✅ APNs Provider yapılandırıldı (local)');
} else {
  console.log('⚠️ APNs Provider yapılandırılmadı - bildirimler gönderilemeyecek');
}

// Gmail Pub/Sub'dan gelen webhook'ları dinle
app.post('/gmail-webhook', async (req, res) => {
  try {
    const message = req.body.message;
    
    if (!message || !message.data) {
      console.log('⚠️ Geçersiz webhook verisi');
      return res.status(200).send('OK');
    }

    // Pub/Sub mesajını decode et
    const data = Buffer.from(message.data, 'base64').toString();
    const notification = JSON.parse(data);
    
    const { emailAddress, historyId } = notification;
    
    console.log(`📬 Gmail push alındı: ${emailAddress}, historyId: ${historyId}`);

    // Bu email için kayıtlı device token'ları al
    // (Gerçek uygulamada database'den çekilecek)
    const deviceTokens = await getDeviceTokens(emailAddress);
    
    if (deviceTokens.length === 0) {
      console.log(`⚠️ ${emailAddress} için device token bulunamadı`);
      return res.status(200).send('OK');
    }

    // APNs bildirimi gönder
    if (!apnProvider) {
      console.log('⚠️ APNs Provider yapılandırılmamış, bildirim gönderilemiyor');
      return res.status(200).send('OK');
    }

    const apnNotification = new apn.Notification({
      alert: {
        title: '📬 Yeni Mail',
        body: `${emailAddress} hesabınıza yeni mail geldi!`
      },
      sound: 'default',
      badge: 1,
      topic: process.env.APNS_BUNDLE_ID || 'com.yunuskaynarpinar.Speedmail', // Bundle ID
      payload: {
        email: emailAddress,
        historyId: historyId
      }
    });

    // Tüm cihazlara gönder
    for (const token of deviceTokens) {
      const result = await apnProvider.send(apnNotification, token);
      
      if (result.failed.length > 0) {
        console.error(`❌ APNs gönderme hatası: ${token}`, result.failed[0].response);
      } else {
        console.log(`✅ APNs bildirimi gönderildi: ${token}`);
      }
    }

    res.status(200).send('OK');
  } catch (error) {
    console.error('❌ Webhook işleme hatası:', error);
    res.status(500).send('Error');
  }
});

// Device token kaydetme endpoint'i
app.post('/register-device', async (req, res) => {
  try {
    const { email, deviceToken } = req.body;
    
    if (!email || !deviceToken) {
      return res.status(400).json({ error: 'Email ve deviceToken gerekli' });
    }

    // Device token'ı kaydet (gerçek uygulamada database'e)
    await saveDeviceToken(email, deviceToken);
    
    console.log(`✅ Device token kaydedildi: ${email}`);
    
    res.json({ success: true });
  } catch (error) {
    console.error('❌ Device token kaydetme hatası:', error);
    res.status(500).json({ error: error.message });
  }
});

// Gmail Watch başlatma endpoint'i
app.post('/setup-gmail-watch', async (req, res) => {
  try {
    const { email, accessToken, refreshToken } = req.body;
    
    if (!email || !accessToken) {
      return res.status(400).json({ error: 'Email ve accessToken gerekli' });
    }

    // OAuth2 client oluştur
    const oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET
    );
    
    oauth2Client.setCredentials({
      access_token: accessToken,
      refresh_token: refreshToken
    });

    const gmail = google.gmail({ version: 'v1', auth: oauth2Client });

    // Gmail Watch isteği gönder
    const response = await gmail.users.watch({
      userId: 'me',
      requestBody: {
        topicName: `projects/${process.env.GOOGLE_PROJECT_ID}/topics/gmail-notifications`,
        labelIds: ['INBOX']
      }
    });

    console.log(`✅ Gmail watch başlatıldı: ${email}`);
    console.log(`   History ID: ${response.data.historyId}`);
    console.log(`   Expiration: ${new Date(parseInt(response.data.expiration))}`);

    res.json({
      success: true,
      historyId: response.data.historyId,
      expiration: response.data.expiration
    });
  } catch (error) {
    console.error('❌ Gmail watch hatası:', error);
    res.status(500).json({ error: error.message });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Basit in-memory storage (gerçek uygulamada database kullanın)
const deviceTokenStore = new Map();

async function saveDeviceToken(email, deviceToken) {
  if (!deviceTokenStore.has(email)) {
    deviceTokenStore.set(email, new Set());
  }
  deviceTokenStore.get(email).add(deviceToken);
}

async function getDeviceTokens(email) {
  const tokens = deviceTokenStore.get(email);
  return tokens ? Array.from(tokens) : [];
}

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Speedmail Backend çalışıyor: http://0.0.0.0:${PORT}`);
  console.log(`📱 APNs: ${process.env.APNS_KEY_ID ? 'Yapılandırıldı' : 'Yapılandırılmadı'}`);
  console.log(`🌍 Railway.app: ${process.env.RAILWAY_ENVIRONMENT ? `Deployed on Railway` : 'Local'}`);
});


#!/bin/bash

cd /Users/yunuskaynarpinar/Desktop/Speedmail/backend

# Environment variables
export APNS_KEY_BASE64="LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR1RBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJIa3dkd0lCQVFRZzBRbHYwd09YZlZKUzRCbTAKaEU5UW9YaHhxSzJsMzQycTJGNG1HZUs3Q2s2Z0NnWUlLb1pJemowREFRZWhSQU5DQUFSUDgrcWp0U0F2Z2lHOQphNTdSbmsyTUIvWjRvbnkyeWtvYXJJT0E4K2ROMlYxUkt6U3QxM01EQVpHc2RSa3FCalBobnBWQmp1VHI4emNKCkptUGo5YkVPCi0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0="
export APNS_KEY_ID="HH9Z3X32PQ"
export APNS_TEAM_ID="B79NG6JX9A"
export APNS_BUNDLE_ID="com.yunuskaynarpinar.Speedmail"
export GOOGLE_PROJECT_ID="speedmail-2e849"
export GOOGLE_CLIENT_ID="YOUR_GOOGLE_CLIENT_ID"
export GOOGLE_CLIENT_SECRET="YOUR_GOOGLE_CLIENT_SECRET"
export NODE_ENV="production"
export PORT="3000"

# Dependencies yükle (ilk kez)
if [ ! -d "node_modules" ]; then
    echo "📦 Dependencies yükleniyor..."
    npm install
fi

# Backend'i başlat
echo "🚀 Backend başlatılıyor..."
node server.js


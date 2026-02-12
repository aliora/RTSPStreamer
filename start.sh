#!/bin/bash

echo "🚀 RTSP Web Viewer Başlatılıyor..."
echo ""

# Renk kodları
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Node modüllerini kontrol et
if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}📦 Node modülleri kuruluyor...${NC}"
    npm install
    echo ""
fi

# Streams dizinini oluştur ve izinleri ayarla
mkdir -p streams
if [ -d "streams" ]; then
    chmod 777 streams
fi

# Sunucuyu başlat
echo -e "${GREEN}✅ Sunucu başlatılıyor...${NC}"
echo -e "${GREEN}🌐 Tarayıcınızda http://localhost:3333 adresini açın${NC}"
echo ""
echo "Durdurmak için CTRL+C tuşlarına basın"
echo ""

node server.js

#!/bin/bash

# Renkler
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${GREEN}📹 RTSP Web Viewer (Python/OpenCV) Başlatılıyor...${NC}"
echo ""

# Venv kontrolü
if [ ! -d "venv" ]; then
    echo -e "${RED}❌ Sanal ortam (venv) bulunamadı!${NC}"
    echo -e "${YELLOW}Önce kurulum yapın: ./install.sh${NC}"
    exit 1
fi

# Sanal ortamı aktif et
echo -e "${GREEN}→${NC} Sanal ortam aktif ediliyor..."
source venv/bin/activate

# Sunucuyu başlat
echo -e "${GREEN}→${NC} Python sunucusu başlatılıyor (Port: 3333)..."
echo ""
python3 server.py

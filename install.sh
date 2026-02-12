#!/bin/bash

# RTSP Web Viewer - Python Kurulum Scripti
# Ubuntu için tasarlanmıştır

set -e  # Hata durumunda dur

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                  ║${NC}"
echo -e "${BLUE}║    📹 RTSP Web Viewer (Python/OpenCV) Kurulum    ║${NC}"
echo -e "${BLUE}║                                                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Root kontrolü
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Bu scripti root olarak çalıştırmayın!${NC}"
    echo -e "${YELLOW}Normal kullanıcı ile çalıştırın: ./install.sh${NC}"
    exit 1
fi

echo -e "${GREEN}[1/5]${NC} Sistem kontrolü yapılıyor..."

# Ubuntu kontrolü
if [ ! -f /etc/lsb-release ]; then
    echo -e "${RED}❌ Bu script Ubuntu için tasarlanmıştır!${NC}"
    exit 1
fi

source /etc/lsb-release
echo -e "${GREEN}✓${NC} İşletim Sistemi: Ubuntu $DISTRIB_RELEASE"

# Paket güncelleme ve Python gereksinimleri
echo ""
echo -e "${GREEN}[2/5]${NC} Sistem paketleri ve Python gereksinimleri kuruluyor..."
sudo apt update -qq
echo "Paketler yükleniyor (detaylar görünecek)..."
sudo apt install -y python3 python3-pip python3-venv libgl1 libglib2.0-0
echo -e "${GREEN}✓${NC} Python3 ve gerekli kütüphaneler kuruldu"

# Sanal ortam oluşturma
echo ""
echo -e "${GREEN}[3/5]${NC} Sanal ortam (venv) oluşturuluyor..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✓${NC} venv oluşturuldu"
else
    echo -e "${GREEN}✓${NC} venv zaten mevcut"
fi

# Bağımlılıkları yükleme
echo ""
echo -e "${GREEN}[4/5]${NC} Python kütüphaneleri yükleniyor..."
source venv/bin/activate
pip install --upgrade pip --quiet
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    echo -e "${GREEN}✓${NC} Kütüphaneler yüklendi"
else
    echo -e "${RED}❌ requirements.txt bulunamadı!${NC}"
    exit 1
fi

# Dizin yapısı
echo ""
echo -e "${GREEN}[5/5]${NC} Proje yapısı hazırlanıyor..."
mkdir -p public
echo -e "${GREEN}✓${NC} Dizinler hazır"

# Kurulum tamamlandı
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                  ║${NC}"
echo -e "${BLUE}║         ${GREEN}✅ Kurulum Başarıyla Tamamlandı!${BLUE}         ║${NC}"
echo -e "${BLUE}║                                                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🚀 Başlatmak için:${NC}"
echo -e "   ${YELLOW}./start.sh${NC}"
echo ""
echo -e "${GREEN}🌐 Ardından tarayıcınızda:${NC}"
echo -e "   ${YELLOW}http://localhost:3333${NC}"
echo ""

# Otomatik başlatma seçeneği
read -p "Şimdi sunucuyu başlatmak ister misiniz? (e/h): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ee]$ ]]; then
    echo ""
    echo -e "${GREEN}→ Sunucu başlatılıyor...${NC}"
    sleep 1
    ./start.sh
fi

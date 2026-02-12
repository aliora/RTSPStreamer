#!/bin/bash

# RTSP Web Viewer - Otomatik Kurulum Scripti
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
echo -e "${BLUE}║         📹 RTSP Web Viewer Kurulum               ║${NC}"
echo -e "${BLUE}║                                                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Root kontrolü
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Bu scripti root olarak çalıştırmayın!${NC}"
    echo -e "${YELLOW}Normal kullanıcı ile çalıştırın: ./install.sh${NC}"
    exit 1
fi

echo -e "${GREEN}[1/6]${NC} Sistem kontrolü yapılıyor..."

# Ubuntu kontrolü
if [ ! -f /etc/lsb-release ]; then
    echo -e "${RED}❌ Bu script Ubuntu için tasarlanmıştır!${NC}"
    exit 1
fi

source /etc/lsb-release
echo -e "${GREEN}✓${NC} İşletim Sistemi: Ubuntu $DISTRIB_RELEASE"

# Paket güncelleme
echo ""
echo -e "${GREEN}[2/6]${NC} Sistem paketleri güncelleniyor..."
sudo apt update -qq

# FFmpeg kurulumu
echo ""
echo -e "${GREEN}[3/6]${NC} FFmpeg kontrol ediliyor..."
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}→${NC} FFmpeg kuruluyor..."
    sudo apt install -y ffmpeg > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} FFmpeg kuruldu"
else
    FFMPEG_VERSION=$(ffmpeg -version | head -n1 | cut -d' ' -f3)
    echo -e "${GREEN}✓${NC} FFmpeg zaten kurulu (Versiyon: $FFMPEG_VERSION)"
fi

# Node.js kurulumu
echo ""
echo -e "${GREEN}[4/6]${NC} Node.js kontrol ediliyor..."
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}→${NC} Node.js kuruluyor..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - > /dev/null 2>&1
    sudo apt install -y nodejs > /dev/null 2>&1
    echo -e "${GREEN}✓${NC} Node.js kuruldu"
else
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓${NC} Node.js zaten kurulu ($NODE_VERSION)"
fi

# npm kontrol
if ! command -v npm &> /dev/null; then
    echo -e "${YELLOW}→${NC} npm kuruluyor..."
    sudo apt install -y npm > /dev/null 2>&1
fi

NPM_VERSION=$(npm -v)
echo -e "${GREEN}✓${NC} npm kurulu (Versiyon: $NPM_VERSION)"

# Node modülleri kurulumu
echo ""
echo -e "${GREEN}[5/6]${NC} Node.js bağımlılıkları kuruluyor..."
if [ ! -d "node_modules" ]; then
    npm install --silent
    echo -e "${GREEN}✓${NC} Bağımlılıklar kuruldu"
else
    echo -e "${GREEN}✓${NC} Bağımlılıklar zaten kurulu"
fi

# Dizin yapısını oluştur
echo ""
echo -e "${GREEN}[6/6]${NC} Proje yapısı oluşturuluyor..."
mkdir -p streams
mkdir -p public
echo -e "${GREEN}✓${NC} Dizinler oluşturuldu"

# Port kontrolü
PORT=3000
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo ""
    echo -e "${YELLOW}⚠ Port $PORT kullanımda!${NC}"
    echo -e "${YELLOW}Sunucuyu başlatmadan önce bu portu kullanmayı bırakın veya server.js dosyasında PORT değerini değiştirin.${NC}"
fi

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
echo -e "   ${YELLOW}http://localhost:3000${NC}"
echo ""
echo -e "${GREEN}📝 Servis olarak çalıştırmak için:${NC}"
echo -e "   ${YELLOW}sudo ./service-install.sh${NC}"
echo ""
echo -e "${GREEN}📖 Daha fazla bilgi için:${NC}"
echo -e "   ${YELLOW}cat README.md${NC}"
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

#!/bin/bash

# RTSP Web Viewer - Servis Kurulum Scripti
# Uygulamayı sistem servisi olarak çalıştırır

# Renkler
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Root kontrolü
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Bu scripti sudo ile çalıştırın: sudo ./service-install.sh${NC}"
    exit 1
fi

# Kullanıcı ve dizin bilgisi
CURRENT_USER=${SUDO_USER:-$USER}
CURRENT_DIR=$(pwd)
SERVICE_NAME="rtsp-viewer"

echo ""
echo -e "${GREEN}=== RTSP Viewer Servis Kurulumu ===${NC}"
echo ""
echo -e "Kullanıcı: ${YELLOW}$CURRENT_USER${NC}"
echo -e "Dizin: ${YELLOW}$CURRENT_DIR${NC}"
echo ""

# Systemd servis dosyası oluştur
echo -e "${GREEN}→${NC} Servis dosyası oluşturuluyor..."

cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=RTSP Web Viewer Service
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$CURRENT_DIR
ExecStart=$CURRENT_DIR/venv/bin/python $CURRENT_DIR/server.py
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=rtsp-viewer

[Install]
WantedBy=multi-user.target
EOF

# Systemd'yi yeniden yükle
echo -e "${GREEN}→${NC} Systemd yeniden yükleniyor..."
systemctl daemon-reload

# Servisi etkinleştir
echo -e "${GREEN}→${NC} Servis etkinleştiriliyor..."
systemctl enable ${SERVICE_NAME}.service

# Servisi başlat
echo -e "${GREEN}→${NC} Servis başlatılıyor..."
systemctl start ${SERVICE_NAME}.service

# Durum kontrolü
sleep 2
if systemctl is-active --quiet ${SERVICE_NAME}.service; then
    echo ""
    echo -e "${GREEN}✅ Servis başarıyla kuruldu ve başlatıldı!${NC}"
    echo ""
    echo -e "${GREEN}Kullanılabilir komutlar:${NC}"
    echo -e "  ${YELLOW}sudo systemctl status ${SERVICE_NAME}${NC}   - Durum kontrolü"
    echo -e "  ${YELLOW}sudo systemctl stop ${SERVICE_NAME}${NC}     - Durdur"
    echo -e "  ${YELLOW}sudo systemctl start ${SERVICE_NAME}${NC}    - Başlat"
    echo -e "  ${YELLOW}sudo systemctl restart ${SERVICE_NAME}${NC}  - Yeniden başlat"
    echo -e "  ${YELLOW}sudo journalctl -u ${SERVICE_NAME} -f${NC}  - Logları izle"
    echo ""
    echo -e "${GREEN}🌐 Tarayıcıda:${NC} ${YELLOW}http://localhost:3333${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Servis başlatılamadı!${NC}"
    echo -e "Hata detayları:"
    systemctl status ${SERVICE_NAME}.service
fi

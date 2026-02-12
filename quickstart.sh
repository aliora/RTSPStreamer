#!/bin/bash

# Hızlı Başlangıç Scripti
# Tek adımda kurulum ve çalıştırma

clear

cat << "EOF"
 ____  _____ ____  ____   
|  _ \|_   _/ ___||  _ \  
| |_) | | | \___ \| |_) | 
|  _ <  | |  ___) |  __/  
|_| \_\ |_| |____/|_|     
                          
 __     ___                     
 \ \   / (_) _____      _____ _ __ 
  \ \ / /| |/ _ \ \ /\ / / _ \ '__|
   \ V / | |  __/\ V  V /  __/ |   
    \_/  |_|\___| \_/\_/ \___|_|   

EOF

echo "🚀 RTSP Web Viewer - Hızlı Başlangıç"
echo ""
echo "Bu script şunları yapacak:"
echo "  1. Sistem gereksinimlerini kontrol eder"
echo "  2. Eksik paketleri kurar"
echo "  3. Uygulamayı başlatır"
echo ""
read -p "Devam etmek için ENTER'a basın..."

# Kurulum scriptini çalıştır
if [ -f "install.sh" ]; then
    chmod +x install.sh
    ./install.sh
else
    echo "❌ install.sh bulunamadı!"
    exit 1
fi

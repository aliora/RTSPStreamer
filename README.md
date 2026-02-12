# 📹 RTSP Web Viewer

Ubuntu üzerinde RTSP kamera akışlarını web tarayıcısından izleme uygulaması.

## ⚡ Hızlı Başlangıç

```bash
chmod +x install.sh
./install.sh
```

Kurulum tamamlandıktan sonra:
```bash
./start.sh
```

Tarayıcıda aç: **http://localhost:3333**

## 🎯 Özellikler

- Maksimum 4 RTSP akışı
- Canlı video izleme
- Sade ve modern tasarım
- Kolay kurulum
- Otomatik başlatma

## 📖 Detaylı Kurulum

Tüm detaylar için: **[KURULUM.md](KURULUM.md)** dosyasını okuyun.

## 🎥 Kullanım

1. **Akış Ekle** butonuna tıklayın
2. RTSP URL'sini girin:
   ```
   rtsp://kullanıcı:şifre@192.168.1.100:554/stream1
   ```
3. Video otomatik oynatılır

## ⚙️ Servis Olarak Çalıştır

```bash
sudo ./service-install.sh
```

Komutlar:
```bash
sudo systemctl status rtsp-viewer   # Durum
sudo systemctl restart rtsp-viewer  # Yeniden başlat
sudo systemctl stop rtsp-viewer     # Durdur
```

## 🐛 Sorun mu var?

[KURULUM.md](KURULUM.md) dosyasındaki **"Sorun Giderme"** bölümüne bakın.

## 📝 Lisans

MIT

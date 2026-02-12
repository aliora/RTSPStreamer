# 📹 RTSP Web Viewer - Kurulum Kılavuzu

Ubuntu üzerinde RTSP kamera akışlarını web tarayıcısından izlemenizi sağlayan uygulama.

## 🎯 Özellikler

- ✅ Maksimum 4 RTSP akışı
- ✅ Web tarayıcıdan canlı izleme
- ✅ Kolay kurulum (tek komut)
- ✅ Modern ve sade tasarım
- ✅ Otomatik başlatma desteği

---

## 📋 Sistem Gereksinimleri

- **İşletim Sistemi:** Ubuntu 20.04 veya üzeri
- **İşlemci:** 2 çekirdek veya daha fazla
- **RAM:** Minimum 2GB
- **Disk:** 500MB boş alan

---

## 🚀 Hızlı Kurulum (Otomatik)

### 1. Proje klasörüne gidin
```bash
cd rtsp-web-viewer
```

### 2. Kurulum scriptini çalıştırılabilir yapın
```bash
chmod +x install.sh start.sh service-install.sh
```

### 3. Kurulumu başlatın
```bash
./install.sh
```

Script otomatik olarak:
- ✅ Sistem gereksinimlerini kontrol eder
- ✅ FFmpeg kurulumunu yapar
- ✅ Node.js kurulumunu yapar
- ✅ Gerekli paketleri indirir
- ✅ Uygulamayı hazır hale getirir

### 4. Uygulamayı başlatın
Kurulum sonunda sorar veya manuel olarak:
```bash
./start.sh
```

### 5. Tarayıcınızda açın
```
http://localhost:3000
```

---

## 🔧 Manuel Kurulum

Eğer otomatik kurulumda sorun yaşarsanız:

### 1. Sistem paketlerini güncelleyin
```bash
sudo apt update
```

### 2. FFmpeg kurun
```bash
sudo apt install ffmpeg -y
```

### 3. Node.js kurun
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs -y
```

### 4. Bağımlılıkları kurun
```bash
npm install
```

### 5. Başlatın
```bash
npm start
```

---

## 🎥 Kullanım

### RTSP Akışı Eklemek

1. Sağ üstteki **"+ Akış Ekle"** butonuna tıklayın
2. Akış bilgilerini girin:
   - **Akış Adı:** Örn: "Ön Kapı Kamerası"
   - **RTSP URL:** Kamera bağlantı adresi

#### RTSP URL Formatı:
```
rtsp://kullanıcı:şifre@ip_adresi:port/stream_yolu
```

#### Örnekler:
```
rtsp://admin:12345@192.168.1.100:554/stream1
rtsp://user:pass@192.168.1.50:8554/live
rtsp://kamera:sifre@192.168.0.10/h264
```

### Akış Silmek

Her akış kartının üstünde **"Sil"** butonu vardır. Tıklayıp onaylayın.

---

## ⚙️ Servis Olarak Çalıştırma

Uygulamanın sistem başlangıcında otomatik çalışması için:

```bash
sudo ./service-install.sh
```

### Servis Komutları:

```bash
# Durumu kontrol et
sudo systemctl status rtsp-viewer

# Durdur
sudo systemctl stop rtsp-viewer

# Başlat
sudo systemctl start rtsp-viewer

# Yeniden başlat
sudo systemctl restart rtsp-viewer

# Logları izle
sudo journalctl -u rtsp-viewer -f
```

### Servisi Kaldır:
```bash
sudo systemctl stop rtsp-viewer
sudo systemctl disable rtsp-viewer
sudo rm /etc/systemd/system/rtsp-viewer.service
sudo systemctl daemon-reload
```

---

## 🔧 Yapılandırma

### Port Değiştirme

`server.js` dosyasını düzenleyin:
```javascript
const PORT = 3000;  // İstediğiniz port
```

### Maksimum Akış Sayısı

`server.js` dosyasında:
```javascript
if (streamConfigs.length >= 4) {  // 4 yerine istediğiniz sayı
```

### FFmpeg Kalite Ayarları

`server.js` içinde FFmpeg parametreleri:
```javascript
'-hls_time', '2',          // Segment süresi (saniye)
'-hls_list_size', '3',     // Kaç segment tutulacak
```

Daha düşük gecikme için:
```javascript
'-hls_time', '1',
'-hls_list_size', '2',
```

---

## 🐛 Sorun Giderme

### Video oynatılmıyor

**1. RTSP URL'sini kontrol edin:**
```bash
ffmpeg -i "rtsp://kullanıcı:şifre@ip:port/stream" -frames:v 1 test.jpg
```
Hata veriyorsa URL yanlış.

**2. Kameraya erişimi test edin:**
```bash
ping ip_adresi
```

**3. Tarayıcı konsolunu kontrol edin:**
F12 tuşuna basıp Console sekmesine bakın.

### Port 3000 kullanımda

**Hangi program kullanıyor:**
```bash
sudo lsof -i :3000
```

**Programı durdurun veya farklı port kullanın**

### FFmpeg kurulu değil

```bash
ffmpeg -version
```
Hata verirse:
```bash
sudo apt install ffmpeg -y
```

### Node.js eski versiyon

```bash
node -v
```
14'ten eski ise:
```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs -y
```

### Modüller bulunamadı

```bash
rm -rf node_modules package-lock.json
npm install
```

---

## 📊 Performans İpuçları

### Çoklu Akış İçin

- **CPU:** 4 akış için minimum 4 çekirdek önerilir
- **RAM:** Akış başına ~500MB hesaplayın
- **Ağ:** Her akış için 2-5 Mbps bant genişliği

### Gecikmeyi Azaltma

1. `server.js` içinde:
```javascript
'-hls_time', '1',
'-hls_list_size', '2',
```

2. RTSP bağlantısını UDP yerine TCP kullanın (varsayılan)

---

## 🔒 Güvenlik

### Üretim Ortamında

1. **HTTPS kullanın** (Nginx ile reverse proxy)
2. **Firewall kuralları:**
```bash
sudo ufw allow 3000/tcp
sudo ufw enable
```

3. **Sadece yerel ağdan erişim:**
`server.js` içinde:
```javascript
app.listen(PORT, 'localhost', () => {
```

4. **Güçlü kamera şifreleri** kullanın

---

## 📝 Ek Bilgiler

### Desteklenen Tarayıcılar

- ✅ Chrome / Chromium
- ✅ Firefox
- ✅ Safari
- ✅ Edge

### HLS Hakkında

Uygulama RTSP akışlarını HLS (HTTP Live Streaming) formatına dönüştürür.
- ⚠️ 2-6 saniye gecikme normaldir
- ✅ Daha geniş tarayıcı desteği
- ✅ Daha kararlı bağlantı

### Log Dosyaları

Servis olarak çalışıyorsa:
```bash
sudo journalctl -u rtsp-viewer -f
```

Normal çalışmada:
Terminal çıktısında görürsünüz.

---

## 💬 Destek

Sorun yaşıyorsanız:

1. Bu dosyayı baştan sona okuyun
2. README.md dosyasını kontrol edin
3. Terminal hata mesajlarını inceleyin
4. FFmpeg ve Node.js versiyonlarını kontrol edin

---

## 📜 Lisans

MIT License - Özgürce kullanabilirsiniz.

---

**🎉 Başarılar! Sorularınız için dokümantasyonu okuyun.**

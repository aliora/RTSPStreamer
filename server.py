import cv2
import threading
import time
from flask import Flask, Response, jsonify, request, send_from_directory
from flask_cors import CORS
import os

app = Flask(__name__, static_folder='public')
CORS(app)

PORT = 3333
STREAMS = {}

# Kamera sınıfı - Her kamera için ayrı thread
class VideoCamera(object):
    def __init__(self, rtsp_url, stream_id):
        self.rtsp_url = rtsp_url
        self.stream_id = stream_id
        self.video = cv2.VideoCapture(self.rtsp_url)
        self.lock = threading.Lock()
        self.frame = None
        self.running = True
        self.thread = threading.Thread(target=self.update, args=())
        self.thread.daemon = True
        self.thread.start()
        self.last_frame_time = time.time()

    def __del__(self):
        self.stop()
        if self.video.isOpened():
            self.video.release()

    def stop(self):
        self.running = False
        if self.thread.is_alive():
            try:
                self.thread.join(timeout=1.0)
            except:
                pass

    def update(self):
        reconnect_interval = 5
        while self.running:
            if not self.video.isOpened():
                print(f"[{self.stream_id}] Bağlantı kapalı, yeniden bağlanılıyor...")
                self.video = cv2.VideoCapture(self.rtsp_url)
                if not self.video.isOpened():
                    time.sleep(reconnect_interval)
                    continue
            
            success, frame = self.video.read()
            if success:
                # Frame boyutunu optimize et (opsiyonel, bant genişliği için)
                # frame = cv2.resize(frame, (640, 360))
                
                # Sıkıştırma kalitesi - %60 (Bant genişliği dostu)
                with self.lock:
                    ret, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 60])
                    if ret:
                        self.frame = buffer.tobytes()
                        self.last_frame_time = time.time()
                
                # FPS kontrolü (gereksiz CPU kullanımı önleme)
                time.sleep(0.03) # ~30 FPS
            else:
                print(f"[{self.stream_id}] Frame okunamadı, yeniden bağlanılıyor...")
                self.video.release()
                time.sleep(reconnect_interval)

    def get_frame(self):
        with self.lock:
            return self.frame

# Root endpoint - Frontend'i sunar
@app.route('/')
def index():
    return send_from_directory('public', 'index.html')

# Diğer statik dosyalar için (örn. css, js)
@app.route('/<path:path>')
def static_files(path):
    return send_from_directory('public', path)

# API: Akış ekle
@app.route('/api/streams', methods=['POST'])
def add_stream():
    data = request.json
    rtsp_url = data.get('rtspUrl')
    name = data.get('name')
    
    if not rtsp_url:
        return jsonify({'error': 'RTSP URL gerekli'}), 400
        
    if len(STREAMS) >= 4:
        return jsonify({'error': 'Maksimum 4 akış eklenebilir'}), 400
        
    stream_id = f"stream_{int(time.time()*1000)}"
    
    # Yeni kamera başlat
    try:
        camera = VideoCamera(rtsp_url, stream_id)
        STREAMS[stream_id] = {
            'id': stream_id,
            'name': name or f"Kamera {len(STREAMS)+1}",
            'rtspUrl': rtsp_url,
            'camera_obj': camera
        }
        
        return jsonify({
            'id': stream_id,
            'name': STREAMS[stream_id]['name'],
            'rtspUrl': rtsp_url,
            'mjpegUrl': f"/video_feed/{stream_id}"
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# API: Akışları listele
@app.route('/api/streams', methods=['GET'])
def get_streams():
    result = []
    for s_id, data in STREAMS.items():
        result.append({
            'id': s_id,
            'name': data['name'],
            'rtspUrl': data['rtspUrl'],
            'mjpegUrl': f"/video_feed/{s_id}"
        })
    return jsonify(result)

# API: Akış sil
@app.route('/api/streams/<id>', methods=['DELETE'])
def delete_stream(id):
    if id in STREAMS:
        # Kamerayı durdur ve temizle
        STREAMS[id]['camera_obj'].stop()
        del STREAMS[id]
        return jsonify({'success': True})
    return jsonify({'error': 'Akış bulunamadı'}), 404

# Video Feed (MJPEG Generatör)
def gen(camera):
    while True:
        frame = camera.get_frame()
        if frame is not None:
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
        else:
            # Frame yoksa boş bekle
            time.sleep(0.1)

@app.route('/video_feed/<id>')
def video_feed(id):
    if id not in STREAMS:
        return "Stream not found", 404
        
    return Response(gen(STREAMS[id]['camera_obj']),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    # Public klasörü yoksa oluştur
    if not os.path.exists('public'):
        os.makedirs('public')
        
    print(f"RTSP Web Viewer (Python/OpenCV) başlatılıyor...")
    print(f"Port: {PORT}")
    app.run(host='0.0.0.0', port=PORT, threaded=True, debug=False)

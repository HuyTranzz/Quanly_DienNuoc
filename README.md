# 📘 Quản Lý Điện Nước Khu Phố — Flutter + ESP32 + MQTT

Đây là ứng dụng giám sát và điều khiển điện – nước cho từng hộ gia đình trong khu phố, sử dụng:
- ESP32 DevKit V1 → thu thập dữ liệu và nhận lệnh từ app
- Flutter App → theo dõi điện – nước realtime và điều khiển thiết bị
- HiveMQ Cloud / broker.hivemq.com → làm MQTT Broker trung gian
- MQTT WebSocket Client → dùng để kiểm tra topic khi debug

Hệ thống sử dụng giao thức MQTT để truyền dữ liệu nhanh, ổn định và realtime giữa app và thiết bị IoT.

---

## 🚀 1. Tính năng chính
📱 Tính năng của App Flutter

- Hiển thị trạng thái Điện (BẬT / TẮT) theo thời gian thực
- Hiển thị thông số tiêu thụ điện, nước
- Điều khiển điện từ xa qua MQTT
- Giới hạn ngưỡng điện – nước
- Hiện thị giao diện cảnh báo khi vượt ngưỡng điện/nước
- Kết nối nhanh đến MQTT Broker
- Dữ liệu realtime thông qua HiveMQ Dashboard
- Đăng nhập cơ bản (màn hình Login)

⚙ Tính năng của ESP32

- Kết nối đến MQTT Broker (broker.hivemq.com)
- Publish dữ liệu điện – nước
- Nhận dữ liệu ngưỡng điện/nước
- Nhận lệnh ON/OFF thiết bị
- Điều khiển 2 LED mô phỏng:
- LED 1 → điện/bật tắt/nhấp nháy khi vượt ngưỡng
- LED 2 → nước/bật tắt/nhấp nháy khi vượt ngưỡng

---

## 🔌 2. Yêu cầu phần cứng

| Thiết bị        | Số lượng | Ghi chú                  |
| --------------- | -------- | ------------------------ |
| ESP32 DevKit V1 | 1        | Main controller          |
| LED bất kỳ      | 2        | LED mô phỏng điện + nước |
| Điện trở 220Ω   | 2        | Hạn dòng cho LED         |

### Sơ đồ nối dây (ESP32 → LED)

| ESP32 Pin | Thiết bị                        |
| --------- | --------------------------------|
| GPIO 4    | LED điện chân dương qua trở 220Ω|
| GPIO 19   | LED nước chân dương qua trở 220Ω|
| GND       | Chân âm LED nối chung           |

Bạn có thể thay đổi chân trong code tùy nhu cầu.

---

## 🖥 3. Yêu cầu phần mềm

### App Flutter

- Flutter SDK
- VSCode + Flutter extension
- Android SDK
- Thư viện sử dụng trong pubspec.yaml:
  
```
cupertino_icons: ^1.0.8
mqtt_client: ^10.11.1
```

### Android Internet Permissions (Android/app/src/main/AndroidManifest.xml)

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <application>
        ...
    </application>
</manifest>
```

--- 

## 🌐 4. Kiến trúc MQTT sử dụng trong dự án

MQTT Broker sử dụng:
```
broker.hivemq.com
```

https://www.mqtt-dashboard.com/

Dự án sử dụng các topic mẫu:

| Topic                        | Mục đích                 |
| -----------------------------| -------------------------|
| khuPho/1/ho/1/dien           | ESP32 gửi dữ liệu điện   |
| khuPho/1/ho/1/nuoc           | ESP32 gửi dữ liệu nước   |
| khuPho/1/ho/1/cmd_dien       | Điều khiển bật/tắt điện  |
| khuPho/1/ho/1/cmd_nuoc       | Điều khiển bật/tắt nước  |
| khuPho/1/ho/1/canhbao_dien   | Gửi cảnh báo điện        |
| khuPho/1/ho/1/canhbao_nuoc   | Gửi cảnh báo nước        |
| khuPho/1/ho/1/set_limit_dien | Đặt ngưỡng điện (App)    |
| khuPho/1/ho/1/set_limit_nuoc | Đặt ngưỡng nước (App)    |

Sử dụng kèm HiveMQ Dashboard

https://www.hivemq.com/demos/websocket-client/

- Quan sát message
- Test subscribe/publish
- Debug ESP32 + App

---

## 📲 5. Cách chạy App Flutter trên VSCode

### Bước 1 — Clone dự án
```
git clone https://github.com/HuyTranzz/Quanly_DienNuoc.git
cd Quanly_DienNuoc
```

### Bước 2 — Cài các gói Flutter
```
flutter pub get
```
### Bước 3 — Chạy ứng dụng
```
flutter run
```
Lưu ý: bật Internet trên thiết bị Android vì app cần kết nối MQTT.

---

## 🔧 6. Chạy ESP32

### Bước 1 — Cài đặt PlatformIO hoặc Arduino IDE

Khuyến nghị: Arduino IDE cho người mới.

### Bước 2 — Cấu hình WiFi + MQTT Broker trong code
```
const char* mqtt_server = "broker.hivemq.com";
```

### Bước 3 — Nạp code vào ESP32

Kết nối ESP32 → nhấn Upload → mở Serial Monitor để xem log.

---

## 🌍 7. Kiểm tra dữ liệu bằng MQTT WebSocket Client

Truy cập: https://www.hivemq.com/demos/websocket-client/

- Nhập host: broker.hivemq.com
- Port WebSocket: 8000
- Kết nối
- Subscribe các topic bạn dùng để kiểm tra dữ liệu realtime

---

## 📂 8. Cấu trúc dự án Flutter (tóm tắt)

```
  lib/
 ├── main.dart
 ├── process/
 │    └── dien_card.dart
 |    └── nuoc_card.dart
 |    └── sensor_card.dart
 ├── screens/
 │    └── household_screen.dart
 |    └── login_screen.dart
 |    └── main_screen.dart
 |    └── settings_screen.dart
 └── services/
      └── mqtt_service.dart
```


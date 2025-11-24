#include <WiFi.h>
#include <PubSubClient.h>

// ===== Thông tin WiFi =====
const char* ssid = "Thang Tran";
const char* password = "thangvip321";

// ===== MQTT Broker =====
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

// ===== Các chân LED =====
const int ledDien = 4;  // LED cho thiết bị điện
const int ledNuoc = 5;  // LED cho thiết bị nước

// ===== Topics MQTT =====
const char* topicDien = "khuPho/1/ho/1/dien";
const char* topicNuoc = "khuPho/1/ho/1/nuoc";
const char* topicCmdDien = "khuPho/1/ho/1/cmd_dien";
const char* topicCmdNuoc = "khuPho/1/ho/1/cmd_nuoc";
const char* topicWarnDien = "khuPho/1/ho/1/canhbao_dien";
const char* topicWarnNuoc = "khuPho/1/ho/1/canhbao_nuoc";
const char* topicSetLimitDien = "khuPho/1/ho/1/set_limit_dien";
const char* topicSetLimitNuoc = "khuPho/1/ho/1/set_limit_nuoc";

// ===== Trạng thái thiết bị =====
bool enableDien = false;
bool enableNuoc = false;
bool blinkDien = false;
bool blinkNuoc = false;

// ===== Ngưỡng giới hạn (có thể thay đổi từ Flutter) =====
float limitDien = 120.0;
float limitNuoc = 15.0;

// ===== Kết nối WiFi =====
void setup_wifi() {
  Serial.println();
  Serial.print("Đang kết nối WiFi: ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\n✅ WiFi đã kết nối!");
  Serial.print("IP: ");
  Serial.println(WiFi.localIP());
}

// ===== Callback MQTT =====
void callback(char* topic, byte* payload, unsigned int length) {
  String msg;
  for (unsigned int i = 0; i < length; i++) msg += (char)payload[i];

  Serial.print("Nhận từ topic: ");
  Serial.print(topic);
  Serial.print(" => ");
  Serial.println(msg);

  bool needPublish = false;  // Cờ đánh dấu có cần gửi dữ liệu ngay không


  // ===== Điều khiển bật/tắt điện =====
  if (String(topic) == topicCmdDien) {
    enableDien = (msg == "1");
    digitalWrite(ledDien, enableDien ? HIGH : LOW);
    Serial.println(enableDien ? "🔌 BẬT điện" : "🔌 TẮT điện");
  }

  // ===== Điều khiển bật/tắt nước =====
  else if (String(topic) == topicCmdNuoc) {
    enableNuoc = (msg == "1");
    digitalWrite(ledNuoc, enableNuoc ? HIGH : LOW);
    Serial.println(enableNuoc ? "💧 BẬT nước" : "💧 TẮT nước");
  }

  // ===== Cập nhật ngưỡng điện =====
  else if (String(topic) == topicSetLimitDien) {
    limitDien = msg.toFloat();
    Serial.print("⚙️ Ngưỡng điện mới: ");
    Serial.println(limitDien);
  }

  // ===== Cập nhật ngưỡng nước =====
  else if (String(topic) == topicSetLimitNuoc) {
    limitNuoc = msg.toFloat();
    Serial.print("⚙️ Ngưỡng nước mới: ");
    Serial.println(limitNuoc);
  }

  // ===== Nếu có thay đổi trạng thái thiết bị => gửi dữ liệu ngay =====
  if (needPublish) {
    publishSensorData();  // Gửi ngay dữ liệu và cảnh báo tương ứng
  }
}

// ===== Kết nối lại MQTT nếu mất =====
void reconnect() {
  while (!client.connected()) {
    Serial.print("Đang kết nối MQTT...");
    String clientId = "ESP32Client-" + String(random(0xffff), HEX);
    if (client.connect(clientId.c_str())) {
      Serial.println("✅ Kết nối MQTT thành công");

      // Đăng ký các topic nhận lệnh
      client.subscribe(topicCmdDien);
      client.subscribe(topicCmdNuoc);
      client.subscribe(topicSetLimitDien);
      client.subscribe(topicSetLimitNuoc);
    } else {
      Serial.print("Lỗi, rc=");
      Serial.print(client.state());
      Serial.println(" thử lại sau 5s");
      delay(5000);
    }
  }
}

// ===== Gửi dữ liệu cảm biến =====
void publishSensorData() {
  // Giả lập điện
  if (enableDien) {
    float dien = random(50, 150);
    char msgDien[10];
    dtostrf(dien, 4, 2, msgDien);
    client.publish(topicDien, msgDien);
    Serial.print("🔹 Gửi điện: ");
    Serial.println(msgDien);

    blinkDien = (dien > limitDien);
    client.publish(topicWarnDien, blinkDien ? "1" : "0");
  } else {
    // Nếu tắt điện => gửi giá trị 0
    client.publish(topicDien, "0");
    client.publish(topicWarnDien, "0");
    blinkDien = false;
    Serial.println("🔹 Điện tắt -> Gửi 0");
  }

  // Giả lập nước
  if (enableNuoc) {
    float nuoc = random(5, 20);
    char msgNuoc[10];
    dtostrf(nuoc, 4, 2, msgNuoc);
    client.publish(topicNuoc, msgNuoc);
    Serial.print("🔹 Gửi nước: ");
    Serial.println(msgNuoc);

    blinkNuoc = (nuoc > limitNuoc);
    client.publish(topicWarnNuoc, blinkNuoc ? "1" : "0");
  }  else {
    // Nếu tắt nước => gửi giá trị 0
    client.publish(topicNuoc, "0");
    client.publish(topicWarnNuoc, "0");
    blinkNuoc = false;
    Serial.println("🔹 Nước tắt -> Gửi 0");
  }
}

// ===== LED nhấp nháy khi vượt ngưỡng =====
void handleBlink() {
  static unsigned long lastBlink = 0;
  static bool stateDien = HIGH;
  static bool stateNuoc = HIGH;

  unsigned long now = millis();
  if (now - lastBlink > 500) {
    lastBlink = now;

    // LED điện
    if (enableDien) {
      if (blinkDien) {
        stateDien = !stateDien;
        digitalWrite(ledDien, stateDien);
      } else {
        digitalWrite(ledDien, HIGH);
      }
    } else {
      digitalWrite(ledDien, LOW);
    }

    // LED nước
    if (enableNuoc) {
      if (blinkNuoc) {
        stateNuoc = !stateNuoc;
        digitalWrite(ledNuoc, stateNuoc);
      } else {
        digitalWrite(ledNuoc, HIGH);
      }
    } else {
      digitalWrite(ledNuoc, LOW);
    }
  }
}

// ===== Setup =====
void setup() {
  pinMode(ledDien, OUTPUT);
  pinMode(ledNuoc, OUTPUT);

  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);
}

// ===== Loop =====
void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  // Gửi dữ liệu mỗi 5 giây
  static unsigned long lastMsg = 0;
  unsigned long now = millis();
  if (now - lastMsg > 5000) {
    lastMsg = now;
    publishSensorData();
  }

  // Xử lý LED nhấp nháy
  handleBlink();
}

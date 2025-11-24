// file mqtt_service.dart
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final client = MqttServerClient('broker.hivemq.com', '');

// Data shared
String dien = '0.0', nuoc = '0.0';
bool warnDien = false, warnNuoc = false;
bool enableDien = false, enableNuoc = false;
double limitDien = 120.0, limitNuoc = 15.0;

// Topics MQTT (giống ESP32)
const String topicDien = 'khuPho/1/ho/1/dien';
const String topicNuoc = 'khuPho/1/ho/1/nuoc';
const String topicCmdDien = 'khuPho/1/ho/1/cmd_dien';
const String topicCmdNuoc = 'khuPho/1/ho/1/cmd_nuoc';
const String topicWarnDien = 'khuPho/1/ho/1/canhbao_dien';
const String topicWarnNuoc = 'khuPho/1/ho/1/canhbao_nuoc';
const String topicSetLimitDien = 'khuPho/1/ho/1/set_limit_dien';
const String topicSetLimitNuoc = 'khuPho/1/ho/1/set_limit_nuoc';

// Hàm publish điều khiển bật/tắt điện
void publishDienControl(bool state) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(state ? '1' : '0');
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.publishMessage(topicCmdDien, MqttQos.atLeastOnce, builder.payload!);
    print('Published: Điều khiển điện = ${state ? "BẬT" : "TẮT"}');
  }
}

// Hàm publish điều khiển bật/tắt nước
void publishNuocControl(bool state) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(state ? '1' : '0');
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.publishMessage(topicCmdNuoc, MqttQos.atLeastOnce, builder.payload!);
    print('Published: Điều khiển nước = ${state ? "BẬT" : "TẮT"}');
  }
}

// Hàm publish ngưỡng điện
void publishLimitDien(double limit) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(limit.toString());
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.publishMessage(topicSetLimitDien, MqttQos.atLeastOnce, builder.payload!);
    print('Published: Ngưỡng điện = $limit');
  }
}

// Hàm publish ngưỡng nước
void publishLimitNuoc(double limit) {
  final builder = MqttClientPayloadBuilder();
  builder.addString(limit.toString());
  if (client.connectionStatus!.state == MqttConnectionState.connected) {
    client.publishMessage(topicSetLimitNuoc, MqttQos.atLeastOnce, builder.payload!);
    print('Published: Ngưỡng nước = $limit');
  }
}

// Hàm setup MQTT
Future<int> setupMqttClient(Function(String, String, bool, bool, bool, bool, bool) callback) async {
  client.logging(on: false);
  client.setProtocolV311();
  client.keepAlivePeriod = 20;
  client.connectTimeoutPeriod = 2000;
  client.onDisconnected = () => callback(dien, nuoc, false, warnDien, warnNuoc, enableDien, enableNuoc);
  client.onConnected = () => callback(dien, nuoc, true, warnDien, warnNuoc, enableDien, enableNuoc);

  final connMess = MqttConnectMessage()
      .withClientIdentifier('Flutter_Client_${DateTime.now().millisecondsSinceEpoch}')
      .withWillTopic('willtopic')
      .withWillMessage('Connection lost')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;

  try {
    await client.connect();
  } on NoConnectionException catch (e) {
    print('ERROR: $e');
    client.disconnect();
  } on SocketException catch (e) {
    print('Socket ERROR: $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state != MqttConnectionState.connected) {
    print('ERROR: MQTT connection failed');
    client.disconnect();
    return -1;
  }

  // Subscribe các topic cần nhận
  client.subscribe(topicDien, MqttQos.atMostOnce);
  client.subscribe(topicNuoc, MqttQos.atMostOnce);
  client.subscribe(topicWarnDien, MqttQos.atMostOnce);
  client.subscribe(topicWarnNuoc, MqttQos.atMostOnce);

  client.updates!.listen((c) {
    final recMess = c[0].payload as MqttPublishMessage;
    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    final topic = c[0].topic;

    if (topic == topicDien) dien = pt;
    if (topic == topicNuoc) nuoc = pt;
    if (topic == topicWarnDien) warnDien = (pt == '1');
    if (topic == topicWarnNuoc) warnNuoc = (pt == '1');

    callback(dien, nuoc, true, warnDien, warnNuoc, enableDien, enableNuoc);
    print('MQTT: Topic <$topic> = $pt');
  });

  return 0;
}
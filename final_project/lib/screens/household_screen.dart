// file household_detail_screen.dart
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../process/dien_card.dart';
import '../process/nuoc_card.dart';
import '../process/sensor_card.dart';

class HouseholdDetailScreen extends StatefulWidget {
  final int khuPhoId;
  final int householdNumber;

  const HouseholdDetailScreen({
    super.key,
    required this.khuPhoId,
    required this.householdNumber,
  });

  @override
  State<HouseholdDetailScreen> createState() => _HouseholdDetailScreenState();
}

class _HouseholdDetailScreenState extends State<HouseholdDetailScreen> {
  bool connected = false;
  String dienValue = '0.0';
  String nuocValue = '0.0';
  bool warnDien = false;
  bool warnNuoc = false;

  @override
  void initState() {
    super.initState();
    _connectMQTT();
  }

  void _connectMQTT() async {
    try {
      await setupMqttClient((dien, nuoc, isConnected, wDien, wNuoc, eDien, eNuoc) {
        setState(() {
          connected = isConnected;
          dienValue = dien;
          nuocValue = nuoc;
          warnDien = wDien;
          warnNuoc = wNuoc;
          enableDien = eDien;
          enableNuoc = eNuoc;
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hộ Gia Đình ${widget.householdNumber}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 149, 187, 203),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status bar MQTT
            Container(
              color: connected ? Colors.green.shade700 : Colors.red.shade700,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    connected ? Icons.cloud_done : Icons.cloud_off,
                    color: Colors.white,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    connected ? 'Kết nối MQTT' : 'Mất kết nối MQTT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            
            // Thông tin hộ gia đình
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              padding: EdgeInsets.all(screenWidth * 0.035),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    color: Colors.white,
                    size: screenWidth * 0.08,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông Tin Hộ Gia Đình',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.042,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.003),
                        Text(
                          'Khu Phố ${widget.khuPhoId} - Hộ ${widget.householdNumber}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.033,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            
            // Cảm biến - sử dụng Wrap thay vì Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: screenHeight * 0.012,
                alignment: WrapAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.44,
                      minWidth: screenWidth * 0.42,
                    ),
                    child: SensorCard(
                      colors: [Colors.orange.shade400, Colors.orange.shade700],
                      name: 'Điện (kWh)',
                      value: double.parse(dienValue).toStringAsFixed(2),
                      warning: warnDien,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.44,
                      minWidth: screenWidth * 0.42,
                    ),
                    child: SensorCard(
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                      name: 'Nước (m³)',
                      value: double.parse(nuocValue).toStringAsFixed(2),
                      warning: warnNuoc,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.012),
            
            // Điều khiển - sử dụng Wrap
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: Wrap(
                spacing: screenWidth * 0.02,
                runSpacing: screenHeight * 0.012,
                alignment: WrapAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.44,
                      minWidth: screenWidth * 0.42,
                    ),
                    child: DienCard(
                      dienState: enableDien,
                      connected: connected,
                      onChanged: (value) {
                        setState(() => enableDien = value);
                      },
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.44,
                      minWidth: screenWidth * 0.42,
                    ),
                    child: NuocCard(
                      nuocState: enableNuoc,
                      connected: connected,
                      onChanged: (value) {
                        setState(() => enableNuoc = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Thông tin thêm
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    'Ngưỡng Điện:',
                    '${limitDien.toStringAsFixed(1)} kWh',
                    Icons.electric_bolt,
                    Colors.orange,
                  ),
                  SizedBox(height: screenHeight * 0.012),
                  _buildInfoRow(
                    context,
                    'Ngưỡng Nước:',
                    '${limitNuoc.toStringAsFixed(1)} m³',
                    Icons.water_drop,
                    Colors.blue,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.018),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: screenWidth * 0.055),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.042,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
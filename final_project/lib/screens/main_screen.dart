// file khu_pho_screen.dart
import 'package:flutter/material.dart';
import 'household_screen.dart';
import 'settings_screen.dart';
import '../services/mqtt_service.dart';

class KhuPhoScreen extends StatefulWidget {
  const KhuPhoScreen({super.key});

  @override
  State<KhuPhoScreen> createState() => _KhuPhoScreenState();
}

class _KhuPhoScreenState extends State<KhuPhoScreen> {
  bool connected = false;
  String dienValue = '0.0';
  String nuocValue = '0.0';
  bool warnDien = false;
  bool warnNuoc = false;

  // Khu phố được chọn
  int selectedKhuPho = 1;
  
  // Danh sách khu phố
  final List<Map<String, dynamic>> khuPhoList = [
    {'id': 1, 'name': 'Khu Phố 1', 'households': 6},
    {'id': 2, 'name': 'Khu Phố 2', 'households': 8},
    {'id': 3, 'name': 'Khu Phố 3', 'households': 5},
    {'id': 4, 'name': 'Khu Phố 4', 'households': 7},
  ];

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
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  int _getHouseholdCount() {
    return khuPhoList.firstWhere((kp) => kp['id'] == selectedKhuPho)['households'];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản Lý Điện Nước',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 149, 187, 203),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: screenWidth * 0.06),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
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
          
          // Dropdown chọn khu phố
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.012,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade800],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn Khu Phố',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenHeight * 0.008),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedKhuPho,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, size: screenWidth * 0.07),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      items: khuPhoList.map((khuPho) {
                        return DropdownMenuItem<int>(
                          value: khuPho['id'],
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(screenWidth * 0.015),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.location_city,
                                  color: Colors.blue.shade700,
                                  size: screenWidth * 0.05,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.025),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      khuPho['name'],
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${khuPho['households']} hộ gia đình',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedKhuPho = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blueGrey.shade800,
                    Colors.blueGrey.shade600,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    
                    // Header với thông tin khu phố
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.home_work,
                            color: Colors.white,
                            size: screenWidth * 0.07,
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  khuPhoList.firstWhere(
                                    (kp) => kp['id'] == selectedKhuPho
                                  )['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.048,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.003),
                                Text(
                                  'Tổng số: ${_getHouseholdCount()} hộ gia đình',
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
                    
                    Text(
                      'Danh Sách Hộ Gia Đình',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.012),
                    
                    // Grid các hộ gia đình
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.95,
                        crossAxisSpacing: screenWidth * 0.03,
                        mainAxisSpacing: screenHeight * 0.015,
                      ),
                      itemCount: _getHouseholdCount(),
                      itemBuilder: (context, index) {
                        bool isActiveHousehold = (selectedKhuPho == 1 && index == 0);
                        
                        return HouseholdCard(
                          khuPhoId: selectedKhuPho,
                          householdNumber: index + 1,
                          dienValue: isActiveHousehold ? dienValue : '0.0',
                          nuocValue: isActiveHousehold ? nuocValue : '0.0',
                          warnDien: isActiveHousehold && warnDien,
                          warnNuoc: isActiveHousehold && warnNuoc,
                          connected: connected,
                          isActive: isActiveHousehold,
                          onTap: () {
                            if (isActiveHousehold) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HouseholdDetailScreen(
                                    khuPhoId: selectedKhuPho,
                                    householdNumber: index + 1,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Hộ ${index + 1} - Khu phố $selectedKhuPho chưa được kích hoạt'
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: Colors.orange.shade700,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HouseholdCard extends StatelessWidget {
  final int khuPhoId;
  final int householdNumber;
  final String dienValue;
  final String nuocValue;
  final bool warnDien;
  final bool warnNuoc;
  final bool connected;
  final bool isActive;
  final VoidCallback onTap;

  const HouseholdCard({
    super.key,
    required this.khuPhoId,
    required this.householdNumber,
    required this.dienValue,
    required this.nuocValue,
    required this.warnDien,
    required this.warnNuoc,
    required this.connected,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [Colors.blue.shade400, Colors.blue.shade700]
                : [Colors.grey.shade600, Colors.grey.shade800],
          ),
          borderRadius: BorderRadius.circular(12),
          border: (warnDien || warnNuoc)
              ? Border.all(color: Colors.yellow, width: 2.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (warnDien || warnNuoc)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.008),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning,
                    color: Colors.yellow,
                    size: screenWidth * 0.035,
                  ),
                ),
              ),
            
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.white,
                        size: screenWidth * 0.06,
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Expanded(
                        child: Text(
                          'Hộ $householdNumber',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.electric_bolt,
                            color: warnDien ? Colors.yellow : Colors.white70,
                            size: screenWidth * 0.035,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Expanded(
                            child: Text(
                              '${double.parse(dienValue).toStringAsFixed(1)} kWh',
                              style: TextStyle(
                                color: warnDien ? Colors.yellow : Colors.white70,
                                fontSize: screenWidth * 0.032,
                                fontWeight: warnDien ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.008),
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            color: warnNuoc ? Colors.yellow : Colors.white70,
                            size: screenWidth * 0.035,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Expanded(
                            child: Text(
                              '${double.parse(nuocValue).toStringAsFixed(1)} m³',
                              style: TextStyle(
                                color: warnNuoc ? Colors.yellow : Colors.white70,
                                fontSize: screenWidth * 0.032,
                                fontWeight: warnNuoc ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.015,
                          vertical: screenWidth * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'Hoạt động' : 'Chưa kích hoạt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.025,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
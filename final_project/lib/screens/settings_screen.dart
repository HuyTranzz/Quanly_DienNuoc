// file settings_screen.dart
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _limitDienCtrl = TextEditingController();
  final TextEditingController _limitNuocCtrl = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _limitDienCtrl.text = limitDien.toStringAsFixed(1);
    _limitNuocCtrl.text = limitNuoc.toStringAsFixed(1);
  }

  void _updateLimitDien() {
    try {
      double newLimit = double.parse(_limitDienCtrl.text);
      if (newLimit <= 0) {
        _showErrorDialog('Giá trị ngưỡng điện phải lớn hơn 0');
        return;
      }
      setState(() {
        limitDien = newLimit;
      });
      publishLimitDien(newLimit);
      _showSuccessDialog('Đã cập nhật ngưỡng điện thành công');
    } catch (e) {
      _showErrorDialog('Vui lòng nhập số hợp lệ');
    }
  }

  void _updateLimitNuoc() {
    try {
      double newLimit = double.parse(_limitNuocCtrl.text);
      if (newLimit <= 0) {
        _showErrorDialog('Giá trị ngưỡng nước phải lớn hơn 0');
        return;
      }
      setState(() {
        limitNuoc = newLimit;
      });
      publishLimitNuoc(newLimit);
      _showSuccessDialog('Đã cập nhật ngưỡng nước thành công');
    } catch (e) {
      _showErrorDialog('Vui lòng nhập số hợp lệ');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài Đặt Ngưỡng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 149, 187, 203),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.015),
              
              // Thông tin hướng dẫn
              Container(
                padding: EdgeInsets.all(screenWidth * 0.035),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: screenWidth * 0.065,
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Text(
                        'Cài đặt ngưỡng cảnh báo cho điện và nước. Khi vượt ngưỡng, hệ thống sẽ gửi cảnh báo.',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: screenWidth * 0.033,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.025),
              
              // Cài đặt ngưỡng điện
              _buildSettingSection(
                context,
                icon: Icons.electric_bolt,
                iconColor: Colors.orange,
                title: 'Ngưỡng Điện',
                subtitle: 'Cảnh báo khi vượt quá ngưỡng tiêu thụ điện',
                controller: _limitDienCtrl,
                unit: 'kWh',
                currentValue: limitDien,
                onUpdate: _updateLimitDien,
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              // Cài đặt ngưỡng nước
              _buildSettingSection(
                context,
                icon: Icons.water_drop,
                iconColor: Colors.blue,
                title: 'Ngưỡng Nước',
                subtitle: 'Cảnh báo khi vượt quá ngưỡng tiêu thụ nước',
                controller: _limitNuocCtrl,
                unit: 'm³',
                currentValue: limitNuoc,
                onUpdate: _updateLimitNuoc,
              ),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Thông tin hiện tại
              Text(
                'Ngưỡng Hiện Tại',
                style: TextStyle(
                  fontSize: screenWidth * 0.048,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              
              Row(
                children: [
                  Expanded(
                    child: _buildCurrentValueCard(
                      context,
                      icon: Icons.electric_bolt,
                      iconColor: Colors.orange,
                      label: 'Điện',
                      value: limitDien.toStringAsFixed(1),
                      unit: 'kWh',
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildCurrentValueCard(
                      context,
                      icon: Icons.water_drop,
                      iconColor: Colors.blue,
                      label: 'Nước',
                      value: limitNuoc.toStringAsFixed(1),
                      unit: 'm³',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String unit,
    required double currentValue,
    required VoidCallback onUpdate,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.025),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: screenWidth * 0.06),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.042,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.003),
                    Text(
                      subtitle,
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
          SizedBox(height: screenHeight * 0.015),
          
          Column(
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Giá trị ngưỡng',
                  labelStyle: TextStyle(fontSize: screenWidth * 0.035),
                  suffixText: unit,
                  suffixStyle: TextStyle(fontSize: screenWidth * 0.035),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.035,
                    vertical: screenHeight * 0.015,
                  ),
                ),
                style: TextStyle(fontSize: screenWidth * 0.038),
              ),
              SizedBox(height: screenHeight * 0.012),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cập nhật',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentValueCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [iconColor.withOpacity(0.8), iconColor],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: screenWidth * 0.07),
          SizedBox(height: screenHeight * 0.008),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: screenWidth * 0.033,
            ),
          ),
          SizedBox(height: screenHeight * 0.003),
          Text(
            '$value $unit',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _limitDienCtrl.dispose();
    _limitNuocCtrl.dispose();
    super.dispose();
  }
}
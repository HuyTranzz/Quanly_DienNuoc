import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class NuocCard extends StatelessWidget {
  final bool nuocState;
  final bool connected;
  final ValueChanged<bool> onChanged;

  const NuocCard({
    super.key,
    required this.nuocState,
    required this.connected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final screenWidth = MediaQuery.of(context).size.width;

    // Tự động co giãn theo màn hình (tối đa 90% chiều rộng)
    final cardWidth = screenWidth * 0.9;

    return Center(
      child: Container(
        width: cardWidth.clamp(180, 350), // Giới hạn min/max để không bị quá to hoặc nhỏ
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: nuocState
                ? [Colors.blue, Colors.cyan, Colors.lightBlueAccent]
                : [Colors.grey.shade700, Colors.grey.shade800, Colors.grey.shade900],
            stops: const [0.3, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              nuocState ? Icons.water_drop : Icons.water_drop_outlined,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 6),
            const Text(
              "Điều Khiển Nước",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Switch(
              value: nuocState,
              onChanged: connected
                  ? (value) {
                      onChanged(value);
                      publishNuocControl(value);
                    }
                  : null,
              activeColor: Colors.white,
              activeTrackColor: Colors.cyanAccent,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade600,
            ),
            Text(
              nuocState ? "BẬT" : "TẮT",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class DienCard extends StatelessWidget {
  final bool dienState;
  final bool connected;
  final ValueChanged<bool> onChanged;

  const DienCard({
    super.key,
    required this.dienState,
    required this.connected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để tự động điều chỉnh
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.42, // Chiếm ~42% màn hình
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dienState
              ? [Colors.amber, Colors.orange, Colors.deepOrange]
              : [Colors.grey.shade700, Colors.grey.shade800, Colors.grey.shade900],
          stops: const [0.3, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            dienState ? Icons.power : Icons.power_off,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(height: 8),
          const Text(
            "Điều Khiển Điện",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Switch(
              value: dienState,
              onChanged: connected
                  ? (value) {
                      onChanged(value);
                      publishDienControl(value);
                    }
                  : null,
              activeColor: Colors.white,
              activeTrackColor: Colors.yellow,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dienState ? "BẬT" : "TẮT",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

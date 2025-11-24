import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  final List<Color> colors;
  final List<double>? stops;
  final String name;
  final String value;
  final bool warning;

  const SensorCard({
    super.key,
    required this.colors,
    this.stops,
    required this.name,
    required this.value,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Card tự co giãn theo màn hình, giới hạn kích thước hợp lý
    final cardSize = screenWidth * 0.4; // mỗi card chiếm 40% chiều rộng màn hình
    final cardWidth = cardSize.clamp(160, 280).toDouble();
    final cardHeight = cardWidth; // giữ tỉ lệ vuông

    return Center(
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: warning ? [Colors.red.shade700, Colors.orange.shade700] : colors,
            stops: stops,
          ),
          borderRadius: BorderRadius.circular(16),
          border: warning ? Border.all(color: Colors.yellowAccent, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (warning)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "⚠️ CẢNH BÁO",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

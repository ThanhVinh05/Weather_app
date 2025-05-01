import 'package:flutter/material.dart';
import '../../domain/models/weather_response.dart';
import 'weather_detail_row.dart';

class WeatherDisplayWidget extends StatelessWidget {
  final WeatherResponse weather;

  const WeatherDisplayWidget({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherCondition = weather.weather.isNotEmpty ? weather.weather.first : null;
    final iconUrl = weatherCondition != null
        ? 'http://openweathermap.org/img/wn/${weatherCondition.icon}@4x.png'
        : null;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tên thành phố
          Text(
            weather.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Icon thời tiết
          if (iconUrl != null)
            Image.network(iconUrl, width: 120, height: 120),

          // Mô tả thời tiết
          if (weatherCondition != null)
            Text(
              weatherCondition.description,
              style: const TextStyle(fontSize: 22, fontStyle: FontStyle.normal, color: Colors.grey),
            ),

          const SizedBox(height: 30),

          // Nhiệt độ
          Text(
            '${weather.main.temp.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blue),
          ),

          const SizedBox(height: 40),

          // Card chi tiết (sử dụng Widget WeatherDetailRow)
          Card(
            margin: EdgeInsets.symmetric(horizontal: 20),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WeatherDetailRow(label: 'Độ ẩm:', value: '${weather.main.humidity}%'),
                  const Divider(height: 25, thickness: 1),
                  WeatherDetailRow(label: 'Tốc độ gió:', value: '${weather.wind.speed.toStringAsFixed(1)} m/s'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
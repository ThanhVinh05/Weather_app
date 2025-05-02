import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/domain/models/forecast_item.dart';

class ForecastItemWidget extends StatelessWidget {
  final ForecastItem item;

  const ForecastItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse chuỗi thời gian 'yyyy-MM-dd HH:mm:ss'
    final dateTime = DateTime.parse(item.dtTxt);
    final formattedDate = DateFormat('EEE, h a').format(dateTime);

    final iconUrl = item.weather.isNotEmpty
        ? 'http://openweathermap.org/img/wn/${item.weather.first.icon}@2x.png'
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (iconUrl != null)
            Image.network(iconUrl, width: 40, height: 40),
          const SizedBox(height: 8),
          Text(
            '${item.main.temp.toStringAsFixed(0)}°C',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/core/constants/api_constants.dart';
import 'package:weather_app/domain/models/forecast_model.dart';

class ForecastItemWidget extends StatelessWidget {
  final ForecastModel item;

  const ForecastItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse chuỗi thời gian 'yyyy-MM-dd HH:mm:ss'
    final dateTime = DateTime.parse(item.dtTxt);
    // Định dạng chỉ hiển thị giờ và AM/PM
    final formattedTime = DateFormat('h a').format(dateTime);

    final iconUrl = item.weather.isNotEmpty
        ? '${ApiConstants.WEATHERICON}/${item.weather.first.icon}@2x.png'
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formattedTime,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          if (iconUrl != null)
            Image.network(iconUrl, width: 35, height: 35),
          const SizedBox(height: 6),
          Text(
            '${item.main.temp.toStringAsFixed(0)}°C',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
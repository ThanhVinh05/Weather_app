import 'package:flutter/material.dart';
import 'package:weather_app/domain/models/forecast_item.dart';
import '../../domain/models/weather_response.dart';
import 'weather_detail_row.dart';
import 'forecast_item_widget.dart';

class WeatherDisplayWidget extends StatelessWidget {
  final WeatherResponse weather;
  final List<ForecastItem>? forecast;

  const WeatherDisplayWidget({
    Key? key,
    required this.weather,
    this.forecast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherCondition = weather.weather.isNotEmpty ? weather.weather.first : null;
    final iconUrl = weatherCondition != null
        ? 'http://openweathermap.org/img/wn/${weatherCondition.icon}@4x.png'
        : null;

    // Lọc dự báo để chỉ hiển thị dự báo cho các ngày khác nhau
    // API 5 ngày / 3 giờ trả về 40 mục.
    // Lấy các mục cách nhau 8 index (tương đương ~24 giờ)
    final List<ForecastItem> dailyForecasts = [];
    if (forecast != null) {
      for (int i = 0; i < forecast!.length && dailyForecasts.length < 5; i += 8) { // Lấy tối đa 5 ngày
        dailyForecasts.add(forecast![i]);
      }
    }


    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            weather.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Icon thời tiết hiện tại
          if (iconUrl != null)
            Image.network(iconUrl, width: 120, height: 120),

          // Mô tả thời tiết hiện tại
          if (weatherCondition != null)
            Text(
              weatherCondition.description,
              style: const TextStyle(fontSize: 20, fontStyle: FontStyle.normal, color: Colors.grey),
            ),

          const SizedBox(height: 10),

          // Nhiệt độ hiện tại
          Text(
            '${weather.main.temp.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.blue),
          ),

          const SizedBox(height: 20),

          // Card chi tiết (Độ ẩm, Tốc độ gió)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 20),
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

          if (dailyForecasts.isNotEmpty) // Chỉ hiển thị nếu có dữ liệu dự báo
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 10.0, left: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dự báo 5 ngày tới:',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (dailyForecasts.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Cuộn theo chiều ngang
                itemCount: dailyForecasts.length,
                itemBuilder: (context, index) {
                  final item = dailyForecasts[index];
                  return ForecastItemWidget(item: item);
                },
              ),
            ),
          const SizedBox(height: 20),

        ],
      ),
    );
  }
}
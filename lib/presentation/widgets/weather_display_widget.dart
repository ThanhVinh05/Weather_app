import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/core/constants/api_constants.dart';
import 'package:weather_app/domain/models/forecast_model.dart';
import '../../domain/models/weather_response.dart';
import 'forecast_item_widget.dart';

class WeatherDisplayWidget extends StatelessWidget {
  final WeatherResponse weather;
  final List<ForecastModel>? forecast;

  const WeatherDisplayWidget({
    Key? key,
    required this.weather,
    this.forecast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weatherCondition = weather.weather.isNotEmpty ? weather.weather.first : null;
    final iconUrl = weatherCondition != null
        ? '${ApiConstants.WEATHERICON}/${weatherCondition.icon}@4x.png'
        : null;

    // Nhóm các mục dự báo theo ngày (yyyy-MM-dd)
    final Map<String, List<ForecastModel>> groupedForecasts = {};
    if (forecast != null) {
      for (var item in forecast!) {
        String date = item.dtTxt.split(' ')[0]; // Lấy phần ngày 'yyyy-MM-dd' từ 'yyyy-MM-dd HH:mm:ss'
        groupedForecasts.putIfAbsent(date, () => []).add(item);
      }
    }

    // Lấy danh sách các ngày và sắp xếp
    final List<String> sortedDates = groupedForecasts.keys.toList()..sort();

    final DateTime now = DateTime.now();
    final String todayString = DateFormat('yyyy-MM-dd').format(now);
    final String tomorrowString = DateFormat('yyyy-MM-dd').format(now.add(const Duration(days: 1)));



    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Text(
                  weather.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                if (iconUrl != null)
                  Image.network(iconUrl, width: 120, height: 120),

                if (weatherCondition != null)
                  Text(
                    weatherCondition.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontStyle: FontStyle.normal, color: Colors.grey),
                  ),

                const SizedBox(height: 10),

                Text(
                  '${weather.main.temp.toStringAsFixed(1)}°C',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Hiển thị Độ ẩm
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, size: 24.0, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.main.humidity}%',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
                // Hiển thị Tốc độ gió
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.air, size: 24.0, color: Colors.lightBlue),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.wind.speed.toStringAsFixed(1)} m/s',
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          if (sortedDates.isNotEmpty) // Chỉ hiển thị phần dự báo nếu có dữ liệu
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 16.0, right: 16.0),
              child: Text(
                'Dự báo chi tiết:',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

          if (sortedDates.isNotEmpty)
            ...sortedDates.map((dateString) {
              List<ForecastModel> dailyForecasts = groupedForecasts[dateString]!;

              // Lọc các mục dự báo cho ngày hôm nay (loại bỏ các giờ đã qua)
              if (dateString == todayString) {
                dailyForecasts = dailyForecasts.where((item) {
                  DateTime forecastTime = DateTime.parse(item.dtTxt);
                  return forecastTime.isAfter(now) || forecastTime.isAtSameMomentAs(now);
                }).toList();
              } else {
              }

              if (dailyForecasts.isNotEmpty) {
                // Xác định tiêu đề cho ngày
                String dayHeaderText;
                if (dateString == todayString) {
                  dayHeaderText = 'Hôm nay';
                } else if (dateString == tomorrowString) {
                  dayHeaderText = 'Ngày mai';
                } else {
                  DateTime date = DateTime.parse(dateString);
                  dayHeaderText = DateFormat('EEEE, dd/MM', 'vi').format(date);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (sortedDates.first != dateString)
                      const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        dayHeaderText,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: dailyForecasts.length,
                        itemBuilder: (context, index) {
                          final item = dailyForecasts[index];
                          return ForecastItemWidget(item: item);
                        },
                      ),
                    ),
                    // Thêm đường phân cách giữa các ngày, trừ ngày cuối cùng
                    if (dateString != sortedDates.last)
                      const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            }).toList(),
          const SizedBox(height: 20),

        ],
      ),
    );
  }
}
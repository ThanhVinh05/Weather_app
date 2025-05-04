import 'weather_model.dart';
import 'weather_condition.dart';
import 'wind_model.dart';

class WeatherResponse {
  final String name; // Tên thành phố
  final WeatherModel main; // Dữ liệu chính (nhiệt độ, độ ẩm...)
  final List<WeatherCondition> weather; // Mô tả thời tiết (icon, description)
  final WindModel wind; // Dữ liệu gió
  final int id; // id thành phố
  final int cod; // mã trạng thái http từ api

  WeatherResponse({
    required this.name,
    required this.main,
    required this.weather,
    required this.wind,
    required this.id,
    required this.cod,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      name: json['name'] as String,
      main: WeatherModel.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List)
          .map((item) => WeatherCondition.fromJson(item as Map<String, dynamic>))
          .toList(),
      wind: WindModel.fromJson(json['wind'] as Map<String, dynamic>),
      id: json['id'] as int,
      cod: json['cod'] as int,
    );
  }
}
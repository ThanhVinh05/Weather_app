import 'package:equatable/equatable.dart';
import 'package:weather_app/domain/models/weather_model.dart';
import 'package:weather_app/domain/models/weather_condition.dart';
import 'package:weather_app/domain/models/wind_model.dart';

// Model cho một mục  dự báo cho 3 giờ tới
class ForecastModel extends Equatable {
  final int dt; // Thời gian của dự báo (Unix timestamp)
  final WeatherModel main; // Dữ liệu chính (nhiệt độ, độ ẩm)
  final List<WeatherCondition> weather; // Mô tả điều kiện thời tiết
  final WindModel wind; // Dữ liệu gió
  final String dtTxt; // Thời gian dự báo dưới dạng chuỗi

  const ForecastModel({
    required this.dt,
    required this.main,
    required this.weather,
    required this.wind,
    required this.dtTxt,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      dt: json['dt'] as int,
      main: WeatherModel.fromJson(json['main'] as Map<String, dynamic>),
      weather: (json['weather'] as List)
          .map((item) => WeatherCondition.fromJson(item as Map<String, dynamic>))
          .toList(),
      wind: WindModel.fromJson(json['wind'] as Map<String, dynamic>),
      dtTxt: json['dt_txt'] as String,
    );
  }

  @override
  List<Object> get props => [dt, main, weather, wind, dtTxt];
}
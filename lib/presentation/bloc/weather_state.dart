import 'package:equatable/equatable.dart';
import 'package:weather_app/domain/models/forecast_item.dart';
import '../../domain/models/weather_response.dart';

enum WeatherStatus { initial, loading, success, failure, }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherResponse? weather;
  final List<ForecastItem>? forecast;
  final String? errorMessage;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.forecast,
    this.errorMessage,
  });

  // Phương thức copyWith để tạo trạng thái mới dựa trên trạng thái hiện tại
  @override
  WeatherState copyWith({
    WeatherStatus? status,
    WeatherResponse? weather,
    List<ForecastItem>? forecast,
    String? errorMessage,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, weather, forecast, errorMessage];
}
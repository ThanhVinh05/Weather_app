import 'package:equatable/equatable.dart';
import '../../domain/models/weather_response.dart';

enum WeatherStatus { initial, loading, success, failure, }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherResponse? weather;
  final String? errorMessage;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.errorMessage,
  });

  // Phương thức copyWith để tạo trạng thái mới dựa trên trạng thái hiện tại
  WeatherState copyWith({
    WeatherStatus? status,
    WeatherResponse? weather,
    String? errorMessage,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, weather, errorMessage]; // So sánh các trạng thái dựa trên các trường này
}
import 'package:equatable/equatable.dart';
import 'package:weather_app/domain/models/forecast_model.dart';
import '../../domain/models/weather_response.dart';

enum WeatherStatus { initial, loading, success, failure, }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherResponse? weather;
  final List<ForecastModel>? forecast;
  final String? errorMessage;
  final List<String>? citySuggestions;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.forecast,
    this.errorMessage,
    this.citySuggestions,
  });

  @override
  WeatherState copyWith({
    WeatherStatus? status,
    WeatherResponse? weather,
    List<ForecastModel>? forecast,
    String? errorMessage,
    List<String>? citySuggestions,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      errorMessage: errorMessage ?? this.errorMessage,
      citySuggestions: citySuggestions ?? this.citySuggestions,
    );
  }

  @override
  List<Object?> get props => [status, weather, forecast, errorMessage, citySuggestions];
}
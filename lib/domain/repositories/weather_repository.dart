import 'package:weather_app/domain/models/forecast_response.dart';
import '../models/weather_response.dart';

abstract class WeatherRepository {
  Future<WeatherResponse> getCurrentWeather(String city);
  Future<ForecastResponse> getWeatherForecast(String city);
  Future<List<String>> getCitySuggestions(String query);
}
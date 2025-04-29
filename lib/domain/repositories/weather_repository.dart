import '../models/weather_response.dart';

abstract class WeatherRepository {
  Future<WeatherResponse> getCurrentWeather(String city);
}
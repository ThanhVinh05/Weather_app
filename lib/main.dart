import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/my_app.dart';
import 'package:weather_app/services/weather_api_service.dart';

// Import class Env đã được generate
import 'env/env.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lấy API Key từ class Env đã generate
  final apiKey = Env.openWeatherApiKey;

  // Kiểm tra
  if (apiKey.isEmpty) {
    print("FATAL ERROR: OpenWeather API Key is empty!");
    return;
  }
  // Khởi tạo Dio instance
  final dio = Dio();

  // Khởi tạo Service
  final weatherApiService = WeatherApiService(dio);

  // Khởi tạo Repository Implementation, truyền Service và API Key
  final weatherRepository = WeatherRepositoryImpl(weatherApiService, apiKey);

  // Chạy ứng dụng và cung cấp Bloc
  runApp(MyApp(weatherRepository: weatherRepository));
}


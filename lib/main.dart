import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:weather_app/domain/repositories/weather_repository_impl.dart';
import 'package:weather_app/my_app.dart';
import 'package:weather_app/services/weather_api_service.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import này
import 'env/env.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi', null); // Khởi tạo cho tiếng Việt

  // Lấy API Key từ class Env đã generate
  final apiKey = Env.openWeatherApiKey;

  // Kiểm tra
  if (apiKey.isEmpty) {
    print("LỖI NGHIÊM TRỌNG: Khóa API OpenWeather trống!");
    return;
  }
  // Khởi tạo Dio
  final dio = Dio();

  // Khởi tạo Connectivity
  final connectivity = Connectivity();

  // Khởi tạo Service, truyền Dio và Connectivity
  final weatherApiService = WeatherApiService(dio, connectivity);

  // Khởi tạo Repository Implementation, truyền Service và API Key
  final weatherRepository = WeatherRepositoryImpl(weatherApiService, apiKey);

  // Chạy ứng dụng và cung cấp Bloc
  runApp(MyApp(weatherRepository: weatherRepository));
}
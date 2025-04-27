import 'package:flutter/material.dart';
import 'package:weather_app/my_app.dart';

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


  runApp(MyApp());
}


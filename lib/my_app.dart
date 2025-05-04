import 'package:flutter/material.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/presentation/screens/weather_screen.dart';
class MyApp extends StatelessWidget {
  final WeatherRepository weatherRepository;

  const MyApp({Key? key, required this.weatherRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(weatherRepository: weatherRepository),
    );
  }
}
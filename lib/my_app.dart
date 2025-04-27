import 'package:flutter/material.dart';
import 'package:weather_app/presentation/screens/weather_screen.dart';
class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Sử dụng BlocProvider để cung cấp WeatherBloc cho cây Widget
      home:  WeatherScreen() // Màn hình UI sử dụng Bloc
    );
  }
}
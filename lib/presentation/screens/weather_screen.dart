import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart';


import '../widgets/weather_display_widget.dart';


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _getWeather(BuildContext context) {
    if (_cityController.text.trim().isNotEmpty) {
      context.read<WeatherBloc>().add(GetWeatherEvent(_cityController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Khu vực nhập thành phố và nút
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'Enter city name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                        ),
                        style: const TextStyle(fontSize: 16.0),
                        onSubmitted: (_) {
                          _getWeather(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _getWeather(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 2.0,
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Khu vực hiển thị kết quả (Loading, Data, Error)
            Expanded(
              child: Center(
                child: BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (context, state) {
                    // Kiểm tra trạng thái dựa trên state.status
                    if (state.status == WeatherStatus.initial) {
                      return const Text(
                        'Enter a city to get weather',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      );
                    } else if (state.status == WeatherStatus.loading) {
                      return const CircularProgressIndicator();
                    } else if (state.status == WeatherStatus.success) {
                      return WeatherDisplayWidget(weather: state.weather!);
                    } else if (state.status == WeatherStatus.failure) {
                      return Text(
                        'Error: ${state.errorMessage!}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.red),
                      );
                    }
                    // Trường hợp không xác định (không nên xảy ra nếu logic đúng)
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/presentation/bloc/weather_bloc.dart';
import 'package:weather_app/presentation/bloc/weather_event.dart';
import 'package:weather_app/presentation/bloc/weather_state.dart';
import '../widgets/weather_display_widget.dart';

class WeatherPage extends StatelessWidget {
  final WeatherRepository weatherRepository;

  const WeatherPage({Key? key, required this.weatherRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(weatherRepository: weatherRepository),
      child: const WeatherPageView(),
    );
  }
}

class WeatherPageView extends StatefulWidget {
  const WeatherPageView({Key? key}) : super(key: key);

  @override
  _WeatherPageViewState createState() => _WeatherPageViewState();
}

class _WeatherPageViewState extends State<WeatherPageView> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _getWeather(BuildContext context) {
    if (_cityController.text.trim().isNotEmpty) {
      context.read<WeatherBloc>().add(GetWeatherEvent(_cityController.text.trim()));
    } else {
       _showErrorDialog('Vui lòng nhập tên thành phố.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      body: BlocConsumer<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state.status == WeatherStatus.failure) {
            // Hiển thị dialog khi trạng thái là failure và có thông báo lỗi
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              _showErrorDialog(state.errorMessage!);
            } else {
              _showErrorDialog('Đã xảy ra lỗi không xác định.');
            }

          }
        },
        builder: (context, state) {
          return Padding(
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

                // Khu vực hiển thị kết quả (Loading, Data, Error)
                Expanded(
                  child: Center(
                    child: _buildWeatherContent(state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm helper để xây dựng nội dung hiển thị dựa trên trạng thái
  Widget _buildWeatherContent(WeatherState state) {
    if (state.status == WeatherStatus.initial) {
      return const Text(
        'Enter a city to get weather',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      );
    } else if (state.status == WeatherStatus.loading) {
      return const CircularProgressIndicator();
    } else if (state.status == WeatherStatus.success) {
      // Truyền cả weather và forecast vào WeatherDisplayWidget
      return WeatherDisplayWidget(
        weather: state.weather!,
        forecast: state.forecast,
      );
    } else if (state.status == WeatherStatus.failure) {
      return Text(
        state.errorMessage ?? 'Đã xảy ra lỗi không xác định.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, color: Colors.red),
      );
    }
    // Trường hợp không xác định
    return const SizedBox.shrink();
  }
}
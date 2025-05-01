import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(const WeatherState()) {
    on<GetWeatherEvent>(_onGetWeather);
  }

  void _onGetWeather(GetWeatherEvent event, Emitter<WeatherState> emit) async {
    if (event.city.trim().isEmpty) {
      emit(state.copyWith(status: WeatherStatus.failure));
      return;
    }

    emit(state.copyWith(status: WeatherStatus.loading));

    try {

      final weather = await weatherRepository.getCurrentWeather(event.city);
      emit(state.copyWith(status: WeatherStatus.success, weather: weather, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: WeatherStatus.failure, errorMessage: 'Unable to get weather data. ${e.toString()}', weather: null));
    }
  }
}
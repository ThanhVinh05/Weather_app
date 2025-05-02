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
      emit(state.copyWith(
        status: WeatherStatus.initial,
        weather: null,
        forecast: null,
      ));
      return;
    }

    // Phát ra trạng thái loading
    emit(state.copyWith(status: WeatherStatus.loading, errorMessage: null));

    try {
      // Lấy thời tiết hiện tại
      final weather = await weatherRepository.getCurrentWeather(event.city);

      // Lấy dự báo thời tiết
      final forecast = await weatherRepository.getWeatherForecast(event.city);

      // Nếu cả hai đều thành công
      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: weather,
        forecast: forecast.list,
        errorMessage: null,
      ));

    } catch (e) {

      emit(state.copyWith(
        status: WeatherStatus.failure,
        // errorMessage: 'Không thể lấy dữ liệu thời tiết: ${e.toString()}',
        errorMessage: 'Không thể tìm thấy dữ liệu thời tiết của thành phố này:',
        weather: null,
        forecast: null,
      ));
    }
  }
}
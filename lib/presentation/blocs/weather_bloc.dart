import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/repositories/weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({required this.weatherRepository}) : super(const WeatherState()) {
    on<GetWeatherEvent>(_onGetWeather);
    on<GetCitySuggestionsEvent>(_onGetCitySuggestions,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).flatMap(mapper),
    );
    on<ClearCitySuggestionsEvent>(_onClearCitySuggestions);
  }

  void _onGetWeather(GetWeatherEvent event, Emitter<WeatherState> emit) async {
    emit(state.copyWith(citySuggestions: null));

    if (event.city.trim().isEmpty) {
      emit(state.copyWith(
        status: WeatherStatus.initial,
        weather: null,
        forecast: null,
        errorMessage: null,
      ));
      return;
    }

    emit(state.copyWith(status: WeatherStatus.loading, errorMessage: null));

    try {
      final weather = await weatherRepository.getCurrentWeather(event.city);
      final forecast = await weatherRepository.getWeatherForecast(event.city);

      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: weather,
        forecast: forecast.list,
        errorMessage: null,
      ));

    } catch (e) {
      String errorMessage = 'Đã xảy ra lỗi khi lấy dữ liệu thời tiết.';
      if (e is Exception) {
        errorMessage = e.toString();
        if (errorMessage.contains('Không có kết nối Internet')) {
          errorMessage = 'Không có kết nối Internet. Vui lòng kiểm tra lại mạng của bạn.';
        } else if (errorMessage.contains('API trả về mã lỗi')) {
          errorMessage = 'API trả về mã lỗi. Vui lòng kiểm tra lại API của bạn.';
        } else {
          errorMessage = 'Đã xảy ra lỗi không xác định: ${e.toString()}';
        }
      } else {
        // Nếu không phải Exception, chuyển sang String
        errorMessage = e.toString();
      }


      emit(state.copyWith(
        status: WeatherStatus.failure,
        errorMessage: errorMessage,
        weather: null,
        forecast: null,
      ));
    }
  }

  void _onGetCitySuggestions(GetCitySuggestionsEvent event, Emitter<WeatherState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(citySuggestions: null));
      return;
    }

    try {
      final suggestions = await weatherRepository.getCitySuggestions(event.query);
      emit(state.copyWith(citySuggestions: suggestions));
    } catch (e) {
      print('Lỗi khi tìm kiếm gợi ý: $e');
      emit(state.copyWith(citySuggestions: null));
    }
  }


  void _onClearCitySuggestions(ClearCitySuggestionsEvent event, Emitter<WeatherState> emit) {
    emit(state.copyWith(citySuggestions: null));
  }
}
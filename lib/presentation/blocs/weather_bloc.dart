import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/repositories/weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;
  final Location _location;

  WeatherBloc({required this.weatherRepository, required Location location})
      : _location = location,
        super(const WeatherState()) {
    on<GetWeatherEvent>(_onGetWeather);
    on<GetCitySuggestionsEvent>(
      _onGetCitySuggestions,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).flatMap(mapper),
    );
    on<ClearCitySuggestionsEvent>(_onClearCitySuggestions);
    on<GetWeatherByLocationEvent>(_onGetWeatherByLocation);
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
          // errorMessage = 'Đã xảy ra lỗi không xác định: ${e.toString()}';
          errorMessage = 'Không thể lấy và phân tích dữ liệu thời tiết.';
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

  void _onGetWeatherByLocation(GetWeatherByLocationEvent event, Emitter<WeatherState> emit) async {
    emit(state.copyWith(
      status: WeatherStatus.loading,
      errorMessage: null,
      citySuggestions: null,
    ));

    try {
      // Kiểm tra và yêu cầu dịch vụ vị trí
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          throw Exception('Dịch vụ định vị không được bật. Vui lòng bật dịch vụ định vị trên thiết bị của bạn.');
        }
      }

      // Kiểm tra và yêu cầu quyền truy cập vị trí
      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await _location.requestPermission();
        if (permission != PermissionStatus.granted) {
          throw Exception('Quyền truy cập vị trí bị từ chối. Vui lòng cấp quyền truy cập vị trí cho ứng dụng trong cài đặt.');
        }
      }

      // Lấy vị trí hiện tại
      final locationData = await _location.getLocation();
      final lat = locationData.latitude;
      final lon = locationData.longitude;

      if (lat == null || lon == null) {
        throw Exception('Không thể lấy được tọa độ hiện tại.');
      }

      print('Fetched Location: Lat = $lat, Lon = $lon');

      // Sử dụng tọa độ để lấy dữ liệu thời tiết và dự báo
      final weather = await weatherRepository.getCurrentWeatherByCoordinates(lat, lon);
      final forecast = await weatherRepository.getWeatherForecastByCoordinates(lat, lon);

      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: weather,
        forecast: forecast.list,
        errorMessage: null,
      ));

    } catch (e) {
      // Xử lý lỗi và phát ra trạng thái failure
      String errorMessage = 'Đã xảy ra lỗi khi xác định vị trí hoặc lấy dữ liệu thời tiết.';
      if (e is Exception) {
        errorMessage = e.toString();
        // Các kiểm tra cụ thể để đưa ra thông báo lỗi thân thiện hơn
        if (errorMessage.contains('Dịch vụ định vị không được bật')) {
          errorMessage = 'Dịch vụ định vị không được bật. Vui lòng bật dịch vụ định vị.';
        } else if (errorMessage.contains('Quyền truy cập vị trí bị từ chối')) {
          errorMessage = 'Ứng dụng không có quyền truy cập vị trí. Vui lòng cấp quyền trong cài đặt.';
        } else if (errorMessage.contains('Không có kết nối Internet')) {
          errorMessage = 'Không có kết nối Internet. Vui lòng kiểm tra lại mạng của bạn.';
        }
        else {
          errorMessage = 'Không thể lấy dữ liệu thời tiết theo vị trí hiện tại.';
        }
      } else {
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
}
import 'package:weather_app/domain/models/forecast_response.dart';
import 'package:weather_app/domain/models/weather_response.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/services/weather_api_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;
  final String _apiKey;

  WeatherRepositoryImpl(this._apiService, this._apiKey);

  @override
  Future<WeatherResponse> getCurrentWeather(String city) async {
    try {
      final rawData = await _apiService.getCurrentWeather(city, _apiKey);

      if (rawData['cod'] == 200) {
        return WeatherResponse.fromJson(rawData);
      } else {
        String? apiMessage = rawData.containsKey('message') ? rawData['message'] : 'Lỗi API không xác định';
        throw Exception('API trả về mã lỗi: ${rawData['cod']} - $apiMessage');
      }

    } catch (e) {
      throw Exception('Không lấy được và phân tích được dữ liệu thời tiết: $e');
    }
  }

  @override
  Future<ForecastResponse> getWeatherForecast(String city) async {
    try {
      final rawData = await _apiService.getWeatherForecast(city, _apiKey);

      if (rawData['cod'] == '200') {
        return ForecastResponse.fromJson(rawData);
      } else {
        String? apiMessage = rawData.containsKey('message') ? rawData['message'] : 'Lỗi API không xác định';
        throw Exception('API trả về mã lỗi: ${rawData['cod']} - $apiMessage');
      }

    } catch (e) {
      throw Exception('Không thể lấy và phân tích dữ liệu dự báo thời tiết: $e');
    }
  }

  @override
  Future<List<String>> getCitySuggestions(String query) async {
    try {
      final rawSuggestions = await _apiService.getCitySuggestions(query, _apiKey);

      // Chuyển đổi dữ liệu thô sang danh sách chuỗi định dạng "City, State, Country"
      final List<String> suggestions = rawSuggestions.map((json) {
        final String name = json['name'];
        final String? state = json['state'];
        final String country = json['country'];

        // Định dạng chuỗi gợi ý
        if (state != null && state.isNotEmpty) {
          return '$name, $state, $country';
        } else {
          return '$name, $country';
        }
      }).toList();

      return suggestions;

    } catch (e) {
      print('Lỗi tại Repository khi lấy gợi ý: $e');
      return []; // Trả về danh sách rỗng khi có lỗi
    }
  }
}
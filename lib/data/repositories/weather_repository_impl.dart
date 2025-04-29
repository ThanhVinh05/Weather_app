import 'package:weather_app/domain/models/weather_response.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/services/weather_api_service.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService _apiService;
  final String _apiKey; // API Key được truyền vào

  WeatherRepositoryImpl(this._apiService, this._apiKey);

  @override
  Future<WeatherResponse> getCurrentWeather(String city) async {
    try {
      // 1. Gọi Service để lấy dữ liệu thô
      final rawData = await _apiService.getCurrentWeather(city, _apiKey);

      // 2. Xử lý dữ liệu thô thành Domain Model
      // Kiểm tra cod = 200 trước khi parse để chắc chắn thành công từ API
      if (rawData['cod'] == 200) {
        return WeatherResponse.fromJson(rawData);
      } else {
        // Xử lý trường hợp API trả về mã lỗi không phải 200 nhưng không ném DioError
        throw Exception('API returned error code: ${rawData['cod']} - ${rawData['message']}');
      }

    } catch (e) {
      // Bắt lỗi từ Service hoặc lỗi parse JSON
      throw Exception('Failed to get and parse weather data: $e');
    }
  }

}
import 'package:dio/dio.dart';

class WeatherApiService {
  final Dio _dio;
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  WeatherApiService(this._dio); // Nhận Dio instance qua constructor

  // Hàm này chỉ gọi API và trả về dữ liệu thô (Map<String, dynamic>)
  Future<Map<String, dynamic>> getCurrentWeather(String city, String apiKey) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric', // Lấy nhiệt độ C, tốc độ gió m/s
          'lang': 'vi', // Ngôn ngữ mô tả thời tiết
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        // Dio sẽ tự xử lý các lỗi >= 400, ném ra DioError
        throw DioError(
            requestOptions: response.requestOptions,
            response: response,
            type: DioErrorType.badResponse,
            error: 'API returned status code ${response.statusCode}');
      }

    } on DioError catch (e) {
      // Xử lý các lỗi từ Dio (network, timeout, bad response, ...)
      String errorMessage = 'Failed to fetch weather data';
      if (e.response != null) {
        errorMessage = 'API Error: ${e.response!.statusCode} - ${e.response!.data['message']}';
      } else {
        errorMessage = 'Network Error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Bắt các lỗi khác có thể xảy ra trong quá trình request
      throw Exception('An unexpected error occurred: $e');
    }
  }

}
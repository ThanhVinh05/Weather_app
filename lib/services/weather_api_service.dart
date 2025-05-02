import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WeatherApiService {
  final Dio _dio;
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  final Connectivity _connectivity; // Thuộc tính kiểm tra mạng

  WeatherApiService(this._dio, this._connectivity);

  Future<Map<String, dynamic>> getCurrentWeather(String city,
      String apiKey) async {
    try {
      // Thêm kiểm tra kết nối mạng trước khi gọi API
      if (await _checkConnectivity() == false) {
        throw Exception('Không có kết nối Internet.');
      }

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
            error: 'Mã trạng thái trả về của API ${response.statusCode}');
      }
    } on DioError catch (e) {
      // Xử lý các lỗi từ Dio (network, timeout, bad response, ...)
      String errorMessage = 'Không thể lấy dữ liệu thời tiết.';
      if (e.response != null) {
        errorMessage =
        'Lỗi API: ${e.response!.statusCode} - ${e.response!.data['message']}';
      } else {
        errorMessage = 'Lỗi mạng: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Bắt các lỗi khác có thể xảy ra trong quá trình request
      throw Exception('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  Future<Map<String, dynamic>> getWeatherForecast(String city,
      String apiKey) async {
    try {
      // Thêm kiểm tra kết nối mạng trước khi gọi API
      if (await _checkConnectivity() == false) {
        throw Exception('Không có kết nối Internet.');
      }

      final response = await _dio.get(
        '$_baseUrl/forecast', // Endpoint cho dự báo
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
        // Dio sẽ tự xử lý các lỗi >= 400, ném ra  DioException
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Mã trạng thái trả về của API ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Xử lý các lỗi từ Dio
      String errorMessage = 'Không thể lấy dữ liệu thời tiết.';
      if (e.response != null) {
        // Chắc chắn rằng e.response!.data là Map trước khi truy cập 'message'
        if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          errorMessage = 'Lỗi API: ${e.response!.statusCode} - ${e.response!
              .data['message']}';
        } else {
          errorMessage = 'Lỗi API: ${e.response!.statusCode}';
        }
      } else {
        errorMessage = 'Lỗi mạng: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Bắt các lỗi khác
      throw Exception(
          'Đã xảy ra lỗi không mong muốn khi tải dự báo: $e');
    }
  }

  // Phương thức kiểm tra kết nối mạng
  Future<bool> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

}
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:weather_app/core/constants/api_constants.dart';

class WeatherApiService {
  final Dio _dio;
  final String _weatherBaseUrl = ApiConstants.WEATHERDATA;
  final String _geoBaseUrl = ApiConstants.GEOCODINGDATA;
  final Connectivity _connectivity;

  WeatherApiService(this._dio, this._connectivity);

  Future<Map<String, dynamic>> getCurrentWeather(String city, String apiKey) async {
    try {
      if (await _checkConnectivity() == false) {
        throw Exception('Không có kết nối Internet.');
      }

      final response = await _dio.get(
        '$_weatherBaseUrl/weather',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'vi',
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Mã trạng thái trả về của API ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Không thể lấy dữ liệu thời tiết.';
      if (e.response != null) {
        if (e.response!.data is Map && e.response!.data.containsKey('message')) {
          errorMessage = 'Lỗi API: ${e.response!.statusCode} - ${e.response!.data['message']}';
        } else {
          errorMessage = 'Lỗi API: ${e.response!.statusCode}';
        }
      } else {
        errorMessage = 'Lỗi mạng: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  Future<Map<String, dynamic>> getWeatherForecast(String city, String apiKey) async {
    try {
      if (await _checkConnectivity() == false) {
        throw Exception('Không có kết nối Internet.');
      }

      final response = await _dio.get(
        '$_weatherBaseUrl/forecast',
        queryParameters: {
          'q': city,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'vi',
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Mã trạng thái trả về của API ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Không thể lấy dữ liệu thời tiết.';
      if (e.response != null) {
        if (e.response!.data is Map &&
            e.response!.data.containsKey('message')) {
          errorMessage = 'Lỗi API: ${e.response!.statusCode} - ${e.response!.data['message']}';
        } else {
          errorMessage = 'Lỗi API: ${e.response!.statusCode}';
        }
      } else {
        errorMessage = 'Lỗi mạng: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không mong muốn khi tải dự báo: $e');
    }
  }


  Future<List<Map<String, dynamic>>> getCitySuggestions(String query, String apiKey) async {
    try {
      if (await _checkConnectivity() == false) {
        print('Không có kết nối Internet, không thể lấy gợi ý thành phố.');
        return [];
      }

      final response = await _dio.get(
        '$_geoBaseUrl/direct', // Endpoint lấy thông tin từ tên thành phố
        queryParameters: {
          'q': query,
          'limit': 5, // Giới hạn 5 gợi ý
          'appid': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        // Xử lý lỗi API trả về mã khác 200
        print('Lỗi API Geocoding: ${response.statusCode} - ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('Lỗi Dio khi lấy gợi ý thành phố: ${e.message}');
      return [];
    } catch (e) {
      print('Lỗi không mong muốn khi lấy gợi ý thành phố: $e');
      return [];
    }
  }


  Future<bool> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
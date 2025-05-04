import 'package:equatable/equatable.dart';
import 'package:weather_app/domain/models/forecast_model.dart';

// Model tổng thể cho phản hồi dự báo thời tiết 5 ngày / 3 giờ
class ForecastResponse extends Equatable {
  final String cod; // Mã trạng thái HTTP từ API
  final int cnt; // Số lượng mục dự báo
  final List<ForecastModel> list; // Danh sách các mục dự báo

  const ForecastResponse({
    required this.cod,
    required this.cnt,
    required this.list,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    // Cần kiểm tra 'list' không null và là List trước khi map
    final List<dynamic>? forecastList = json['list'];
    if (forecastList == null) {
      throw FormatException('JSON không hợp lệ: Thiếu trường "danh sách" trong dữ liệu dự báo');
    }

    return ForecastResponse(
      cod: json['cod'] as String, // API trả về string '200' cho thành công
      cnt: json['cnt'] as int,
      list: forecastList
          .map((item) => ForecastModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object> get props => [cod, cnt, list];
}
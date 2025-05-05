import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

// Event khi người dùng muốn lấy thời tiết cho một thành phố
class GetWeatherEvent extends WeatherEvent {
  final String city;

  const GetWeatherEvent(this.city);

  @override
  List<Object> get props => [city];
}

// Event khi người dùng nhập vào ô tìm kiếm để lấy gợi ý thành phố
class GetCitySuggestionsEvent extends WeatherEvent {
  final String query;

  const GetCitySuggestionsEvent(this.query);

  @override
  List<Object> get props => [query];
}

// Event để xóa danh sách gợi ý
class ClearCitySuggestionsEvent extends WeatherEvent {
  const ClearCitySuggestionsEvent();

  @override
  List<Object> get props => []; // Không có thuộc tính
}

// Event lấy thời tiết theo vị trí hiện tại
class GetWeatherByLocationEvent extends WeatherEvent {
  const GetWeatherByLocationEvent();

  @override
  List<Object> get props => []; // Không có thuộc tính
}
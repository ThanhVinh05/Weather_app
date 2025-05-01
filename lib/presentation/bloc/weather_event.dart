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


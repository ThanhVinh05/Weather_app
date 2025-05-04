class WeatherModel {
  final double temp; // Nhiệt độ hiện tại (°C)
  final int humidity; // Độ ẩm (%)

  WeatherModel({
    required this.temp,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temp: (json['temp'] as num).toDouble(),
      humidity: json['humidity'] as int,
    );
  }
}
class WeatherData {
  final double temp; // Nhiệt độ hiện tại (°C)
  final int humidity; // Độ ẩm (%)

  WeatherData({
    required this.temp,
    required this.humidity,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['temp'] as num).toDouble(),
      humidity: json['humidity'] as int,
    );
  }
}
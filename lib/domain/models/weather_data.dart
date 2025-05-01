class MainWeatherData {
  final double temp; // Nhiệt độ hiện tại (°C)
  final int humidity; // Độ ẩm (%)

  MainWeatherData({
    required this.temp,
    required this.humidity,
  });

  factory MainWeatherData.fromJson(Map<String, dynamic> json) {
    return MainWeatherData(
      temp: (json['temp'] as num).toDouble(),
      humidity: json['humidity'] as int,
    );
  }
}
class Main {
  final double temp; // nhiệt độ
  final int humidity; // độ ẩm
  final int pressure; // áp suất

  Main({required this.temp, required this.humidity, required this.pressure});

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: (json['temp'] as num).toDouble(),
      humidity: json['humidity'] as int,
      pressure: json['pressure'] as int,
    );
  }
}
class WindData {
  final double speed; // Tốc độ gió (m/s hoặc mph)

  WindData({
    required this.speed,
  });

  factory WindData.fromJson(Map<String, dynamic> json) {
    return WindData(
      speed: (json['speed'] as num).toDouble(),
    );
  }
}
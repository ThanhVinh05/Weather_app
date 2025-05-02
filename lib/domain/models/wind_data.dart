class WindData {
  final double speed; // Tốc độ gió

  WindData({
    required this.speed,
  });

  factory WindData.fromJson(Map<String, dynamic> json) {
    return WindData(
      speed: (json['speed'] as num).toDouble(),
    );
  }
}
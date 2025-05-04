class WindModel {
  final double speed; // Tốc độ gió

  WindModel({
    required this.speed,
  });

  factory WindModel.fromJson(Map<String, dynamic> json) {
    return WindModel(
      speed: (json['speed'] as num).toDouble(),
    );
  }
}
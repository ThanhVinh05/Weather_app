class WeatherCondition {
  final int id; // ID điều kiện thời tiết
  final String description; // Mô tả chi tiết
  final String icon; // Mã icon thời tiết

  WeatherCondition({
    required this.id,
    required this.description,
    required this.icon,
  });

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      id: json['id'] as int,
      description: json['description'] as String,
      icon: json['icon'] as String,
    );
  }
}
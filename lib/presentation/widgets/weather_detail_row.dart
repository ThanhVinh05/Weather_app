import 'package:flutter/material.dart';

class WeatherDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const WeatherDetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 17),
        ),
      ],
    );
  }
}
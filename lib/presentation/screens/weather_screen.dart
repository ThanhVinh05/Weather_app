import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();

  // Dữ liệu thời tiết mẫu tĩnh để hiển thị
  final String _sampleCity = 'Hà Nội';
  final String _sampleWeatherDescription = 'Mây rải rác';
  final double _sampleTemperature = 28.5;
  final int _sampleHumidity = 70;
  final double _sampleWindSpeed = 3.6;
  final double _sampleFeelsLike = 32.1;
  final IconData _sampleWeatherIcon = Icons.cloud;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 4.0, // Thêm bóng cho AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Khu vực nhập thành phố và nút
            Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'Enter city name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true, // Đổ màu nền cho TextField
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                        ),
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        print('See pressed for city: ${_cityController.text}');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder( // Bo tròn góc nút
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: _buildWeatherDisplayStatic(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để hiển thị thông tin thời tiết mẫu tĩnh
  Widget _buildWeatherDisplayStatic() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _sampleCity,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87
          ),
        ),
        const SizedBox(height: 16),

        Icon(
          _sampleWeatherIcon,
          size: 100,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),

        Text(
          _sampleWeatherDescription,
          style: const TextStyle(
              fontSize: 22,
              fontStyle: FontStyle.italic,
              color: Colors.black54
          ),
        ),
        const SizedBox(height: 24),

        Text(
          '${_sampleTemperature.toStringAsFixed(1)}°C', // Định dạng nhiệt độ
          style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent
          ),
        ),

        const SizedBox(height: 32),

        Card( // Sử dụng Card để nhóm các thông tin chi tiết
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Bo tròn góc Card
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Độ ẩm:', '${_sampleHumidity}%'),
                const Divider(height: 24), // Tăng chiều cao Divider
                _buildDetailRow('Tốc độ gió:', '${_sampleWindSpeed.toStringAsFixed(1)} m/s'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Widget helper cho từng dòng chi tiết
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        Text(value, style: const TextStyle(fontSize: 18, color: Colors.blueGrey)),
      ],
    );
  }
}
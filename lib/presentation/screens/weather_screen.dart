import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/presentation/blocs/weather_bloc.dart';
import 'package:weather_app/presentation/blocs/weather_event.dart';
import 'package:weather_app/presentation/blocs/weather_state.dart';
import '../widgets/weather_display_widget.dart';

class WeatherScreen extends StatelessWidget {
  final WeatherRepository weatherRepository;

  const WeatherScreen({Key? key, required this.weatherRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(weatherRepository: weatherRepository),
      child: const WeatherScreenView(),
    );
  }
}

class WeatherScreenView extends StatefulWidget {
  const WeatherScreenView({Key? key}) : super(key: key);

  @override
  _WeatherScreenViewState createState() => _WeatherScreenViewState();
}

class _WeatherScreenViewState extends State<WeatherScreenView> {
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _cityFocusNode = FocusNode();

  final List<String> _cities = [
    'Chọn thành phố',
    'Hà Nội',
    'Đà Nẵng',
    'Thành phố Hồ Chí Minh',
    'New York',
    'Seoul',
    'Bangkok',
  ];

  String _selectedCity = 'Chọn thành phố';

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi của text trong TextField để gửi event lấy gợi ý
    _cityController.addListener(_onCityQueryChanged);

    // Lắng nghe sự thay đổi focus để ẩn gợi ý khi mất focus
    _cityFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _cityController.removeListener(_onCityQueryChanged);
    _cityController.dispose();
    _cityFocusNode.removeListener(_onFocusChanged);
    _cityFocusNode.dispose();
    super.dispose();
  }

  void _onCityQueryChanged() {
    final query = _cityController.text.trim();

    // Gửi event lấy gợi ý chỉ khi TextField có focus và text không rỗng
    if (_cityFocusNode.hasFocus && query.isNotEmpty) {
      context.read<WeatherBloc>().add(GetCitySuggestionsEvent(query));
    } else if (query.isEmpty) {
      // Nếu text rỗng, xóa gợi ý
      context.read<WeatherBloc>().add(const ClearCitySuggestionsEvent());
    }
  }

  void _onFocusChanged() {
    if (!_cityFocusNode.hasFocus) {
      // Nếu TextField mất focus, đợi một chút rồi xóa gợi ý
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          context.read<WeatherBloc>().add(const ClearCitySuggestionsEvent());
        }
      });
    } else {
      // Nếu TextField có focus, kiểm tra nếu có text thì lấy gợi ý lại
      if (_cityController.text.trim().isNotEmpty) {
        context.read<WeatherBloc>().add(GetCitySuggestionsEvent(_cityController.text.trim()));
      }
    }
  }

  void _getWeather(String city) {
    _cityFocusNode.unfocus();
    if (city.trim().isNotEmpty) {
      _cityController.text = city.trim();
      _cityController.selection = TextSelection.fromPosition(TextPosition(offset: _cityController.text.length));
    } else {
      _showErrorDialog('Vui lòng nhập tên thành phố.');
      _cityController.clear();
    }
    context.read<WeatherBloc>().add(GetWeatherEvent(city.trim()));
    context.read<WeatherBloc>().add(const ClearCitySuggestionsEvent());
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      //  GestureDetector để đóng bàn phím khi tap ra ngoài
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: BlocConsumer<WeatherBloc, WeatherState>(
          listener: (context, state) {
            if (state.status == WeatherStatus.failure) {
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
                _showErrorDialog(state.errorMessage!);
              }
            }
          },
          builder: (context, state) {
            // Lọc danh sách gợi ý dựa trên text hiện tại trong TextField
            final String currentQuery = _cityController.text.trim().toLowerCase();
            final List<String>? filteredSuggestions = state.citySuggestions?.where((suggestion) {
              if (currentQuery.isEmpty) {
                return false; // Không hiển thị gợi ý nếu ô nhập rỗng
              }
              // Chuyển gợi ý và query về chữ thường để so sánh không phân biệt hoa/thường
              return suggestion.toLowerCase().startsWith(currentQuery);
            }).toList();


            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
              Card(
              elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Chọn thành phố',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    isExpanded: true,
                    value: _selectedCity,
                    items: _cities.map((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                        if (newValue != 'Chọn thành phố') {
                          _getWeather(newValue);
                        } else {
                          _getWeather('');
                        }
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ),
              ),

              // Khu vực Search
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // Margin dưới chỉ áp dụng khi KHÔNG hiển thị gợi ý hoặc TextField mất focus
                margin: filteredSuggestions != null && filteredSuggestions.isNotEmpty && _cityFocusNode.hasFocus
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(bottom: 24.0),

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              focusNode: _cityFocusNode, // Gán FocusNode
                              decoration: InputDecoration(
                                labelText: 'Nhập tên thành phố',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                              ),
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedCity = 'Chọn thành phố';
                              });
                              _getWeather(_cityController.text.trim());
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              elevation: 2.0,
                            ),
                            child: const Text('Search'),
                          ),
                        ],
                      ),

                      // Hiển thị danh sách gợi ý đã lọc nếu có và TextField đang có focus
                      if (_cityFocusNode.hasFocus && filteredSuggestions != null && filteredSuggestions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: filteredSuggestions.length, // Sử dụng danh sách đã lọc
                              itemBuilder: (context, index) {
                                final suggestion = filteredSuggestions[index]; // Lấy từ danh sách đã lọc
                                return ListTile(
                                  title: Text(suggestion),
                                  onTap: () {

                                    setState(() {
                                      _selectedCity = 'Chọn thành phố';
                                    });
                                    _getWeather(suggestion);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Khu vực hiển thị kết quả (Loading, Data, Error)
              Expanded(
                child: Center(
                  child: _buildWeatherContent(state),
                ),
              ),
              ],
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherState state) {
    if (state.status == WeatherStatus.loading) {
      return const CircularProgressIndicator();
    } else if (state.status == WeatherStatus.success) {
      return WeatherDisplayWidget(
        weather: state.weather!,
        forecast: state.forecast,
      );
    }
    return const SizedBox.shrink();
  }
}
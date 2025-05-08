import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/presentation/blocs/weather_bloc.dart';
import 'package:weather_app/presentation/blocs/weather_event.dart';
import 'package:weather_app/presentation/blocs/weather_state.dart';
import '../widgets/weather_display_widget.dart';

class WeatherScreen extends StatelessWidget {
  final WeatherRepository weatherRepository;

  const WeatherScreen({Key? key, required this.weatherRepository }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final location = Location();
    return BlocProvider(
      create: (context) => WeatherBloc(weatherRepository: weatherRepository, location: location),
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
    '',
    'Hà Nội',
    'Đà Nẵng',
    'Thành phố Hồ Chí Minh',
    'New York',
    'Seoul',
    'Bangkok',
  ];

  String _selectedCity = '';

  @override
  void initState() {
    super.initState();
    _cityController.addListener(_onCityQueryChanged);
    _cityFocusNode.addListener(_onFocusChanged);
    _cityController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherBloc>().add(const GetWeatherByLocationEvent());
    });
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

    if (_cityFocusNode.hasFocus && query.isNotEmpty) {
      context.read<WeatherBloc>().add(GetCitySuggestionsEvent(query));
    } else if (query.isEmpty) {
      context.read<WeatherBloc>().add(const ClearCitySuggestionsEvent());
    }
  }

  void _onFocusChanged() {
    if (!_cityFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          context.read<WeatherBloc>().add(const ClearCitySuggestionsEvent());
        }
      });
    } else {
      if (_cityController.text.trim().isNotEmpty) {
        context.read<WeatherBloc>().add(GetCitySuggestionsEvent(_cityController.text.trim()));
      }
    }
  }

  void _getWeather(String city) {
    _cityFocusNode.unfocus();

    final trimmedCity = city.trim();

    if (trimmedCity.isEmpty) {
      _showErrorDialog('Vui lòng nhập tên thành phố.');
      _cityController.clear();
      setState(() {
        _selectedCity = '';
      });
      context.read<WeatherBloc>().add(const ClearCitySuggestionsEvent());
      context.read<WeatherBloc>().add(GetWeatherEvent(''));
      return;
    }
    _cityController.text = trimmedCity;
    _cityController.selection = TextSelection.fromPosition(TextPosition(offset: _cityController.text.length));
    context.read<WeatherBloc>().add(GetWeatherEvent(trimmedCity));
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

  String _getBackgroundImage(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) {
      return 'assets/backgrounds/initial_background.jpg'; // Ảnh nền ban đầu hoặc mặc định
    }

    // Logic ánh xạ mã icon sang tên file ảnh
    if (iconCode.endsWith('d')) { // Ban ngày
      if (iconCode.startsWith('01')) return 'assets/backgrounds/clear_day.jpg';
      if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) return 'assets/backgrounds/clouds_day.jpg';
      if (iconCode.startsWith('09') || iconCode.startsWith('10') || iconCode.startsWith('11')) return 'assets/backgrounds/rain_day.jpg'; // Gộp mưa, mưa phùn, dông
      if (iconCode.startsWith('13')) return 'assets/backgrounds/snow_day.jpg';
      if (iconCode.startsWith('50')) return 'assets/backgrounds/mist_day.jpg';
      return 'assets/backgrounds/default_day.jpg'; // Mặc định ban ngày
    } else { // Ban đêm ('n')
      if (iconCode.startsWith('01')) return 'assets/backgrounds/clear_night.jpg';
      if (iconCode.startsWith('02') || iconCode.startsWith('03') || iconCode.startsWith('04')) return 'assets/backgrounds/clouds_night.jpg';
      if (iconCode.startsWith('09') || iconCode.startsWith('10') || iconCode.startsWith('11')) return 'assets/backgrounds/rain_night.jpg'; // Gộp mưa, mưa phùn, dông
      if (iconCode.startsWith('13')) return 'assets/backgrounds/snow_night.jpg';
      if (iconCode.startsWith('50')) return 'assets/backgrounds/mist_night.jpg';
      return 'assets/backgrounds/default_night.jpg'; // Mặc định ban đêm
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.withOpacity(0.5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _cityController.clear();
              setState(() {
                _selectedCity = '';
              });
              context.read<WeatherBloc>().add(const ClearCitySuggestionsEvent());
              context.read<WeatherBloc>().add(const GetWeatherByLocationEvent());
            },
          ),
        ],
      ),
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
              if (_cityController.text.isNotEmpty) {
                _cityController.clear();
              }
              setState(() {
                _selectedCity = '';
              });
            }
          },
          builder: (context, state) {
            return BlocBuilder<WeatherBloc, WeatherState>(
                  builder: (context, state) {
                    final currentIconCode = state.status == WeatherStatus.success && state.weather != null && state.weather!.weather.isNotEmpty
                        ? state.weather!.weather.first.icon
                        : null;

                    final backgroundImagePath = _getBackgroundImage(currentIconCode);

                    final String currentQuery = _cityController.text.trim().toLowerCase();
                    final List<String>? filteredSuggestions = state.citySuggestions?.where((suggestion) {
                      if (currentQuery.isEmpty) {
                        return false;
                      }
                      return suggestion.toLowerCase().contains(currentQuery);
                    }).toList();


                    return Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(backgroundImagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // Dropdown chọn thành phố
                              Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: DropdownButtonFormField<String>(

                                  decoration: const InputDecoration(
                                    labelText: 'Chọn thành phố',
                                    labelStyle: TextStyle(color: Colors.black87),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  isExpanded: true,
                                  value: _selectedCity,
                                  items: _cities.map((String city) {
                                    return DropdownMenuItem<String>(
                                      value: city,
                                      // Sử dụng DefaultTextStyle để áp dụng màu chữ cho các mục trong Dropdown
                                      child: DefaultTextStyle(
                                        style: const TextStyle(color: Colors.black87),
                                        child: Text(city),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCity = newValue;
                                      });
                                      if (newValue != '') {
                                        _getWeather(newValue);
                                      } else {
                                        _cityController.clear();
                                        _getWeather('');
                                      }
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                  dropdownColor: Colors.white.withOpacity(0.7),
                                  style: const TextStyle(fontSize: 16.0, color: Colors.white),
                                  iconEnabledColor: Colors.black,
                                ),
                              ),

                              // Khu vực tìm kiếm (TextField và Button)
                              Container(
                                margin: _cityFocusNode.hasFocus && filteredSuggestions != null && filteredSuggestions.isNotEmpty
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.only(bottom: 24.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(filteredSuggestions != null && filteredSuggestions.isNotEmpty ? 0.9 : 0.3), // Nền trong suốt hơn khi không có gợi ý, ít trong suốt hơn khi có gợi ý
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _cityController,
                                            focusNode: _cityFocusNode,
                                            decoration: InputDecoration(
                                              labelText: 'Nhập tên thành phố',
                                              labelStyle: TextStyle(color: _cityFocusNode.hasFocus ? Colors.black87 : Colors.black54), // Đổi màu label khi focus
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8.0),
                                                borderSide: BorderSide.none,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white.withOpacity(0.7),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                                            ),
                                            style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                                            cursorColor: Colors.blueAccent,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _selectedCity = '';
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
                                            elevation: 0,
                                          ),
                                          child: const Text('Search'),
                                        ),
                                      ],
                                    ),

                                    if (_cityFocusNode.hasFocus && filteredSuggestions != null && filteredSuggestions.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxHeight: 200),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.zero,
                                            itemCount: filteredSuggestions.length,
                                            itemBuilder: (context, index) {
                                              final suggestion = filteredSuggestions[index];
                                              return ListTile(
                                                title: Text(suggestion, style: const TextStyle(color: Colors.black87),),
                                                onTap: () {
                                                  setState(() {
                                                    _selectedCity = '';
                                                  });
                                                  _getWeather(suggestion);
                                                },
                                                tileColor: Colors.white.withOpacity(0.9),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),


                              // Khu vực hiển thị kết quả (Loading, Data)
                              Expanded(
                                child: Center(
                                  child: _buildWeatherContent(state),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
          },
          ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherState state) {
    if (state.status == WeatherStatus.loading) {
      return const CircularProgressIndicator(color: Colors.white,);
    } else if (state.status == WeatherStatus.success) {
      if (state.weather != null) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
          ),
          padding: const EdgeInsets.all(16.0),
          child: WeatherDisplayWidget(
            weather: state.weather!,
            forecast: state.forecast,
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}
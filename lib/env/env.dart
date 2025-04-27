import 'package:envied/envied.dart';

part 'env.g.dart'; // File này sẽ được tự động generate

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPENWEATHER_API_KEY') // Ánh xạ với tên biến trong .env
  static const String openWeatherApiKey = _Env.openWeatherApiKey;

}
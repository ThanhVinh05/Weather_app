import 'package:envied/envied.dart';

part 'env.g.dart'; //  Đây là file sẽ được generate

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPENWEATHER_API_KEY')
  static const String openWeatherApiKey = _Env.openWeatherApiKey;
}
import 'package:sprintf/sprintf.dart';
import 'package:http/http.dart' as http;

const Duration UPD_INTERVAL = const Duration(minutes: 10);
// Last time the weather information was fetched.
DateTime? lastTime = null;
// Weather app key.
const String WTTR_KEY = '1473cbe9b65e8b1d60d7b15f1614607a';
// City name
const String RQST_STR1 = 'api.openweathermap.org/data/2.5/weather?q={%s}&appid={%s}';
// City name, state
const String RQST_STR2 = 'api.openweathermap.org/data/2.5/weather?q={%s},{%s}&appid={%s}';
// City name, state, country code
const String RQST_STR3 = 'api.openweathermap.org/data/2.5/weather?q={%s},{%s},{%s}&appid={%s}';

// Get weather data. Only fetches every 10 minutes.
Future<String> fetchWeatherData() async
{
  Duration sinceLastTime;
  if(lastTime == null)
  {
    lastTime = DateTime.now();
    sinceLastTime = new Duration(minutes: 10);
  }
  else
    sinceLastTime = new Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - lastTime!.millisecondsSinceEpoch);

  if(sinceLastTime >= UPD_INTERVAL)
  {
    final response = await http.get(Uri.parse(sprintf(RQST_STR1, ['Corvallis', WTTR_KEY])));

    if(response == 200)
    {

    }
  }
  return Future.value('test');
}


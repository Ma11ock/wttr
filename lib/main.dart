import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wttr/fetcher.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

List<String> citiesToList = <String>['Portland', 'Corvallis'];

const String keyTempType = 'key-temp-type';
const String keyCitiesList = 'key-cities-list';

List<WeatherInfo> totalWeather = <WeatherInfo>[];

void main()
{
  // Init.
  Settings.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget
{
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Weather App',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: const MainPage(title: 'Weather'),
  );
}

class MainPage extends StatefulWidget
{
  const MainPage({required this.title, Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();

  final String title;
}

class MainPageState extends State<MainPage>
{
  int currentIndex = 0;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('This Week'),
      centerTitle: true,
    ),
    body: WeatherScreen(key: UniqueKey()),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(context, SettingsPage()).then((value) => setState(() {}));
      },
      child: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => setState(() {
        currentIndex = index;
        switch(index)
        {
          case 1:
            Navigator.push(context, GraphPage());
            break;
          default:
            break;
        }
      }),
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Graph',
            backgroundColor: Colors.red
        ),
      ],
    ),
  );
}


class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
{
  late WeatherBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = WeatherBloc(citiesToList);
  }

  @override
  Widget build(BuildContext context) {
    return
      RefreshIndicator(
        onRefresh: () => _bloc.fetchWeatherList(citiesToList),
        child: StreamBuilder<ApiResponse<List<WeatherInfo>>>(
          stream: _bloc.weatherListStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data!.status) {
                case Status.LOADING:
                  // Create loading
                  return Loading(loadingMessage: snapshot.data!.message);
                  break;
                case Status.COMPLETED:
                  // Create this class too
                  return ValueChangeObserver<String>(
                      cacheKey: keyTempType,
                      defaultValue: 'Celsius',
                      builder: (_, tempType, __) => WeatherList(weatherList: snapshot.data!.data, tempType: tempType),
                  );
                  break;
                case Status.ERROR:
                  return Error(errorMessage: snapshot.data!.message, onRetryPressed: () => _bloc.fetchWeatherList(citiesToList));
                  break;
              }
            }
            return Container();
          },
        ),
      );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}

final TextStyle infoTextStyle = TextStyle(
    fontSize: 18.0,
    color: Colors.grey[600]
);
class WeatherList extends StatelessWidget {
  final List<WeatherInfo> weatherList;
  final String tempType;

  WeatherList({Key? key, required this.weatherList, required this.tempType}) : super(key: key)
  {
    for (var element in weatherList) {
      if(!totalWeather.contains(element))
        totalWeather.add(element);
    }
  }

  Widget createWeatherReport(WeatherInfo info)
  {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      // TODO start here
      child: Column(),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: weatherList.map((weather) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(getWeatherIcon(weather)),
            Center(child: Text('${weather.descr}, ${getCloudiness(weather.clouds)}', style: infoTextStyle),),
            Text(
              weather.cityName,
              style: const TextStyle(
                  fontSize: 24.0,
              ),
            ),
            Text(
              'Current temperature: ${getTemp(weather.temp, tempType)}',
              style: infoTextStyle,
            ),
            Text(
              'Daily Low: ${getTemp(weather.tempMin, tempType)}; '
                  'Daily High: ${getTemp(weather.tempMax, tempType)}',
                  style: infoTextStyle
            ),
            Text(
                'Pressure: ${doubleToFixed(weather.pressure)}\nHumidity: ${doubleToFixed(weather.humidity)}%',
                style: infoTextStyle,
            ),
            Text(
              'Wind: ${doubleToFixed(weather.windSpeed)}m/s @ ${doubleToFixed(weather.windDeg)}??',
                  style: infoTextStyle
            )
            
          ],
        ),
      )).toList(),
    );
  }
}

class Error extends StatelessWidget {
  final String errorMessage;

  final VoidCallback onRetryPressed;

  const Error({Key? key, required this.errorMessage, required this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.lightGreen,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          RaisedButton(
            color: Colors.lightGreen,
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key? key, required this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.lightGreen,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends MaterialPageRoute<void>
{
  SettingsPage() : super(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
        children: [
          DropDownSettingsTile<String>(
            title: 'Measure',
            settingKey: keyTempType,
            selected: 'Celsius',
            values: const <String, String>{
              'Celsius' : 'Celsius',
              'Fahrenheit' : 'Fahrenheit',
              'Kelvin' : 'Kelvin',
            },
            onChange: (standard) { },
          ),
          ElevatedButton(
          onPressed: () { Navigator.push(context, CitiesPage()); },
          child: const Text('Edit Cities'),
        ),
      ],
        ),
      ),
    );
  });
}

class GraphPage extends MaterialPageRoute<void>
{

  GraphPage() : super(builder: (BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
         centerTitle: true,
         title: const Text('Graphs')
        ),
        body: SfCartesianChart(
          title: ChartTitle(text: 'Temperature (??Kelvin) vs\nCity'),
          primaryXAxis: CategoryAxis(),
          series: <ScatterSeries<WeatherInfo, String>>[
            ScatterSeries<WeatherInfo, String>(
              dataSource: totalWeather,
              xValueMapper: (WeatherInfo data, _) => data.cityName,
              yValueMapper: (WeatherInfo data, _) => data.temp,
            )
          ],
        ),
    ),
    );
  });
}

class CitiesPage extends MaterialPageRoute<void>
{
  CitiesPage() : super(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Cities")
      ),
      body: ValueChangeObserver<String>(
        cacheKey: keyCitiesList,
        defaultValue: "",
        builder: (_, newCity, __)
        {
          if(newCity != "" && !citiesToList.contains(newCity)) {
            if (newCity[0] == '-')
              citiesToList.remove(newCity.substring(1));
            else
              citiesToList.add(newCity);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: citiesToList.map((city) => Card(
                child: Text(city),
            )).toList(),
          );
        }
      ),
      bottomNavigationBar: TextInputSettingsTile(
        title: 'Add City',
        settingKey: keyCitiesList
      ),
    );

  });
}

IconData getWeatherIcon(WeatherInfo info)
{
  switch(info.main)
  {
    case 'Clear':
      return Icons.wb_sunny;
      break;
    case 'Clouds':
      return Icons.cloud;
      break;
    case 'Rain':
      return Icons.grain;
      break;
    case 'Snow':
      return Icons.snowboarding;
      break;
  }

  return Icons.wb_sunny;
}

String getTemp(double kelvin, String tempStandard) {
  String result;
  switch (tempStandard)
  {
    case 'Celsius':
      result = doubleToFixed(kelvin - 273.15) + "??C";
      break;
    case 'Fahrenheit':
      result = doubleToFixed((kelvin - 273.15) * (9.0/5.0) + 32.0) + "??F";
      break;
    default:
      result = doubleToFixed(kelvin) + "??K";
      break;
  }

  return result;
}

String getCloudiness(double cloudPercent)
{
  if(cloudPercent >= 0.0 && cloudPercent <= 20.0)
    return "sunny";
  else if(cloudPercent >= 20.0 && cloudPercent < 30.0)
    return "mostly sunny";
  else if(cloudPercent >= 30.0 && cloudPercent < 50.0)
    return "partly cloudy";
  else if(cloudPercent >= 50.0 && cloudPercent < 70.0)
    return "mostly cloudy";
  else if(cloudPercent >= 70.0 && cloudPercent <= 100.0)
    return "cloudy";
  return "";
}

String doubleToFixed(double d)
{
  return d.toStringAsFixed(2);
}
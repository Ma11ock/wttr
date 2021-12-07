import 'package:flutter/material.dart';
import 'package:wttr/fetcher.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

List<String> citiesToList = <String>['Corvallis', 'Portland'];
String tempStandard = 'Celsius';

void main()
{
  // Init.
  Settings.init(cacheProvider: SharePreferenceCache());
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
    body: WeatherScreen(),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(context, SettingsPage()).then((value) => setState(() {}));
      },
      child: const Icon(Icons.add),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => setState(() => currentIndex = index),
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
                  return WeatherList(weatherList: snapshot.data!.data);
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

class WeatherList extends StatefulWidget {
  List<WeatherInfo> weatherList;

  WeatherList({Key? key, required this.weatherList}) : super(key: key);

  @override
  WeatherListState createState() => WeatherListState(weatherList: weatherList);
}

class WeatherListState extends State<WeatherList>
{
  List<WeatherInfo> weatherList;
  WeatherListState({required this.weatherList});

  @override
  Widget build(BuildContext context) {
    print("Lol");
    return Column(
      children: weatherList.map((weather) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Icon(getWeatherIcon(weather)),
            Text(
              weather.cityName,
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[600]
              ),
            ),
            Text(
              'Current temperature: ${getTemp(weather.temp).toStringAsFixed(2)}',
            ),
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
          DropDownSettingsTile(
            title: 'Measure',
            settingKey: tempStandard,
            selected: 1,
            values: const <int, String>{
              1: 'Celsius',
              2: 'Fahrenheit',
              3: 'Kelvin',
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


class CitiesPage extends MaterialPageRoute<void>
{
  CitiesPage() : super(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: const Text('Edit Cities'),
        centerTitle: true,
      ),
      body: const Center(
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

double getTemp(double kelvin) {
  print("Blessus ${tempStandard}");
  switch (tempStandard)
  {
    case 'Celsius':
      return kelvin - 273.15;
      break;
    case 'Fahrenheit':
      return (kelvin - 273.15) * (9.0/5.0) + 32.0;
      break;
    case 'Kelvin':
      return kelvin;
      break;
  }

  return kelvin;
}
import 'package:flutter/material.dart';
import 'package:wttr/fetcher.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

late final DateTime appStart;

List<String> citiesToList = <String>['Corvallis', 'Portland'];

String tempStandard = 'Celsius';

void main()
{
  // Init.
  Settings.init();
  appStart = new DateTime.now();
  runApp(MainApp());
}

class MainApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Weather App',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: MainPage(title: 'Weather'),
  );
}

class MainPage extends StatefulWidget
{
  MainPage({required this.title, Key? key}) : super(key: key);

  @override
  MainPageState createState() => MainPageState();

  final String title;
}

class MainPageState extends State<MainPage>
{
  int currentIndex = 0;
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('This Week'),
      centerTitle: true,
    ),
    body: WeatherScreen(),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(context, SettingsPage());
      },
      child: Icon(Icons.add),
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

class WeatherList extends StatelessWidget {
  final List<WeatherInfo> weatherList;

  const WeatherList({Key? key, required this.weatherList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: weatherList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5 / 1.8,
      ),
      itemBuilder: (context, index) {
        return Text('so far it works');
      },
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
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.lightGreen,
            child: Text('Retry', style: TextStyle(color: Colors.white)),
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
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends MaterialPageRoute<Null>
{
  SettingsPage() : super(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
        children: [
          DropDownSettingsTile(
            title: 'Measure',
            settingKey: tempStandard,
            selected: 1,
            values: <int, String>{
              1: 'Celsius',
              2: 'Farenheit',
              3: 'Kelvin',
            },
            onChange: (standard) {},
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
class CitiesPage extends MaterialPageRoute<Null>
{
  CitiesPage() : super(builder: (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text('Edit Cities'),
        centerTitle: true,
      ),
      body: Center(
      ),
    );
  });
}

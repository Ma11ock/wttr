import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

late final DateTime appStart;

void main()
{
  // Init.
  appStart = new DateTime.now();
  runApp(MainApp());
}

class MainApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Weather App',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: MainPage(title: 'Forecast')
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
    body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: createWeatherBoxes(),
    ),
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

List<Widget> createWeatherBoxes()
{
    return [];
}
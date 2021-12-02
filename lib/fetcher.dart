import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sprintf/sprintf.dart';
import 'package:http/http.dart' as http;

// Weather app key.
const String WTTR_KEY = '1473cbe9b65e8b1d60d7b15f1614607a';
// City name
const String RQST_STR1 = 'https://api.openweathermap.org/data/2.5/weather?q=%s&appid=%s';
// City name, state
const String RQST_STR2 = 'https://api.openweathermap.org/data/2.5/weather?q=%s,%s&appid=%s';
// City name, state, country code
const String RQST_STR3 = 'https://api.openweathermap.org/data/2.5/weather?q=%s,%s,%s&appid=%s';

class ApiBaseHelper
{


// Get weather data.
Future<dynamic> get() async
{
    var responseJson;
    try {
      final response = await http.get(
          Uri.parse(sprintf(RQST_STR1, ['Corvallis', WTTR_KEY])));
      responseJson = _getWeatherList(response);
    }
    on SocketException
    {
      throw FetchDataException("No internet connection");
    }

  return responseJson;
}

dynamic _getWeatherList(http.Response response)
{
  switch(response.statusCode)
  {
    case 200:
      return jsonDecode(response.body);
      break;
    case 400:
      throw BadRequestException(response.body.toString());
      break;
    case 401:
    case 403:
      throw UnauthorisedException(response.body.toString());
      break;
    case 429:
      throw UnauthorisedException('429: ${response.body.toString()}');
      break;
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
      break;
  }
}
}

class WeatherResponse
{
  late int totalResults;
  late List<WeatherInfo> results;

  WeatherResponse.fromJson(Map<String, dynamic> json)
  {
    totalResults = 1;
    results = <WeatherInfo>[];
    results.add(WeatherInfo.fromJson(json));
  }
}

class WeatherInfo
{
  late double long;
  late double lat;
  late String main;
  late String descr;
  late double temp;
  late double feelsLike;
  late int pressure;
  late int humidity;
  late double tempMin;
  late double tempMax;
  late double windSpeed;
  late int windDeg;
  double? rain1h;
  double? rain3h;
  late int clouds;
  late DateTime dt;
  late String cityName;


  WeatherInfo.fromJson(Map<String, dynamic> json)
  {
    print(json);
    long = json['coord']['lon'];
    lat = json['coord']['lat'];
    main = json['weather'][0]['main'];
    descr = json['weather'][0]['description'];
    temp = json['main']['temp'];
    feelsLike = json['main']['feels_like'];
    pressure = json['main']['pressure'];
    print("Not yet");
    humidity = json['main']['humidity'];
    tempMin = json['main']['temp_min'];
    tempMax = json['main']['temp_max'];
    windSpeed = json['wind']['speed'];
    print("Here");
    windDeg = json['wind']['deg'];
    if(json['rain'] != null)
    {
      rain1h = json['rain']['1h'];
      rain3h = json['rain']['3h'];
    }
    clouds = json['clouds']['all'];
    dt = DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000);
    print('Got weather information for time $dt');
    cityName = json['name'];
    print("Done");
  }

}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class ApiResponse<T>
{
  late Status status;
  late T data;
  late String message;

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString()
  {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { LOADING, COMPLETED, ERROR }

class WeatherRepository
{
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<WeatherInfo>> fetchWeatherList() async {
    final response = await _helper.get();
    return WeatherResponse.fromJson(response).results;
  }
}

class WeatherBloc
{
  WeatherRepository? _weatherRepository;

  final StreamController<ApiResponse<List<WeatherInfo>>> _weatherListController = StreamController<ApiResponse<List<WeatherInfo>>>();

  StreamSink<ApiResponse<List<WeatherInfo>>> get weatherListSink =>
      _weatherListController.sink;

  Stream<ApiResponse<List<WeatherInfo>>> get weatherListStream =>
      _weatherListController.stream;

  WeatherBloc(List<String> cities)
  {
    _weatherRepository = WeatherRepository();
    fetchWeatherList(cities);
  }

  fetchWeatherList(List<String> cities) async
  {
    weatherListSink.add(ApiResponse.loading('Fetching Weather'));
    try {
      List<WeatherInfo> weathers = [];
      for(String s in cities)
      {
        weathers += await _weatherRepository!.fetchWeatherList();
      }
      weatherListSink.add(ApiResponse.completed(weathers));
    } catch (e) {
      weatherListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose()
  {
    _weatherListController.close();
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}
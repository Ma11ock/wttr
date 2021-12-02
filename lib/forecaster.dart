

import 'package:flutter/cupertino.dart';
import 'fetcher.dart';

class DayForecastWidget extends Widget
{
    @override
    Widget build(BuildContext context)
    {
      return FutureBuilder<String>(
        future: fetchWeatherData(),
        builder: (context, snapshot)
        {
          return Container();
        },
      );
    }

  @override
  Element createElement() {
    // TODO: implement createElement
    throw UnimplementedError();
  }
}

class LongTermForecast
{
  late DateTime lastTime;

  LongTermForecast()
  {
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chirag',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController cityController = TextEditingController();
  String cityName = '';
  Weather? weather;

  void fetchWeatherData(String city) async {
    final apiKey = '37f5eaac8d6bd4b56ed3fef9c3b10986';
    final apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        final jsonResponse = jsonDecode(response.body);
        weather = Weather.fromJson(jsonResponse);
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Weather'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: EdgeInsets.symmetric(horizontal: 25),
                child: TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'Enter city name',
                    border: OutlineInputBorder(
                      // Add border here
                      borderRadius: BorderRadius.circular(
                          8.0), // Customize border radius if needed
                      borderSide: BorderSide(), // Add side border if needed
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    cityName = cityController.text;
                  });
                  fetchWeatherData(cityName);
                },
                child: Text('Get Weather'),
              ),
              SizedBox(height: 20),
              if (weather != null)
                WeatherInfo(weather: weather!)
              else
                Text('Enter a city name and press "Get Weather"'),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final Weather weather;

  WeatherInfo({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          'http://openweathermap.org/img/wn/${weather.icon}.png',
          scale: 0.3,
        ),
        SizedBox(height: 20),
        Text(
          'Current Weather in ${weather.cityName}',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temperature: ${weather.temperature.toStringAsFixed(2)}°C',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Weather: ${weather.weatherDescription}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Humidity: ${weather.humidity}%',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Wind Speed: ${weather.windSpeed} m/s',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class Weather {
  final String cityName;
  final double temperature;
  final String weatherDescription;
  final int humidity;
  final double windSpeed;
  final String icon;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.weatherDescription,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature:
          json['main']['temp'].toDouble() - 273.15, // Kelvin to Celsius
      weatherDescription: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'],
      icon: json['weather'][0]['icon'],
    );
  }
}

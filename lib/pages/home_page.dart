import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/data/cities.dart';
import 'package:flutter_application/data/repositories/weather_repository.dart';
import 'package:http_interceptor/http_interceptor.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WeatherRepository repository = WeatherRepository(InterceptedClient.build(
      interceptors: [WeatherApiInterceptor(), LoggerInterceptor()]));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: WeatherSearch(repository));
              },
              icon: Icon(Icons.search)),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Icon(
              Icons.wb_sunny,
              size: 64,
              color: Colors.grey,
            ),
            Container(
              height: 16,
            ),
            Text(
              "Search for a city",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

class WeatherSearch extends SearchDelegate<String?> {
  int selected = -1;
  WeatherRepository repo;

  WeatherSearch(this.repo);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            selected = -1;
            query = "";
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ));
  }

  @override
  Widget buildResults(BuildContext context) {
    final city = selected == -1 ? null : cities[selected];

    return city != null ? buildWeatherCard(city) : buildEmptyCard();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? cities
        : cities.where((p) => p["country"].toString().startsWith(query)).toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              selected = index;
              query = cities[selected]["country"].toString();
              showResults(context);
            },
            title: Text(suggestionList[index]['name'].toString()),
            subtitle: Text(suggestionList[index]['country'].toString()),
          );
        });
  }

  Widget buildWeatherCard(final city) {
    return FutureBuilder<Map<String, dynamic>>(
      future: repo.fetchCityWeather(city["id"]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final weather = snapshot.data;
        final iconWeather = weather!["weather"][0]["icon"];
        final main = weather["main"];
        final wind = weather["wind"];
        return Card(
          margin: EdgeInsets.all(16.0),
          child: Container(
            width: Size.infinite.width,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Tooltip(
                    child: Image.network(
                        "https://openweathermap.org/img/w/$iconWeather.png"),
                    message: weather["weather"][0]["main"],
                  ),
                  title: Text(city["name"]),
                  subtitle: Text(city["country"]),
                ),
                ListTile(
                  title: Text("${main["temp"]} °C"),
                  subtitle: Text("Temperature"),
                ),
                ListTile(
                  title: Text("${main["temp_min"]} °C"),
                  subtitle: Text("Min Temperature"),
                ),
                ListTile(
                  title: Text("${main["temp_max"]} °C"),
                  subtitle: Text("Max Temperature"),
                ),
                ListTile(
                  title: Text("${main["humidity"]} °C"),
                  subtitle: Text("Humidity"),
                ),
                ListTile(
                  title: Text("${main["pressure"]} °C"),
                  subtitle: Text("Pressure"),
                ),
                ListTile(
                  title: Text("${main["speed"]} m/s"),
                  subtitle: Text("Wind Speed"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildEmptyCard() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.wb_sunny,
            size: 64,
            color: Colors.grey,
          ),
          Container(
            height: 16,
          ),
          Text(
            "Search for a city",
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24.0),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_application/data/credentials.dart';
import 'package:http_interceptor/http/http.dart';
import 'package:dio/dio.dart';
import 'package:http_interceptor/http_interceptor.dart';

const baseUrl = "https://api.openweathermap.org/data/2.5";

class WeatherRepository {
  InterceptedClient client;

  WeatherRepository(this.client);

  Future<Map<String, dynamic>> fetchCityWeather(int? id) async {
    var parsedWeather;
    try {
      final response =
          await client.get("$baseUrl/weather".toUri(), params: {'id': "$id"});
      if (response.statusCode == 200) {
        parsedWeather = json.decode(response.body);
      } else {
        return Future.error(
            "Error while fetching", StackTrace.fromString("${response.body}"));
      }
    } on SocketException {
      return Future.error("No Internet connection");
    } on FormatException {
      return Future.error("Bad response format");
    } on Exception catch (error) {
      print(error);
      return Future.error("Unexpected eeroor");
    }
    return parsedWeather;
  }
}

class LoggerInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print("----- Request -----");
    print(data.toString());
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print("----- Response -----");
    print(data.toString());
    return data;
  }
}

class WeatherApiInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    try {
      data.params['appid'] = OPEN_WEATHER_API_KEY;
      data.params['units'] = 'metric';
      data.headers[HttpHeaders.contentTypeHeader] = "application/json";
    } catch (e) {
      print(e);
    }
    print(data.params);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async =>
      data;
}

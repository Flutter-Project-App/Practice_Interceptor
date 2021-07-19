import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(Icons.search))
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Icon(Icons.wb_sunny, size: 64, color: Colors.grey,),
            Container(
              height: 16,
            )
          ],
        ),
      ),
    );
  }
}

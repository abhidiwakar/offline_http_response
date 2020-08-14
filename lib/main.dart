import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:httpresponsecache/database/database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTTP Cache',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'HTTP Cache'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data = '';
  DatabaseHelper _databaseHelper = DatabaseHelper();
  _getData() {
    Future.delayed(Duration(seconds: 5), () async {
      try {
        data = '';
        if (mounted) {
          setState(() {});
        }
        var response = await get('https://jsonplaceholder.typicode.com/posts');
        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);
          var dbData = await _databaseHelper.getAllValues();
          Map<String, dynamic> dd;

          for (var i = 0; i < dbData.length; i++) {
            if (dbData[i][DatabaseHelper().colScreen] == 'homepage') {
              dd = dbData[i];
              break;
            }
          }

          if (dd != null && dd.isNotEmpty) {
            if (dd['response'].toString() != body.toString()) {
              await _databaseHelper.updateData('homepage', body.toString());
              print('Updating response');
            } else {
              print('Same Response Received...');
            }
          } else {
            print(
              await _databaseHelper.insertData(
                'homepage',
                body.toString(),
              ),
            );
            print('Inserting response');
          }

          data = body.toString();
          if (mounted) {
            setState(() {});
          }
        } else {
          print('Failed to receive any response...');
        }
      } on SocketException {
        print(
            'Socket Exception Occurred... Retreiving offline saved response!');
        print('You are offline! Some features might not work...');
        try {
          var offlineResponse =
              await _databaseHelper.getScreenResponse('homepage');
          if (offlineResponse != null) {
            data = offlineResponse[0][DatabaseHelper().colResponse].toString();
            print(data);
            if (mounted) {
              setState(() {});
            }
          } else {
            print('No offline data available...');
          }
        } catch (e) {
          print(e.toString());
        }
      } catch (e) {
        print(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Text(data),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getData,
        child: Icon(Icons.call_made),
      ),
    );
  }
}

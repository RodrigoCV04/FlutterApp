import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomepageState();
}


class _HomepageState extends State<HomePage> {
  bool share_location = false;
  late Timer _timer;
  

  //Function
  Future<void>POSTRequest(String id, String lat, String long) async {
    final url = Uri.parse('https://insys.live/api/tracer/');

    final Map<String, dynamic> Data = {
      'id' : id,
      'latitud' : lat,
      'longitud' : long
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type' : 'application/json',
      },
      body: jsonEncode(Data)
    );

    print('${Data}');

    if(response.statusCode == 200){
      if(response.body.isNotEmpty){
        var response_body = jsonDecode(response.body);
        print('Respuesta: $response_body');
      }else print('No hay respuesta');
    }else{
      print('Error en la solicitud: ${response.statusCode}');
    }
  }



  Future<bool> GetPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) return false;
    }
    share_location = true;
    return true;
  }


  Future<Position> GetCoordenates() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) return Future.error('error');
    share_location = true;
    return await Geolocator.getCurrentPosition();
  }


  void SharePosition() async {
    if(await GetPermission()){
        Position position = await GetCoordenates();
        POSTRequest('3', position.latitude.toString(), position.longitude.toString());
        //print(position.latitude); //En grados decimales
        //print(position.longitude);
        _timer = Timer.periodic(Duration(seconds: 30), (_timer) async  {
          position = await GetCoordenates();
          POSTRequest('3', position.latitude.toString(), position.longitude.toString());
          //print(position.latitude +1);
          //print(position.longitude +1);
      });
    }
  }

  void StopSharing(){
    _timer.cancel();
    print("stop sharing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geolocator App'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            if(!share_location) SharePosition(); else StopSharing();
          },
          child: const Text('Send data')),
      ),
    );
  }
}
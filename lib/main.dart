import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup name ideas',
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tinder! (But better)',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.grey,
        ),
        body: const Center(
          child: Jokes(),
        ),
      ),
    );
  }
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class Jokes extends StatefulWidget {
  const Jokes({Key? key}) : super(key: key);

  @override
  State<Jokes> createState() => _JokesState();
}

class _JokesState extends State<Jokes> {
  Future<Map<String, Object?>> getData(String url) async {
    var result = await http.get(Uri.parse(url));
    return jsonDecode(result.body) as Map<String, Object?>;
  }

  String joke = "noJoke";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
              child: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dx > 0) {
                setState(() {
                  getData('https://api.chucknorris.io/jokes/random')
                      .then((value) {
                    joke = value["value"].toString();
                  });
                });
              }
              if (details.delta.dx < 0) {
                setState(() {
                  getData('https://api.chucknorris.io/jokes/random')
                      .then((value) {
                    joke = value["value"].toString();
                  });
                });
              }
            },
            child: Container(
                width: 350,
                height: 450,
                decoration: BoxDecoration(
                    color: Colors.grey, border: Border.all(width: 3)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          joke,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              getData('https://api.chucknorris.io/jokes/random')
                                  .then((value) {
                                joke = value["value"].toString();
                              });
                            });
                          },
                          icon: const Icon(Icons.favorite),
                          color: HexColor.fromHex('#ffcc00'),
                          iconSize: 60,
                        ),
                      ]),
                )),
          )),
        ),
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            backgroundColor: Colors.grey,
            child: const Icon(
              Icons.account_circle,
              size: 35.0,
              color: Color.fromRGBO(255, 204, 0, 1),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'Personal Information:',
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(
                        width: 400,
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text('Full Name: Abdulayev Damir'),
                            const Text('Date of birth: 30/09/2003'),
                            const Text(
                                'Email: d.abdulayev@innopolis.university'),
                            const Text('Occupation: Flutter student'),
                            Image.network(
                              'https://sun9-east.userapi.com/sun9-41/s/v1/ig2/rWNeo2aCPcz4S_YeoZErICSuVcnFBSImYfVGb7o-NyseGop6MVwPhLlYF6Mg-mZaj7CXkPTvm1C-b_mrcYGtjxxM.jpg?size=1440x2160&quality=95&type=album',
                              width: 100,
                              height: 100,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

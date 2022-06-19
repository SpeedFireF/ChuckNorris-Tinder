import 'dart:collection';
import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/colors.dart';
import 'firebase_options.dart';

part 'main.g.dart';

late DatabaseReference realtimedb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  realtimedb = FirebaseDatabase.instanceFor(app: app).ref('test');
  runApp(const MyApp());
}

@JsonSerializable()
class JokeJsonSerializable {
  @JsonKey(name: 'value')
  final String joke;

  JokeJsonSerializable(this.joke);

  factory JokeJsonSerializable.fromJson(Map<String, dynamic> json) =>
      _$JokeJsonSerializableFromJson(json);

  Map<String, dynamic> toJson() => _$JokeJsonSerializableToJson(this);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Norris Tinder',
      home: Jokes(),
    );
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
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title:Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Tinder! (But better)',
                  style: TextStyle(
                      color: MainColors.secondColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w400),
                ),
                IconButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const SavedJokes(),
                    ),
                  );
                }, icon: const Icon(Icons.list, color: MainColors.secondColor))
              ],
            ),

            backgroundColor: MainColors.secondPageBackGround,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: MainColors.secondColor,
                height: 2.0,
              ),
            ),
          ),
          backgroundColor: MainColors.secondPageBackGround,
          body: Center(
              child: GestureDetector(
                onPanUpdate: (details) {
                  if (details.delta.dx > 10) {
                    setState(() {
                      getData('https://api.chucknorris.io/jokes/random')
                          .then((value) {
                        var user = JokeJsonSerializable.fromJson(value);
                        joke = user.joke;
                      });
                    });
                  }
                  if (details.delta.dx < 10) {

                    setState(() {
                      getData('https://api.chucknorris.io/jokes/random')
                          .then((value) {
                        var user = JokeJsonSerializable.fromJson(value);
                        joke = user.joke;
                      });
                    });
                  }
                },
                child: Container(
                    width: 350,
                    height: 450,
                    decoration: BoxDecoration(
                        color: MainColors.mainColor,
                        border: Border.all(
                            width: 2, color: MainColors.secondColor)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              joke,
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    var data = await getData('https://api.chucknorris.io/jokes/random');
                                    var user = JokeJsonSerializable.fromJson(data);
                                    setState((){ joke = user.joke;});
                                    },
                                  icon: const Icon(Icons.favorite),
                                  color: MainColors.secondColor,
                                  iconSize: 60,
                                ),
                                IconButton(
                                  onPressed: () {
                                    realtimedb.push().set(joke);
                                  },
                                  icon: const Icon(Icons.add_circle_sharp),
                                  color: MainColors.secondColor,
                                  iconSize: 60,
                                ),
                              ],
                            )
                          ]),
                    )),
              )),
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            backgroundColor: MainColors.secondColor,
            child: const Icon(
              Icons.account_circle,
              size: 35.0,
              color: MainColors.secondPageButtonColor,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) =>
                    SafeArea(
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
        }),),
    );
  }
}

class SavedJokes extends StatefulWidget {
  const SavedJokes({Key? key}) : super(key: key);

  @override
  State<SavedJokes> createState() => _SavedJokesState();
}

class _SavedJokesState extends State<SavedJokes> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Center(
              child: Text(
                'Tinder! (But better)',
                style: TextStyle(
                    color: MainColors.secondColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w400),
              ),
            ),
            backgroundColor: MainColors.secondPageBackGround,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: MainColors.secondColor,
                height: 2.0,
              ),
            ),
          ),
          body: FutureBuilder(
            future: getFavorites(),
            builder: (context, snapshot){
              if (!snapshot.hasData){
                return const CircularProgressIndicator();
              }
              var data = snapshot.data as SplayTreeMap<String, dynamic>;
              return ListView(
                children: data.keys.map((e) {
                  return Container(
                    margin: const EdgeInsets.all(20),
                    child: Text(data[e], style: const TextStyle(fontSize: 16),),
                  );
                }).toList(),
              );
            },
          ),

        ),
    );
  }
}

Future<SplayTreeMap<String, dynamic>> getFavorites() async {
  var data = await realtimedb.get();
  return SplayTreeMap<String, dynamic>.from(data.value as Map);
}
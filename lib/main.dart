import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dreams/views/dreams_component.dart';
import 'dreams/presenter/dreams_presenter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: Firebase.initializeApp(), builder: (context, snapshot) {
      if (snapshot.hasError) {
        print("Could not connect!");
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return MaterialApp(
            home: Builder(
                builder: (context) =>
                    Scaffold(
                      //backgroundColor: Colors.blueGrey,
                      appBar: AppBar(
                        title: Text("Sweet Dreams"),
                      ),
                      body: Center(
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(top: 20.0,
                                    bottom: 20.0),
                                child: Text("Welcome and Sweet Dreams!",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                  textScaleFactor: 3,)
                                ,),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent
                                ),
                                child: Text('Sleep Calculator'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (
                                          BuildContext context) { //Navigate to second route "Sleep Calculator" when pressed.
                                        return SleepCalculatorScreen();
                                      }));
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent
                                ),
                                child: Text('Sleep Log'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return SleepLogScreen();
                                      }));
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent
                                ),
                                child: Text('Time Clock'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return TimeClockScreen();
                                      }));
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent
                                ),
                                child: Text('Settings'),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return SettingScreen();
                                      }));
                                },
                              )
                            ],
                          )
                      ),
                    )
            )
        );
      }
      Widget loading = MaterialApp();
      return loading;
    });
  }
}

class SleepCalculatorScreen extends StatefulWidget {
  @override
  _SleepCalculatorScreen createState() => _SleepCalculatorScreen();
}

class _SleepCalculatorScreen extends State<SleepCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return new HomePage(
      new SleepCalculatorPresenter(), title: 'Sweet Dreams', key: Key("UNITS"),);
  }
}

  class SleepLogScreen extends StatefulWidget {
    @override
  _SleepLogScreen createState() => _SleepLogScreen();
  }

  class _SleepLogScreen extends State<SleepLogScreen> {
  @override
    Widget build(BuildContext context) {
    return new SleepLogPage(
      new SleepLogPresenter(), title: 'Sleep Log', key: Key("LOGS"),);
  }
}

class TimeClockScreen extends StatefulWidget {
  @override
  _TimeClockScreen createState() => _TimeClockScreen();
}

class _TimeClockScreen extends State<TimeClockScreen> {
  @override
  Widget build(BuildContext context) {
    return new TimeClockPage(
    new TimeClockPresenter(), title: 'Time Clock', key: Key("LOGS"),);
  }
}

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreen createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return new SettingPage(
      new SettingPresenter(), title: 'Settings', key: Key("LOGS"),);
  }
}

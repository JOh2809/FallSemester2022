import 'package:flutter/material.dart';

import 'dreams/views/dreams_component.dart';
import 'dreams/presenter/dreams_presenter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text("Sweet Dreams"),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Text("Sweet Dreams!",style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent), textScaleFactor: 3,)
                  ,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent
                  ),
                  child: Text('Sleep Calculator'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) { //Navigate to second route "Sleep Calculator" when pressed.
                      return SleepCalculatorScreen();
                    }));
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent
                  ),
                  child: Text('Sleep Log'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
                      return SleepLogScreen();
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



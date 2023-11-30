import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../dreams/presenter/dreams_presenter.dart';
import '../dreams/views/dreams_component.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Auth_page.dart';
import 'Loginpage.dart';
import 'package:google_sign_in/google_sign_in.dart';

void signUserOut(){
  FirebaseAuth.instance.signOut();
}

class HomePage extends StatefulWidget {

  final Key? key;
  final String title;
  HomePage(SleepCalculatorPresenter sleepCalculatorPresenter, {this.key, required this.title});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Could not connect!");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return DynamicHomePage();
        } else {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
class DynamicHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: signUserOut,
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          backgroundColor: Colors.purpleAccent.withOpacity(0.9),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background-sweet-dreams.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Text(
                    "Welcome ${user?.displayName ?? 'User'} and Sweet Dreams!",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textScaleFactor: 3,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Sleep Calculator'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SleepCalculatorScreen();
                      },
                    ));
                  },
                ),

                /*
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Yotube'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return YouTubeScreen();
                      },
                    ));
                  },
                ),
                 */
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Sleep Log'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SleepLogScreen();
                      },
                    ));
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Sleep Diary'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SleepDiaryScreen();
                      },
                    ));
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Sleep Music'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SleepMusicScreen();
                      },
                    ));
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Time Clock'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return TimeClockScreen();
                      },
                    ));
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Sleep Info'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SleepInfoScreen();
                      },
                    ));
                  },
                ),
                SizedBox(height: 10.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withOpacity(0.4),
                  ),
                  child: Text('Settings'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SettingScreen();
                      },
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
    return new SleepCalculatorPage(
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

class SleepDiaryScreen extends StatefulWidget {
  @override _SleepDiaryScreen createState() => _SleepDiaryScreen();
}

class _SleepDiaryScreen extends State<SleepDiaryScreen> {
  @override
  Widget build(BuildContext context) {
    return new SleepDiaryPage(
      new SleepDiaryPresenter(), title: 'Sleep Diary', key: Key("DIARIES"),);
  }
}

class SleepMusicScreen extends StatefulWidget {
  @override _SleepMusicScreen createState() => _SleepMusicScreen();
}

class _SleepMusicScreen extends State<SleepMusicScreen> {
  @override
  Widget build(BuildContext context) {
    return new SleepMusicPage(
      new SleepMusicPresenter(), title: 'Sleep Music', key: Key("MUSIC"),);
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

class SleepInfoScreen extends StatefulWidget {
  @override
  _SleepInfoScreen createState() => _SleepInfoScreen();
}

class _SleepInfoScreen extends State<SleepInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return new SleepInfoPage(
      new SleepInfoPresenter(), title: 'Sleep Info', key: Key("LOGS"),);
  }
}


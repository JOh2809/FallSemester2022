import 'dart:core';
import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../views/dreams_view.dart';
import '../presenter/dreams_presenter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'VideoPlayer.dart';
import 'package:intl/intl.dart';

class SleepCalculatorPage extends StatefulWidget {
  final UNITSPresenter presenter;

  SleepCalculatorPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _SleepCalculatorPageState createState() => _SleepCalculatorPageState();
}

class _SleepCalculatorPageState extends State<SleepCalculatorPage> implements UNITSView {

  var _sleepHourController = TextEditingController();
  var _sleepMinuteController = TextEditingController();
  var _hourController = TextEditingController();
  var _minuteController = TextEditingController();
  String _hour = "0.0";
  String _minute = "0.0";
  String _sleepMinute = "0.0";
  String _sleepHour = "0.0";
  var _resultString = '';
  var _timeString = '';
  var _message = '';
  var _messageTwo = '';
  var _value = 0;
  var _valueTime = 0;
  final FocusNode _hourFocus = FocusNode(); // The hour the user want's to wake up at
  final FocusNode _sleepHourFocus = FocusNode(); // The number of hours the user want's to sleep for
  final FocusNode _sleepMinuteFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();

  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this.widget.presenter.unitsView = this;
  }

  void handleRadioValueChanged(int? value) {
    this.widget.presenter.onOptionChanged(value!, sleepHourString: _sleepHour, sleepMinuteString: _sleepMinute );
  }
  void handleRadioValueChangedTime(int? value) {
    this.widget.presenter.onTimeOptionChanged(value!);
  }

  void _calculator() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      this.widget.presenter.onCalculateClicked(_hour, _minute, _sleepMinute, _sleepHour);
    }
  }

  @override
  void updateResultValue(String resultValue){
    setState(() {
      _resultString = resultValue;
    });
  }
  @override
  void updateTimeString(String timeString){
    setState(() {
      _timeString = timeString;
    });
  }
  @override
  void updateMessage(String message){
    setState(() {
      _message = message;
    });
  }
  @override
  void updateMessageTwo(String messageTwo) {
    setState(() {
      _messageTwo = messageTwo;
    });
  }
  @override
  void updateSleepMinute({required String sleepMinute}){
    setState(() {
      // ignore: unnecessary_null_comparison
      _sleepMinuteController.text = sleepMinute != null?sleepMinute:'';
    });
  }
  @override
  void updateSleepHour({required String sleepHour}){
    setState(() {
      // ignore: unnecessary_null_comparison
      _sleepHourController.text = sleepHour != null?sleepHour:'';
    });
  }
  @override
  void updateHour({required String hour}) {
    setState(() {
      _hourController.text = hour != null ? hour : '';
    });
  }
  @override
  void updateMinute({required String minute}) {
    setState(() {
      _minuteController.text = minute != null ? minute : '';
    });
  }
  @override
  void updateUnit(int value){
    setState(() {
      _value = value;
    });
  }
  @override
  void updateTimeUnit(int value){
    setState(() {
      _valueTime = value;
    });
  }

  @override
  Widget build(BuildContext context) {

    var _unitView = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio<int>(
          activeColor: Colors.blueAccent.shade700,
          value: 0, groupValue: _value, onChanged: handleRadioValueChanged,
        ),
        Text(
          'Wake up at',
          style: TextStyle(color: Colors.blueAccent.shade700),
        ),
        Radio<int>(
          activeColor: Colors.blueAccent.shade700,
          value: 1, groupValue: _value, onChanged: handleRadioValueChanged,
        ),
        Text(
          'Go to bed at',
          style: TextStyle(color: Colors.blueAccent.shade700),
        ),
      ],
    );

    var _unitViewTime = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio<int>(
          activeColor: Colors.blueAccent.shade700,
          value: 0, groupValue: _valueTime, onChanged: handleRadioValueChangedTime,
        ),
        Text(
          'AM',
          style: TextStyle(color: Colors.blueAccent.shade700),
        ),
        Radio<int>(
          activeColor: Colors.blueAccent.shade700,
          value: 1, groupValue: _valueTime, onChanged: handleRadioValueChangedTime,
        ),
        Text(
          'PM',
          style: TextStyle(color: Colors.blueAccent.shade700),
        ),
      ],
    );

    var _mainPartView = Container(
      color: Colors.blue.shade200,
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text("I want to:",style: const TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1.5,)
                ,),
              _unitView,
              Row(
                children: <Widget>[
                  Expanded(
                    child: hourFormField(context),
                  ),
                  Expanded(
                    child: minFormField(context),
                  )
                ],
              ),
              _unitViewTime,
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text("I want to sleep for:",style: const TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1.5,)
                ,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: sleepHourFormField(context),
                  ),
                  Expanded(
                    child: sleepMinuteFormField(),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: calculateButton()
                ,),
            ],
          ),
        ),
      ),
    );

    var _resultView = Column(
      children: <Widget>[
        Center(
          child: Text(
            '$_message $_resultString $_timeString',
            style: TextStyle(
                color: Colors.blueAccent.shade700,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic
            ),
          ),
        ),
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text(
              'Sleep Calculator',
        style: TextStyle(
        color: Colors.black,)
          ),
          centerTitle: true,
          backgroundColor: Colors.greenAccent.shade700,
        ),
        backgroundColor: Colors.white,
        body: Container(
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
                fit: BoxFit.cover),
            ),
        child:                                                      ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(5.0)),
            _mainPartView,
            Padding(padding: EdgeInsets.all(5.0)),
            _resultView
          ],
        )
        )
    );
  }

  ElevatedButton calculateButton() {
    return ElevatedButton(
      onPressed: _calculator,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.withOpacity(.5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      child: Text('Calculate', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
    );
  }

  TextFormField sleepMinuteFormField() {
    return TextFormField(
      controller: _sleepMinuteController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      focusNode: _sleepMinuteFocus,
      onFieldSubmitted: (value){
        _sleepMinuteFocus.unfocus();
      },
      validator: (value) {
        if (value!.length == 0 || (double.parse(value) < 0 || double.parse(value) > 59)) {
          return ('Minute between 0 - 59');
        }
      },
      onSaved: (value) {
        _sleepMinute = value!;
      },
      decoration: InputDecoration(
          hintText: 'e.g.) 40',
          labelText: 'Minute',
          icon: Icon(Icons.assessment),
          fillColor: Colors.white
      ),
    );
  }

  TextFormField sleepHourFormField(BuildContext context) {
    return TextFormField(
      controller: _sleepHourController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      focusNode: _sleepHourFocus,
      onFieldSubmitted: (term) {
        _fieldFocusChange(context, _sleepHourFocus, _sleepMinuteFocus);
      },
      validator: (value) {
        if (value!.length == 0 || (double.parse(value) < 1 || double.parse(value) > 12)) {
          return ('Hour between 1 - 12');
        }
      },
      onSaved: (value) {
        _sleepHour = value!;
      },
      decoration: InputDecoration(
        hintText: "e.g.) 7",
        labelText: "Hour",
        icon: Icon(Icons.assessment),
        fillColor: Colors.white,
      ),
    );
  }

  TextFormField hourFormField(BuildContext context) {
    return TextFormField(
      controller: _hourController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      focusNode: _hourFocus,
      onFieldSubmitted: (term){
        _fieldFocusChange(context, _hourFocus, _minuteFocus);
      },
      validator: (value) {
        if (value!.length == 0 || (double.parse(value) < 1 || double.parse(value) > 12)) {
          return ('Hour between 1 - 12');
        }
      },
      onSaved: (value) {
        _hour = value!;
      },
      decoration: InputDecoration(
        hintText: 'e.g.) 6',
        labelText: 'Hour',
        icon: Icon(Icons.assessment),
        fillColor: Colors.white,
      ),
    );
  }

  TextFormField minFormField(BuildContext context) {
    return TextFormField(
      controller: _minuteController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      focusNode: _minuteFocus,
      onFieldSubmitted: (term){
        _fieldFocusChange(context, _minuteFocus, _sleepHourFocus);
      },
      validator: (value) {
        if (value!.length == 0 || (double.parse(value) < 0 || double.parse(value) > 59)) {
          return ('Minute between 0 - 59');
        }
      },
      onSaved: (value) {
        _minute = value!;
      },
      decoration: InputDecoration(
        hintText: 'e.g.) 30',
        labelText: 'Minute',
        icon: Icon(Icons.assessment),
        fillColor: Colors.white,
      ),
    );
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}

class SleepLogPage extends StatefulWidget {
  final SleepLogPresenter presenter;

  SleepLogPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SleepLogPageState createState() => _SleepLogPageState(presenter);
}

class _SleepLogPageState extends State<SleepLogPage> implements UNITSView {
  final firestore = FirebaseFirestore.instance;
  final SleepLogPresenter presenter;
  _SleepLogPageState(this.presenter);
  List _sleepHoursList = [];
  List _sleepQualityList = [];
  final FocusNode _qualityRatingFocus = FocusNode();
  final FocusNode _hoursSleptFocus = FocusNode();
  final FocusNode _timesNappedFocus = FocusNode();
  final FocusNode _timeFellAsleepFocus = FocusNode();
  var _qualityRatingController = TextEditingController();
  var _hoursSleptController = TextEditingController();
  var _timesNappedController = TextEditingController();
  var _timeFellAsleepController = TextEditingController();
  var _resultString = '';
  var _resultString2 = '';
  var _message = '';
  DateTime Date = DateTime.now();
  String _qualityRating = "0";
  String _hoursSlept = "0.0";
  String _timeFellAsleep = "0.0";
  String _timesNapped = "0";
  String _sleepLogDate = '';
  String _averageHourSlept = "0";
  String _averageSleepQuality = "0";

  var _formKey = GlobalKey<FormState>();

  Future _getSleepHourAverage() async{
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String string = dateFormat.format(DateTime.now());
    firestore.collection("Sleep Logs").where("Sleep Log Date", isLessThan: string).get().then(
          (querySnapshot) {
        print("Successfully Completed");
        for(var docSnapshot in querySnapshot.docs) {
          int hours = int.parse(docSnapshot['Hours Slept'].toString()); // pull the hours slept as an int
          print("Hours Slept: $hours");
          _sleepHoursList.add(hours);

        }
        setState(() {
          double mean = _sleepHoursList.reduce((a,b) => a + b) / _sleepHoursList.length;
          _averageHourSlept = mean.toStringAsFixed(3); // Limits the length of the average to something more palatable
          _resultString = _averageHourSlept;
          _sleepHoursList.clear();
        });
      },
      onError: (e) => print("Error completing: $e"),
    );
    return _averageHourSlept;
  }

  Future _getSleepQualityAverage() async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    double mean = 0.0;
    int sum = 0;
    String string = dateFormat.format(DateTime.now());
    firestore.collection("Sleep Logs").where("Sleep Log Date", isLessThan: string).get().then(
          (querySnapshot) {
        print("Successfully Completed");
        for(var docSnapshot in querySnapshot.docs) {
          int sleepQuality = int.parse(docSnapshot['Quality Rating'].toString()); // pull the hours slept as an int
          print("Sleep quality: $sleepQuality");
          _sleepQualityList.add(sleepQuality);

        }
        setState(() {
          sum = _sleepQualityList.reduce((a,b) => a + b);
          print("Sum = $sum");
          mean =  sum / _sleepQualityList.length;
          _averageSleepQuality = mean.toStringAsFixed(3);
          _resultString2 = _averageSleepQuality;
          _sleepQualityList.clear();
        });

          },
      onError: (e) => print("Error completing: $e"),
    );
    return _averageSleepQuality;
  }

  @override
  void initState() {
    super.initState();
    this.widget.presenter.unitsView = this;

  }

  void _recorder() {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      this.widget.presenter.onRecordClicked( _hoursSlept ,_qualityRating);
    }
     _sleepLogDate = '$Date';
    presenter.createLog(_sleepLogDate, _hoursSlept, _qualityRating, _timesNapped, _timeFellAsleep);
  }

  @override
  void updateResultValue(String resultValue){
    setState(() {
      print("Average Hours Slept = $_averageHourSlept");
      _getSleepHourAverage();
      resultValue = _averageHourSlept;
      _resultString = resultValue;
      print("Average Sleep Quality = $_averageSleepQuality");
      _getSleepQualityAverage();
      resultValue = _averageSleepQuality;
      _resultString2 = resultValue;
    });
  }


  @override
  void updateResultValue2(String resultValue2){
    setState(() {
      print("Average Sleep Quality = $_averageSleepQuality");
      _getSleepQualityAverage();
      resultValue2 = _averageSleepQuality;
      _resultString2 = resultValue2;
      print("Average Sleep Quality = $_averageSleepQuality");

    });
  }

  @override
  void updateMessage(String message){
    setState(() {
      _message = message;
    });
  }
  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {

    var _dreamTypeView = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio<int>(
          activeColor: Colors.blueAccent.shade700,
          value: 0, groupValue: null, onChanged: null,
        ),
        Text(
          'Dream',
          style: TextStyle(color: Colors.blueAccent.shade700, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Radio<int>(
          activeColor: Colors.blueAccent.shade700,
          value: 1, groupValue: null, onChanged: null,
        ),
        Text(
          'Nightmare',
          style: TextStyle(color: Colors.blueAccent.shade700, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );

    TextFormField qualityRatingField(BuildContext context) {
      return TextFormField(
        controller: _qualityRatingController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        focusNode: _qualityRatingFocus,
        onFieldSubmitted: (value){
          _qualityRatingFocus.unfocus();
        },
        validator: (value) {
          if (value!.length == 0 || (double.parse(value) < 1 || double.parse(value) > 10)) {
            return ('Rate the quality of your sleep between 1 - 10');
          }
        },
        onSaved: (value) {
          _qualityRating = value!;
        },
        decoration: InputDecoration (
          hintText: 'e.g.) 9',
          labelText: 'From 1 - 10, rate the quality of your sleep',
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
                Icons.scale,
                size: 30.0,
            ),
          fillColor: Colors.blueAccent
        ),
      );
    }

    TextFormField hoursSleptField(BuildContext context) { //Hours slept
      return TextFormField(
        controller: _hoursSleptController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: _hoursSleptFocus,
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _hoursSleptFocus, _qualityRatingFocus);
        },
        validator: (value) {
          if (value!.length == 0 || (double.parse(value) < 0 || double.parse(value) > 24)) {
            return ('Hour between 0 - 24');
          }
        },
        onSaved: (value) {
          _hoursSlept = value!;
        },
        decoration: InputDecoration(
          hintText: 'e.g.) 8',
          labelText: 'How long did you sleep for?',
          labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          icon: Icon(
              Icons.timer,
              size: 30.0,
          ),
          fillColor: Colors.white,
        ),
      );
    }

    TextFormField timesNappedField(BuildContext context) { //Hours slept
      return TextFormField(
        controller: _timesNappedController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: _timesNappedFocus,
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _hoursSleptFocus, _qualityRatingFocus);
        },
        onSaved: (value) {
          _timesNapped = value!;
        },
        decoration: InputDecoration(
          hintText: 'e.g.) 8',
          labelText: 'How many times did you nap\ntoday, if at all?',
          labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          icon: Icon(
            Icons.numbers_sharp,
            size: 30.0,
          ),
          fillColor: Colors.white,
        ),
      );
    }

    TextFormField timeFellAsleepField(BuildContext context) { //Hours slept
      return TextFormField(
        controller: _timeFellAsleepController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: _timeFellAsleepFocus,
        onFieldSubmitted: (term) {
          _fieldFocusChange(context, _hoursSleptFocus, _qualityRatingFocus);
        },
        onSaved: (value) {
          _timeFellAsleep = value!;
        },
        decoration: InputDecoration(
          hintText: 'e.g.) 8',
          labelText: 'How long did it take you to\nfall asleep?',
          labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          icon: Icon(
            Icons.punch_clock,
            size: 30.0,
          ),
          fillColor: Colors.white,
        ),
      );
    }

    var _sleepLogView = Container(
      color: Colors.lightBlueAccent.withOpacity(0.9),
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              hoursSleptField(context),
              qualityRatingField(context),
              //timesNappedField(context),
              //timeFellAsleepField(context),
              /*Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text("Did you have a dream or a nightmare?",style: const TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 1.5,)
                ,),
              _dreamTypeView,
*/
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: recordButton(),
              ),
            ],
          ),
        ),
      ),
    );

    var _sleepLogResultView = Column(
      children: <Widget>[
        Center(
          child: Text(
            'The average amount of sleep you get (in hours) is: $_resultString\n\n'
                'The average quality of the sleep (1 being low quality, 10 being high quality) you get is: $_resultString2',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Log',
            style: TextStyle(
              color: Colors.black,)),
      ),
    body: Container(
    decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
    fit: BoxFit.cover),
    ),
      child: ListView(
          children: <Widget>[
              _sleepLogView,
            _sleepLogResultView,
            ],
          ),
      )
    );
  }

  ElevatedButton recordButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.withOpacity(.5),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      onPressed: _recorder,
      icon: Icon( // <-- Icon
        Icons.cloud,
        size: 30.0,
      ),
      label: Text('Record Sleep Data', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
    );
  }


  @override
  void updateHour({required String hour}) {
    // TODO: implement updateHour
  }

  @override
  void updateMinute({required String minute}) {
    // TODO: implement updateMinute
  }

  @override
  void updateSleepHour({required String sleepHour}) {
    // TODO: implement updateSleepHour
  }

  @override
  void updateSleepMinute({required String sleepMinute}) {
    // TODO: implement updateSleepMinute
  }

  @override
  void updateTimeString(String timeString) {
    // TODO: implement updateTimeString
  }

  @override
  void updateTimeUnit(int value) {
    // TODO: implement updateTimeUnit
  }

  @override
  void updateUnit(int value) {
    // TODO: implement updateUnit
  }
}
class SleepDiaryPage extends StatefulWidget {
  final SleepDiaryPresenter presenter;

  SleepDiaryPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SleepDiaryPageState createState() => _SleepDiaryPageState(presenter);
}

class _SleepDiaryPageState extends State<SleepDiaryPage> {
  final SleepDiaryPresenter presenter;
  _SleepDiaryPageState(this.presenter);
  final FocusNode _diaryEntryOneFocus = FocusNode();
  final FocusNode _diaryEntryTwoFocus = FocusNode();
  final FocusNode _diaryEntryThreeFocus = FocusNode();
  final FocusNode _diaryEntryFourFocus = FocusNode();
  final FocusNode _diaryEntryFiveFocus = FocusNode();
  final FocusNode _behaviorEntryOneFocus = FocusNode();
  final FocusNode _behaviorEntryTwoFocus = FocusNode();
  final FocusNode _behaviorEntryThreeFocus = FocusNode();
  final FocusNode _behaviorEntryFourFocus = FocusNode();
  final FocusNode _behaviorEntryFiveFocus = FocusNode();
  var _diaryEntryOneController = TextEditingController();
  var _diaryEntryTwoController = TextEditingController();
  var _diaryEntryThreeController = TextEditingController();
  var _diaryEntryFourController = TextEditingController();
  var _diaryEntryFiveController = TextEditingController();
  var _behaviorEntryOneController = TextEditingController();
  var _behaviorEntryTwoController = TextEditingController();
  var _behaviorEntryThreeController = TextEditingController();
  var _behaviorEntryFourController = TextEditingController();
  var _behaviorEntryFiveController = TextEditingController();
  String _diaryEntryOne = '';
  String _diaryEntryTwo = '';
  String _diaryEntryThree = '';
  String _diaryEntryFour = '';
  String _diaryEntryFive = '';
  String _behaviorEntryOne = '';
  String _behaviorEntryTwo = '';
  String _behaviorEntryThree = '';
  String _behaviorEntryFour = '';
  String _behaviorEntryFive = '';
  var _formKey = GlobalKey<FormState>();

  void _archiver() {
    _diaryEntryOne = _diaryEntryOneController.text;
    _diaryEntryTwo = _diaryEntryTwoController.text;
    _diaryEntryThree = _diaryEntryThreeController.text;
    _diaryEntryFour = _diaryEntryFourController.text;
    _diaryEntryFive = _diaryEntryFiveController.text;
    _behaviorEntryOne = _behaviorEntryOneController.text;
    _behaviorEntryTwo = _behaviorEntryTwoController.text;
    _behaviorEntryThree = _behaviorEntryThreeController.text;
    _behaviorEntryFour = _behaviorEntryFourController.text;
    _behaviorEntryFive = _behaviorEntryFiveController.text;
    presenter.archiveEntries(_diaryEntryOne, _diaryEntryTwo, _diaryEntryThree, _diaryEntryFour, _diaryEntryFive,  _behaviorEntryOne, _behaviorEntryTwo, _behaviorEntryThree, _behaviorEntryFour, _behaviorEntryFive);
  }

  void _remover() {
    presenter.removeEntry();
  }

  @override
  Widget build(BuildContext context) {
    TextFormField diaryEntryOneField(BuildContext context) {
      return TextFormField(
        controller: _diaryEntryOneController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _diaryEntryOneFocus,
        onFieldSubmitted: (value) {
          _diaryEntryOneFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Diary Entry 1',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField diaryEntryTwoField(BuildContext context) {
      return TextFormField(
        controller: _diaryEntryTwoController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _diaryEntryTwoFocus,
        onFieldSubmitted: (value) {
          _diaryEntryTwoFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Diary Entry 2',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField diaryEntryThreeField(BuildContext context) {
      return TextFormField(
        controller: _diaryEntryThreeController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _diaryEntryThreeFocus,
        onFieldSubmitted: (value) {
          _diaryEntryThreeFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Diary Entry 3',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField diaryEntryFourField(BuildContext context) {
      return TextFormField(
        controller: _diaryEntryFourController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _diaryEntryFourFocus,
        onFieldSubmitted: (value) {
          _diaryEntryFourFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Diary Entry 4',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField diaryEntryFiveField(BuildContext context) {
      return TextFormField(
        controller: _diaryEntryFiveController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _diaryEntryFiveFocus,
        onFieldSubmitted: (value) {
          _diaryEntryFiveFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Diary Entry 5',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField behaviorEntryOneField(BuildContext context) {
      return TextFormField(
        controller: _behaviorEntryOneController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _behaviorEntryOneFocus,
        onFieldSubmitted: (value) {
          _behaviorEntryOneFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Behavior Entry 1',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField behaviorEntryTwoField(BuildContext context) {
      return TextFormField(
        controller: _behaviorEntryTwoController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _behaviorEntryTwoFocus,
        onFieldSubmitted: (value) {
          _behaviorEntryTwoFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Behavior Entry 2',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField behaviorEntryThreeField(BuildContext context) {
      return TextFormField(
        controller: _behaviorEntryThreeController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _behaviorEntryThreeFocus,
        onFieldSubmitted: (value) {
          _behaviorEntryThreeFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Behavior Entry 3',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField behaviorEntryFourField(BuildContext context) {
      return TextFormField(
        controller: _behaviorEntryFourController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _behaviorEntryFourFocus,
        onFieldSubmitted: (value) {
          _behaviorEntryFourFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Behavior Entry 4',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    TextFormField behaviorEntryFiveField(BuildContext context) {
      return TextFormField(
        controller: _behaviorEntryFiveController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        focusNode: _behaviorEntryFiveFocus,
        onFieldSubmitted: (value) {
          _behaviorEntryFiveFocus.unfocus();
        },
        decoration: InputDecoration(
            labelText: 'Behavior Entry 5',
            border: OutlineInputBorder(),
            labelStyle: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            icon: Icon(
              Icons.book_outlined,
              size: 30.0,
            ),
            fillColor: Colors.blueAccent
        ),
        maxLines: 5,
        minLines: 1,
      );
    }

    ElevatedButton archiveButton() {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.withOpacity(.5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        onPressed: _archiver,
        icon: Icon( // <-- Icon
          Icons.download_done_outlined,
          size: 30.0,
        ),
        label: Text('Archive Diary Entries', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
      );
    }

    ElevatedButton archiveButtonTwo() {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.withOpacity(.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        onPressed: _archiver,
        icon: Icon( // <-- Icon
          Icons.download_done_outlined,
          size: 30.0,
        ),
        label: Text('Archive Behavior Entries', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
      );
    }

    ElevatedButton removeButton() {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent.shade400
        ),
        onPressed: _remover,
        icon: Icon( // <-- Icon
          Icons.download_done_outlined,
          size: 30.0,
        ),
        label: Text('Remove Diary Entry'),
      );
    }

    var _sleepDiaryView = Container(
        color: Colors.lightBlueAccent.withOpacity(0.9),
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                diaryEntryOneField(context),
                SizedBox(height: 15,),
                behaviorEntryOneField(context),
                SizedBox(height: 15,),
                diaryEntryTwoField(context),
                SizedBox(height: 15,),
                behaviorEntryTwoField(context),
                SizedBox(height: 15,),
                diaryEntryThreeField(context),
                SizedBox(height: 15,),
                behaviorEntryThreeField(context),
                SizedBox(height: 15,),
                diaryEntryFourField(context),
                SizedBox(height: 15,),
                behaviorEntryFourField(context),
                SizedBox(height: 15,),
                diaryEntryFiveField(context),
                SizedBox(height: 15,),
                behaviorEntryFiveField(context),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: archiveButton(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                  child: archiveButtonTwo(),
                ),
              ],
            ),
          ),
        )
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('Create New Sleep Diary'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () async {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) {
                    return SleepDiaryHistoryPage( key: null, entryOne: _diaryEntryOne, entryTwo: _diaryEntryTwo, entryThree: _diaryEntryThree, entryFour: _diaryEntryFour,  entryFive: _diaryEntryFive, behaviorEntryOne: _behaviorEntryOne, behaviorEntryTwo: _behaviorEntryTwo, behaviorEntryThree: _behaviorEntryThree, behaviorEntryFour: _behaviorEntryFour, behaviorEntryFive: _behaviorEntryFive, title: 'HISTORY');
                  },
                ));
              },
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
              fit: BoxFit.cover),
          ),
          child: ListView(
            children: <Widget>[
              _sleepDiaryView,
              //_behaviorDiaryView,
            ],
          ),
        ));
  }
}

class SleepDiaryHistoryPage extends StatefulWidget {
  //final SleepDiaryHistoryPresenter presenter;
  SleepDiaryHistoryPage({required Key? key, required this.title, required this.entryOne, required this.entryTwo, required this.entryThree, required this.entryFour, required this.entryFive, required this.behaviorEntryOne, required this.behaviorEntryTwo, required this.behaviorEntryThree, required this.behaviorEntryFour, required this.behaviorEntryFive}) : super(key: key);
  final String title;
  final String entryOne;
  final String entryTwo;
  final String entryThree;
  final String entryFour;
  final String entryFive;
  final String behaviorEntryOne;
  final String behaviorEntryTwo;
  final String behaviorEntryThree;
  final String behaviorEntryFour;
  final String behaviorEntryFive;
  @override
  _SleepDiaryHistoryPageState createState() => _SleepDiaryHistoryPageState(entryOne, entryTwo, entryThree, entryFour, entryFive, behaviorEntryOne, behaviorEntryTwo, behaviorEntryThree, behaviorEntryFour, behaviorEntryFive);
}

class _SleepDiaryHistoryPageState extends State<SleepDiaryHistoryPage> {
  String entryOne;
  //kakak
  String entryTwo;
  String entryThree;
  String entryFour;
  String entryFive;
  String behaviorEntryOne;
  String behaviorEntryTwo;
  String behaviorEntryThree;
  String behaviorEntryFour;
  String behaviorEntryFive;

  _SleepDiaryHistoryPageState(this.entryOne, this.entryTwo, this.entryThree, this.entryFour, this.entryFive, this.behaviorEntryOne, this.behaviorEntryTwo, this.behaviorEntryThree, this.behaviorEntryFour, this.behaviorEntryFive);
  var _resultString = '';
  var _resultBehavior = '';
  String _recievedEntry = "";
  String _recievedBehavior = "";
  List _diaryEntriesList = [];
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final firestore = FirebaseFirestore.instance;

  String _getDiaryEntry() {

    firestore.collection("Sleep Diaries").get().then(
          (querySnapshot) {
        print("Successfully Completed");
        for(var docSnapshot in querySnapshot.docs) {
          String entries = docSnapshot['Sleep Diary Entry 1']; // pull the hours slept as an int
          print("Diary Entry: $entries");
          _recievedEntry = entries;
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    return _recievedEntry;
  }

  String _getBehaviorEntry() {
    firestore.collection("Sleep Diaries").get().then(
          (querySnapshot) {
        print("Successfully Completed");
        for(var docSnapshot in querySnapshot.docs) {
          String entries = docSnapshot['Behavior Entry 1']; // pull the hours slept as an int
          print("Behavior Entry: $entries");
          _recievedBehavior = entries;
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    return _recievedBehavior;
  }

  @override
   void updateResultValue(){
    setState(() {
      _getDiaryEntry();
      _getBehaviorEntry();
      _resultString = _recievedEntry;
      _resultBehavior = _recievedBehavior;
    });
  }

  @override
  Widget build(BuildContext context) {

    ElevatedButton loadButton() {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.withOpacity(.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
        onPressed: updateResultValue,
        icon: Icon( // <-- Icon
          Icons.download_done_outlined,
          size: 30.0,
        ),
        label:  Text('Load Latest Diary Entry', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
      );
    }

    var _sleepDiaryResultView = Column(
      children: <Widget>[
        Center(
          child: Text(
            'Retrieved Latest Diary: $_resultString',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic
            ),
          ),
        ),
      ],
    );

    var _sleepBehaviorResultView = Column(
      children: <Widget>[
        Center(
          child: Text(
            'Retrieved Latest Behavior: $_resultBehavior',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Diary History'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body:  Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
              fit: BoxFit.cover),
          ),
          child : Column(
          children: <Widget>[
          Hero(
            tag: 'ListTile-Hero',
            child: Card(
              child: ListTile(
                  leading: Icon(Icons.book_outlined),
                  title: Text(entryOne),
                  subtitle: Text(behaviorEntryOne),
                  tileColor: Colors.cyan,
                  trailing: Icon(Icons.more_vert),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute<Widget>(builder: (BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(title: const Text('Sleep Diary Entry 1')),
                            body: Center(
                                child: Hero(
                                    tag: 'ListTile-Hero',
                                    child: Card(
                                        child: ListTile(
                                          title: Text(entryOne),
                                            subtitle: Text(behaviorEntryOne),
                                            tileColor: Colors.blue[700],
                                            onTap: () {
                                              Navigator.pop(context);
                                            })


                                    )
                                )
                            ),
                          );
                        }
                        ));
                  }
              ),

            ),
          ),
            Hero(
              tag: 'ListTile-Hero',
              child: Card(
                child: ListTile(
                    leading: Icon(Icons.book_outlined),
                    title: Text(entryTwo),
                    subtitle: Text(behaviorEntryTwo),
                    tileColor: Colors.cyan,
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(title: const Text('Sleep Diary Entry 2')),
                              body: Center(

                                  child: Hero(
                                      tag: 'ListTile-Hero',
                                      child: Card(
                                          child: ListTile(
                                              title: Text(entryTwo),
                                              subtitle: Text(behaviorEntryTwo),
                                              tileColor: Colors.blue[700],
                                              onTap: () {
                                                Navigator.pop(context);
                                              })

                                      )
                                  )
                              ),
                            );
                          }
                          ));
                    }
                ),

              ),
            ),
            Hero(
              tag: 'ListTile-Hero',
              child: Card(
                child: ListTile(
                    leading: Icon(Icons.book_outlined),
                    title: Text(entryThree),
                    subtitle: Text(behaviorEntryThree),
                    tileColor: Colors.cyan,
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(title: const Text('Sleep Diary Entry 3')),
                              body: Center(
                                  child: Hero(
                                      tag: 'ListTile-Hero',
                                      child: Card(
                                          child: ListTile(
                                              title: Text(entryThree),
                                              subtitle: Text(behaviorEntryThree),
                                              tileColor: Colors.blue[700],
                                              onTap: () {
                                                Navigator.pop(context);
                                              })

                                      )
                                  )
                              ),
                            );
                          }
                          ));
                    }
                ),

              ),
            ),
            Hero(
              tag: 'ListTile-Hero',
              child: Card(
                child: ListTile(
                    leading: Icon(Icons.book_outlined),
                    title: Text(entryFour),
                    subtitle: Text(behaviorEntryFour),
                    tileColor: Colors.cyan,
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(title: const Text('Sleep Diary Entry 4')),
                              body: Center(
                                  child: Hero(
                                      tag: 'ListTile-Hero',
                                      child: Card(
                                          child: ListTile(
                                              title: Text(entryFour),
                                              subtitle: Text(behaviorEntryFour),
                                              tileColor: Colors.blue[700],
                                              onTap: () {
                                                Navigator.pop(context);
                                              })

                                      )
                                  )
                              ),
                            );
                          }
                          ));
                    }
                ),

              ),
            ),
            Hero(
              tag: 'ListTile-Hero',
              child: Card(
                child: ListTile(
                    leading: Icon(Icons.book_outlined),
                    title: Text(entryFive),
                    subtitle: Text(behaviorEntryFive),
                    tileColor: Colors.cyan,
                    trailing: Icon(Icons.more_vert),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(builder: (BuildContext context) {
                            return Scaffold(
                              appBar: AppBar(title: const Text('Sleep Diary Entry 5')),
                              body: Center(
                                  child: Hero(
                                      tag: 'ListTile-Hero',
                                      child: Card(
                                          child: ListTile(
                                              title: Text(entryFive),
                                              subtitle: Text(behaviorEntryFive),
                                              tileColor: Colors.blue[700],
                                              onTap: () {
                                                Navigator.pop(context);
                                              })

                                      )
                                  )
                              ),
                            );
                          }
                          ));
                    }
                ),

              ),
            ),
            loadButton(),
            _sleepDiaryResultView,
            _sleepBehaviorResultView,
          ]
          )
      ),
    );
  }
}

class SleepMusicPage extends StatefulWidget {
  final SleepMusicPresenter presenter;

  SleepMusicPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SleepMusicPageState createState() => _SleepMusicPageState(presenter);
}

class _SleepMusicPageState extends State<SleepMusicPage> {
  final SleepMusicPresenter presenter;
  _SleepMusicPageState(this.presenter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Music'),),
      body: SingleChildScrollView(
          child: Column(
            children: [
            SizedBox(height: 10,),
            Text("(ULTRA CALM) Sleep Music                                                              ",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),),
            SizedBox(height: 10,),
            YoutubeVideo("https://www.youtube.com/watch?v=SaRjRbkW6K4"),
            SizedBox(height: 10,),
            Text("Relaxing Water Sounds for Sleep                                                      ",
              style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),),
            SizedBox(height: 10,),
            YoutubeVideo("https://www.youtube.com/watch?v=A1IYf7fKdhY"),
            SizedBox(height: 10,),
            Text("Deep White Noise for Falling Asleep                                                ",
              style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),),
            SizedBox(height: 10,),
            YoutubeVideo("https://www.youtube.com/watch?v=FdN1pnEaJs0")
          ],),
      ),
    );
  }
}

class SleepGraphPage extends StatefulWidget {

  final SleepGraphPresenter presenter;

  SleepGraphPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SleepGraphPageState createState() => _SleepGraphPageState();
}

class _SleepGraphPageState extends State<SleepGraphPage> {
  late final List<charts.Series<dynamic, String>> seriesList; //list that will be sent to the bar graph
  final firestore = FirebaseFirestore.instance;               //instance of the firestore database

  Future <List<SleepHours>> populateList() async {    //method to populate a list of sleep logs
    final List<SleepHours> hoursOfSleep = [];         //list that will hold sleep data
    DateFormat dateFormat = DateFormat("yyyy-MM-dd"); //format to help set the condition
    String string = dateFormat.format(DateTime.now().subtract(Duration(days: 7)));
    await firestore.collection("Sleep Logs").where("Sleep Log Date", isGreaterThanOrEqualTo: string).get().then((querySnapshot) { //pulls every document in Sleep Logs with a date within the last 7 days
        print("Successfully Completed");
        int count = 1;
        for(var docSnapshot in querySnapshot.docs){
          String date = 'Entry $count';
          //String date = docSnapshot['Sleep Log Date'].toString();                 // pull the date of the sleep log as a string
          double hours = double.parse(docSnapshot['Hours Slept'].toString());       // pull the hours slept as an int
          double quality = double.parse(docSnapshot['Quality Rating'].toString());  // pull the quality rating as an int
          hoursOfSleep.add(SleepHours(date, hours, quality));                       // add the pulled data to the hours list
          count++;
          //print(count);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    return hoursOfSleep;
  }

  List <charts.Series<SleepHours, String>> _getSleepData(List<SleepHours> sleepData){
    return[
      charts.Series<SleepHours, String>( //hours slept column
        id: 'Hours Slept',                                          //name of column
        domainFn: (SleepHours sleephours, _) => sleephours.date,     //x-axis is the date
        measureFn: (SleepHours sleephours, _) => sleephours.hours,  //y-axis is the hours
        data: sleepData,                                            //use hoursOfSleep as the data set
        colorFn: (SleepHours sleephours, _){
          return charts.MaterialPalette.black;                      //outlines hours column in black to stand out
        },
          fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.blue.shadeDefault;          //makes the column blue
        },
      ),
      charts.Series<SleepHours, String>( //quality of sleep column
        id: 'Quality Rating',                                       //name of column
        domainFn: (SleepHours sleephours, _) => sleephours.date,    //x-axis is the date
        measureFn: (SleepHours sleephours, _) => sleephours.quality,//y-axis is the quality rating
        data: sleepData,                                            //use hoursOfSleep as the data set
        colorFn: (SleepHours sleephours, _){
          return charts.MaterialPalette.black;                      //outlines quality column in black to stand out
        },
        fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.green.shadeDefault;         //makes the column green
        },
      )
    ];
  }

  barChart() {                                                      //constructs the bar chart
    return charts.BarChart(
      seriesList,                                                   //uses seriesList for the columns and axes
      animate: true,                                                //animates the graph
      vertical: false,                                               //makes the graph vertical
      barGroupingType: charts.BarGroupingType.grouped,              //groups the columns together
      defaultRenderer: charts.BarRendererConfig(
        groupingType: charts.BarGroupingType.grouped,
        strokeWidthPx: 2,
      ),
      domainAxis: new charts.OrdinalAxisSpec(                       //prints a value in each entry's x axis
          renderSpec: new charts.SmallTickRendererSpec(
            // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(                 //set font size and color of x axis
                  fontSize: 18, // size in Pts.
                  color: charts.MaterialPalette.white),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(                  //set the x axis to white
                  color: charts.MaterialPalette.white))),
      primaryMeasureAxis: new charts.NumericAxisSpec(
          renderSpec: new charts.GridlineRendererSpec(              //y axis setup
            // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(                 //set font size and color for y axis
                  fontSize: 18, // size in Pts.
                  color: charts.MaterialPalette.white),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(                  //set the lines for each y value to white
                  color: charts.MaterialPalette.white))),
    );
  }

  @override
  void initState() {
    super.initState();
    barChartState(); //calls the method to start the bar chart implementation
  }

  void barChartState() async {
    Future <List<SleepHours>> logs = populateList(); //calls the method to return a list of entries with the date, hours, and quality recorded
    List<SleepHours> list2 = await logs;             //converts the list of Futures into a list of SleepHours so that it can be used in the bar chart
    seriesList = _getSleepData(list2);               //calls the method to prepare the list of sleep logs to be used as data
  }

  @override
  Widget build(BuildContext context) {               //builds the Time Clock page with the bar graph
    return FutureBuilder(future: populateList(), builder: (context, snapshot) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Sleep Graph'),),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background_three_sweet_dreams.jpg"), //sets the background to an image
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.all(20.0),
          child: barChart(),              //creates the bar chart on the page
        ),
      );
    }
    );
  }
}

class SleepHours{
  final String date;                               //variable for date
  final double hours;                              //variable for hours slept
  final double quality;                            //variable for quality rating
  SleepHours(this.date, this.hours, this.quality);

  String toString(){
    return "Date: $date\nHours Recorded: $hours\nQuality Rating: $quality"; //returns a string of all values
  }
}

class SettingPage extends StatefulWidget {
  final SettingPresenter presenter;

  SettingPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SettingPageState createState() => _SettingPageState();
}

class NotificationSettingPage extends StatefulWidget {
  final NotificationSettingPresenter presenter;

  NotificationSettingPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
    body: Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
    fit: BoxFit.cover),
    ),
          child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Text("Notification Settings!", style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textScaleFactor: 3,)
                  ,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(.5),
                      foregroundColor: Colors.white,
                      //minimumSize: Size(150, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0))
                  ),
                  child: Text('Notification Settings', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return NotificationSettingScreen();
                        }));
                  },
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.withOpacity(.5),
                        foregroundColor: Colors.white,
                        //minimumSize: Size(150, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0))
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  child: Text('Return to Home Screen', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
                )
              ]),
        )
    );
  }
}

class NotificationSettingScreen extends StatefulWidget {
  @override
  _NotificationSettingScreen createState() => _NotificationSettingScreen();
}

class _NotificationSettingScreen extends State<NotificationSettingScreen> {
  @override
  Widget build(BuildContext context) {
    return new NotificationSettingPage(
      new NotificationSettingPresenter(), title: 'Notification Settings', key: Key("LOGS"),);
  }
}

//Sleep Info Page
class SleepInfoPage extends StatefulWidget {
  final SleepInfoPresenter presenter;
  final String title;
  SleepInfoPage(this.presenter, {required Key? key, required this.title}) : super(key : key);
  @override
  _SleepInfoPageState createState() => _SleepInfoPageState();
}

class _SleepInfoPageState extends State<SleepInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Info', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.greenAccent.shade700.withOpacity(.9),),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
            fit: BoxFit.cover),
        ),
        //padding: EdgeInsets.all(20.0),
        child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 80.0, bottom: 20.0),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0))
                ),
                child: Text('Sleep Benefits', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),

                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SleepBenefitsScreen();
                      }));
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.withOpacity(.5),
                    foregroundColor: Colors.white,
                    //minimumSize: Size(150, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0))
                ),
                child: Text('How to get more sleep', style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) {
                        return SleepAdviceScreen();
                      }));
                },
              ),

            ]
        ),),
    );
  }
}

//Sleep Benefits Page from here to line 904
class SleepBenefitsScreen extends StatefulWidget {
  @override
  _SleepBenefitsScreen createState() => _SleepBenefitsScreen();
}

class _SleepBenefitsScreen extends State<SleepBenefitsScreen> {
  @override
  Widget build(BuildContext context) {
    return new SleepBenefitsPage(
      new SleepBenefitsPresenter(), title: 'Sleep Benefits', key: Key("LOGS"),
    );
  }
}

class SleepBenefitsPage extends StatefulWidget {
  final SleepBenefitsPresenter presenter;
  final String title;
  SleepBenefitsPage(this.presenter, {required Key? key, required this.title}) : super(key : key);
  @override
  _SleepBenefitsPageState createState() => _SleepBenefitsPageState();
}
//Consider changing the font in the future
class _SleepBenefitsPageState extends State<SleepBenefitsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Benefits', style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.greenAccent.shade700,

      ),
      body: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
          fit: BoxFit.cover),
          ),
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(20)),
            RichText(
                text: new TextSpan(
                children: [
                  new TextSpan(
                      text:'The recommended amount of sleep for an adult is between 7-9 hours each night.'
                        ' Getting this amount of sleep can result in: \n\n',
                    style: new TextStyle(backgroundColor: Colors.lightGreen.withOpacity(.3), color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)
                  ),
                  new TextSpan(
                    text: '     • An improved immune system\n'
                          '     • Reduced risk for serious health problems\n'
                          '     • Clearer thinking',
                    style: new TextStyle(backgroundColor: Colors.lightGreen.withOpacity(.3), color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)
                  ),
                ]
              )
          ),
          Padding(padding: EdgeInsets.only(top: 20.0, bottom: 20.0)),
            RichText(
                text: new TextSpan(
                    children: [
                      new TextSpan(
                          text:'Getting less than 7 hours of sleep can result in: \n\n',
                          style: new TextStyle(backgroundColor: Colors.lightGreen.withOpacity(.3), color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)
                      ),
                      new TextSpan(
                          text: '     • Depression\n'
                                '     • Diabetes, heart disease, and high blood \n'
                                '       pressure\n'
                                '     • Weight gain',
                          style: new TextStyle(backgroundColor: Colors.lightGreen.withOpacity(.3), color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)
                      ),
                    ]
                )
            ),
            Padding(padding: EdgeInsets.only(top: 20.0, bottom: 20.0)),
            RichText(
                text: new TextSpan(
                    children: [
                      new TextSpan(
                          text:'Needing more than 9 hours of sleep to feel\n'
                               'rested could indicate an underlying sleep or \n'
                               'medical problem'
                               ,
                          style: new TextStyle(backgroundColor: Colors.lightGreen.withOpacity(.3), color: Colors.black, fontSize: 19, fontWeight: FontWeight.w900)
                      ),
                    ]
                )
            ),
          Padding(padding: EdgeInsets.only(top: 100)),
          RichText(
            text: new TextSpan(
                children: [
                  new TextSpan(
                    text: 'Further Reading (Clickable Links): \n',
                    style: new TextStyle(backgroundColor: Colors.lightBlueAccent.withOpacity(.4), fontSize: 24, color: Colors.black, fontWeight: FontWeight.w700),
                  ),
                  new TextSpan(
                    text:'    • Office of Disease Prevention and Health Promotion,\n',
                    style: new TextStyle(backgroundColor: Colors.lightBlueAccent.withOpacity(.4), fontSize: 24, color:Colors.black),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://web.archive.org/web/20231114005511/https://health.gov/myhealthfinder/healthy-living/mental-health-and-relationships/get-enough-sleep'));
                      },
                  ),
                  new TextSpan(
                    text: '   • Mayo Clinic\n',
                    style: new TextStyle(fontSize: 24, backgroundColor: Colors.lightBlueAccent.withOpacity(.4), color: Colors.black),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () { launchUrl(Uri.parse('https://web.archive.org/web/20231201150857/https://www.mayoclinic.org/healthy-lifestyle/adult-health/expert-answers/how-many-hours-of-sleep-are-enough/faq-20057898'));
                      },
                  ),
                  new TextSpan(
                    text:'    • Johns Hopkins University',
                    style: new TextStyle(fontSize: 24, backgroundColor: Colors.lightBlueAccent.withOpacity(.4), color: Colors.black),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://web.archive.org/web/20231127212524/https://www.hopkinsmedicine.org/health/wellness-and-prevention/oversleeping-bad-for-your-health'));
                      },
                  ),
                ]
            ),
          ),
      ]),
      )
    );
  }
}

class SleepAdviceScreen extends StatefulWidget{
  @override
  _SleepAdviceScreen createState() => _SleepAdviceScreen();
}
class _SleepAdviceScreen extends State<SleepAdviceScreen> {
  @override
  Widget build(BuildContext context) {
    return new SleepAdvicePage(
      new SleepAdvicePresenter(), title: 'Sleep Advice', key: Key("LOGS"),
    );
  }
}

class SleepAdvicePage extends StatefulWidget {
  final SleepAdvicePresenter presenter;
  final String title;
  SleepAdvicePage(this.presenter, {required Key? key, required this.title});
  @override
  _SleepAdvicePageState createState() => _SleepAdvicePageState();
}

class _SleepAdvicePageState extends State<SleepAdvicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advice for Sleep', style: TextStyle(color: Colors.black),),
               backgroundColor: Colors.greenAccent.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background_three_sweet_dreams.jpg"),
        fit: BoxFit.cover),
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget> [
            RichText(
                text: new TextSpan(
                    children: [
                      new TextSpan(
                          text:'Tips for getting better sleep: \n\n',
                          style: new TextStyle(backgroundColor: Colors.lightGreen.withOpacity(.3), color: Colors.black, fontSize: 24, fontWeight: FontWeight.w800)
                      ),
                      new TextSpan(
                          text:'     • Be consistent, go to bed and wake up at \n'
                               '       the same time each night\n\n'
                               '     • Make sure bedroom is comfortable and \n'
                               '       sufficiently dark\n\n'
                               '     • Get some exercise during the day\n\n'
                               '     • Remove electronic devices, such as TVs, from your bedroom\n\n' ,
                          style: new TextStyle(backgroundColor: Colors.lightGreen.withOpacity(.3), color: Colors.black, fontSize: 19, fontWeight: FontWeight.w600)
                      ),
                    ]
                )
            ),
            RichText(text: new TextSpan(
                children: [
                  new TextSpan(text: 'Source:', style: new TextStyle(backgroundColor: Colors.purple.withOpacity(.3), color: Colors.black, fontSize: 21, fontWeight: FontWeight.w800)),
                  new TextSpan(
                    text:' Centers for Disease Control and Prevention',
                    style: new TextStyle(backgroundColor: Colors.purple.withOpacity(.3), color:Colors.black, fontSize: 21, fontWeight: FontWeight.w800),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://web.archive.org/web/20231119222342/https://www.cdc.gov/sleep/about_sleep/sleep_hygiene.html'));
                      },
                  ),
                ]
            )),
            Padding(padding: EdgeInsets.only(top: 75)),
            RichText(text: new TextSpan(
              children: [
                new TextSpan(text: 'Further Reading (Clickable Links): \n\n', style: new TextStyle(backgroundColor: Colors.lightBlueAccent.withOpacity(.3), color: Colors.black, fontSize: 21, fontWeight: FontWeight.w800)),
                  new TextSpan(
                    text:'     • United Kingdom National Health Service\n\n',
                    style: new TextStyle(backgroundColor: Colors.lightBlueAccent.withOpacity(.3), color:Colors.black, fontSize: 21, fontWeight: FontWeight.w800),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://web.archive.org/web/20231114140631/https://www.nhs.uk/every-mind-matters/mental-wellbeing-tips/how-to-fall-asleep-faster-and-sleep-better/'));
                      },
                  ),
                new TextSpan(
                  text:'     • Healthline\n\n',
                  style: new TextStyle(backgroundColor: Colors.lightBlueAccent.withOpacity(.3), color:Colors.black, fontSize: 21, fontWeight: FontWeight.w800),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          'https://web.archive.org/web/20231103022030/https://www.healthline.com/nutrition/17-tips-to-sleep-better'));
                    },
                ),
                new TextSpan(
                  text:'     • Headspace\n\n',
                  style: new TextStyle(backgroundColor: Colors.lightBlueAccent.withOpacity(.3), color:Colors.black, fontSize: 21, fontWeight: FontWeight.w800),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          'https://web.archive.org/web/20230622173135/https://www.headspace.com/sleep/how-to-sleep-better'));
                    },
                ),
              ]
            )
            ),
          ],
        ),
      ),
    );
  }
}


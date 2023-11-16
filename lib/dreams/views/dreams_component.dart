import 'dart:core';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../views/dreams_view.dart';
import '../presenter/dreams_presenter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  final UNITSPresenter presenter;

  HomePage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements UNITSView {

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
          title: Text('Sleep Calculator'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent.shade700,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(5.0)),
            _mainPartView,
            Padding(padding: EdgeInsets.all(5.0)),
            _resultView
          ],
        )
    );

  }

  ElevatedButton calculateButton() {
    return ElevatedButton(
      onPressed: _calculator,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent.shade700,
        textStyle: TextStyle(color: Colors.white70)
      ),
      child: Text(
        'Calculate',
        style: TextStyle(fontSize: 16.9),
      ),
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
  _SleepLogPageState createState() => _SleepLogPageState();
}

class _SleepLogPageState extends State<SleepLogPage> implements UNITSView {

  final databaseReference = FirebaseFirestore.instance.collection('Sleep Logs');
  final FocusNode _qualityRatingFocus = FocusNode();
  final FocusNode _hoursSleptFocus = FocusNode();
  var _qualityRatingController = TextEditingController();
  var _hoursSleptController = TextEditingController();
  var _resultString = '';
  var _message = '';
  DateTime Date = DateTime.now();
  String _qualityRating = "0";
  String _hoursSlept = "0.0";
  String _sleepLogDate = '';

  var _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    this.widget.presenter.unitsView = this;
  }

  void _recorder() {
    if(_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      this.widget.presenter.onRecordClicked(_qualityRating);
    }
     _sleepLogDate = '$Date';
    createLog(_sleepLogDate, _hoursSlept, _qualityRating);
  }

  @override
  void updateResultValue(String resultValue){
    setState(() {
      _resultString = resultValue;
    });
  }

  @override
  void updateMessage(String message){
    setState(() {
      _message = message;
    });
  }

  void createLog(String _sleepLogDate, String _hoursSlept, String _qualityRating) {
    final data = {"Sleep Log Date": _sleepLogDate, "Hours Slept": _hoursSlept, "Quality Rating": _qualityRating};
    databaseReference.add(data);
  }

  Future<DocumentSnapshot> retrieveData() async{
    return databaseReference.doc("1").get();
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  /*late final List<charts.Series<dynamic, String>> seriesList;

  static List <charts.Series<SleepHours, String>> _createRandomData() {
    final random = Random();
    final hoursOfSleep = [
      SleepHours('Sunday', random.nextInt(9)),
      SleepHours('Monday', random.nextInt(9)),
      SleepHours('Tuesday', random.nextInt(9)),
      SleepHours('Wednesday', random.nextInt(9)),
      SleepHours('Thursday', random.nextInt(9)),
      SleepHours('Friday', random.nextInt(9)),
      SleepHours('Saturday', random.nextInt(9)),
    ];
    final qualityOfSleep = [
    SleepHours('Sunday', random.nextInt(11)),
    SleepHours('Monday', random.nextInt(11)),
    SleepHours('Tuesday', random.nextInt(11)),
    SleepHours('Wednesday', random.nextInt(11)),
    SleepHours('Thursday', random.nextInt(11)),
    SleepHours('Friday', random.nextInt(11)),
    SleepHours('Saturday', random.nextInt(11)),
    ];
    return[
      charts.Series<SleepHours, String>(
        id: 'Hours Slept',
        domainFn: (SleepHours sleephours, _) => sleephours.day,
        measureFn: (SleepHours sleephours, _) => sleephours.hours,
        data: hoursOfSleep,
        fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.blue.shadeDefault;
        },
      ),
      charts.Series<SleepHours, String>(
        id: 'Quality of Sleep',
        domainFn: (SleepHours sleephours, _) => sleephours.day,
        measureFn: (SleepHours sleephours, _) => sleephours.hours,
        data: qualityOfSleep,
        fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.green.shadeDefault;
        },
      )
    ];
  }

  barChart() {
    return charts.BarChart(
      seriesList,
      animate: true,
      vertical: true,
      barGroupingType: charts.BarGroupingType.grouped,
      defaultRenderer: charts.BarRendererConfig(
        groupingType: charts.BarGroupingType.grouped,
        strokeWidthPx: 1.0,
      ),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.NoneRenderSpec(),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {

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
          labelText: 'Quality of sleep on a scale of 1-10',
            labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.6)),
            icon: Icon(Icons.scale),
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
          labelText: 'Hours slept today',
          labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.6)),
          icon: Icon(Icons.timer),
          fillColor: Colors.white,
        ),
      );
    }

    var _sleepLogView = Container(
      color: Colors.purpleAccent.withOpacity(0.4),
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              hoursSleptField(context),
              qualityRatingField(context),
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
            'Result: $_resultString',
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
        title: Text('Sleep Log'),
      ),
      body: ListView(
          children: <Widget>[
              _sleepLogView,
              Padding(
                padding: EdgeInsets.only(top: 200.0, bottom: 20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade400
                  ),
                        onPressed: () {},
                  icon: Icon( // <-- Icon
                    Icons.bar_chart_sharp,
                    size: 27.0,
                  ),
                  label: Text('Historical Sleep Data'),
                ),
              ),
            _sleepLogResultView,
            //_sleepLogHistoryView,
            ],
          ),
      );
  }

  ElevatedButton recordButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent.shade400
      ),
      onPressed: _recorder,
      icon: Icon( // <-- Icon
        Icons.cloud,
        size: 27.0,
      ),
      label: Text('Record Sleep Data'),
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

class TimeClockPage extends StatefulWidget {

  final TimeClockPresenter presenter;

  TimeClockPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _TimeClockPageState createState() => _TimeClockPageState();
}

class _TimeClockPageState extends State<TimeClockPage> {
  late final List<charts.Series<dynamic, String>> seriesList;

  static List <charts.Series<SleepHours, String>> _getSleepData() {
    final List logList = [];
    final List<SleepHours> hoursOfSleep = [];
    final List<SleepHours> qualityOfSleep = [];
    final firestore = FirebaseFirestore.instance;
    firestore.collection("Sleep Logs").where("Sleep Log Date", isLessThanOrEqualTo: DateTime.now().subtract(Duration(days: 7))).get().then(
            (querySnapshot) {
              print("Successfully Completed");
          for(var docSnapshot in querySnapshot.docs){
            //final data = docSnapshot.data() as Map<String, dynamic>;
            print('${docSnapshot.id} => ${docSnapshot.data()}');
          }
        }
    );
    return[
      charts.Series<SleepHours, String>( //hours slept column
        id: 'Hours Slept',
        domainFn: (SleepHours sleephours, _) => sleephours.day,
        measureFn: (SleepHours sleephours, _) => sleephours.hours,
        data: hoursOfSleep,
        fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.blue.shadeDefault;
        },
      ),
      charts.Series<SleepHours, String>( //quality of sleep column
        id: 'Quality of Sleep',
        domainFn: (SleepHours sleephours, _) => sleephours.day,
        measureFn: (SleepHours sleephours, _) => sleephours.hours,
        data: qualityOfSleep,
        fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.green.shadeDefault;
        },
      )
    ];
  }

  barChart() {
    return charts.BarChart(
      seriesList,
      animate: true,
      vertical: true,
      barGroupingType: charts.BarGroupingType.grouped,
      defaultRenderer: charts.BarRendererConfig(
        groupingType: charts.BarGroupingType.grouped,
        strokeWidthPx: 1.0,
      ),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.NoneRenderSpec(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    seriesList = _getSleepData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Clock'),),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: barChart(),
      ),
    );
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
        body: Center(
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
                      primary: Colors.blueAccent
                  ),
                  child: Text('Notification Settings'),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                          return NotificationSettingScreen();
                        }));
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go back')
                )
              ]),
        )
    );
  }
}

class SleepHours{
  final String day;
  final int hours;
  SleepHours(this.day, this.hours);
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
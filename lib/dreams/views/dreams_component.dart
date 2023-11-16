import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
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
      this.widget.presenter.onRecordClicked( _hoursSlept ,_qualityRating);
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


  late final List<charts.Series<dynamic, String>> seriesList;

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
    return[
      charts.Series<SleepHours, String>(
        id: 'Hours Slept',
        domainFn: (SleepHours sleephours, _) => sleephours.day,
        measureFn: (SleepHours sleephours, _) => sleephours.hours,
        data: hoursOfSleep,
        fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.blue.shadeDefault;
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
            'Average Hours Slept: $_resultString',
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
    return[
      charts.Series<SleepHours, String>(
        id: 'Hours Slept',
        domainFn: (SleepHours sleephours, _) => sleephours.day,
        measureFn: (SleepHours sleephours, _) => sleephours.hours,
        data: hoursOfSleep,
        fillColorFn: (SleepHours sleephours, _) {
          return charts.MaterialPalette.blue.shadeDefault;
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
    seriesList = _createRandomData();
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
        title: Text('Sleep Info'),
      backgroundColor: Colors.purpleAccent.withOpacity(.9),),
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background-sweet-dreams.jpg"),
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
                    backgroundColor: Colors.blueAccent.withOpacity(.4),
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 60),
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
                    backgroundColor: Colors.blueAccent.withOpacity(.4),
                    foregroundColor: Colors.white,
                    minimumSize: Size(150, 60),
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
        title: Text('Sleep Benefits'),),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(20)),
            RichText(
                text: new TextSpan(
                children: [
                  new TextSpan(
                      text:'The recommended amount of sleep for an adult is between 7-9 hours each night.'
                        ' Getting this amount of sleep can result in: \n\n',
                    style: new TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.w700)
                  ),
                  new TextSpan(
                    text: '     • An improved immune system\n'
                          '     • Reduced risk for serious health problems\n'
                          '     • Clearer thinking',
                    style: new TextStyle(color: Colors.deepPurple, fontSize: 18, fontWeight: FontWeight.w700)
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
                          style: new TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w700)
                      ),
                      new TextSpan(
                          text: '     • Depression\n'
                                '     • Diabetes, heart disease, and high blood \n'
                                '       pressure\n'
                                '     • Weight gain',
                          style: new TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w700)
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
                          style: new TextStyle(color: Colors.blueAccent, fontSize: 19, fontWeight: FontWeight.w900)
                      ),
                    ]
                )
            ),
          Padding(padding: EdgeInsets.only(top: 250.0)),
          RichText(
            text: new TextSpan(
                children: [
                  new TextSpan(
                    text: 'Source: ',
                    style: new TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                  ),
                  new TextSpan(
                    text:'Office of Disease Prevention and Health Promotion,\n',
                    style: new TextStyle(color:Colors.purple),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://health.gov/myhealthfinder/healthy-living/mental-health-and-relationships/get-enough-sleep'));
                      },
                  ),
                  new TextSpan(
                    text: '   Mayo Clinic',
                    style: new TextStyle(color: Colors.red),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () { launchUrl(Uri.parse('https://www.mayoclinic.org/healthy-lifestyle/adult-health/expert-answers/how-many-hours-of-sleep-are-enough/faq-20057898'));
                      },
                  ),
                  new TextSpan(
                    text: ', and ',
                    style: new TextStyle(color: Colors.black),
                  ),
                  new TextSpan(
                    text:'Johns Hopkins University',
                    style: new TextStyle(color:Colors.blueAccent),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://www.hopkinsmedicine.org/health/wellness-and-prevention/oversleeping-bad-for-your-health#:~:text=Oversleeping%20is%20associated%20with%20many,Obesity'));
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
        title: Text('Advice for Sleep'),),
      body: Container(
        //decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/background-sweet-dreams.jpg"),
          //fit: BoxFit.cover),
       // ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget> [
            RichText(
                text: new TextSpan(
                    children: [
                      new TextSpan(
                          text:'Tips for getting better sleep: \n\n',
                          style: new TextStyle(color: Colors.purple, fontSize: 24, fontWeight: FontWeight.w900)
                      ),
                      new TextSpan(
                          text:'     • Be consistent, go to bed and wake up at \n'
                               '       the same time each night\n\n'
                               '     • Make sure bedroom is comfortable and \n'
                               '       sufficiently dark\n\n'
                               '     • Get some exercise during the day\n\n'
                               '     • Remove electronic devices, such as TVs,\n'
                               '       from your bedroom\n\n' ,
                          style: new TextStyle(color: Colors.purple, fontSize: 18, fontWeight: FontWeight.w600)
                      ),
                    ]
                )
            ),
            RichText(text: new TextSpan(
                children: [
                  new TextSpan(text: 'Source:', style: new TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800)),
                  new TextSpan(
                    text:' Centers for Disease Control and Prevention',
                    style: new TextStyle(color:Colors.purple, fontSize: 14, fontWeight: FontWeight.w800),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://www.cdc.gov/sleep/about_sleep/sleep_hygiene.html'));
                      },
                  ),
                ]
            )),
            Padding(padding: EdgeInsets.only(top: 200)),
            RichText(text: new TextSpan(
              children: [
                new TextSpan(text: 'Further Reading: \n\n', style: new TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w800)),
                  new TextSpan(
                    text:'     • United Kingdom National Health Service\n\n',
                    style: new TextStyle(color:Colors.blue, fontSize: 18, fontWeight: FontWeight.w600),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse(
                            'https://www.nhs.uk/every-mind-matters/mental-wellbeing-tips/how-to-fall-asleep-faster-and-sleep-better/'));
                      },
                  ),
                new TextSpan(
                  text:'     • Healthline\n\n',
                  style: new TextStyle(color:Colors.blue, fontSize: 18, fontWeight: FontWeight.w600),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          'https://www.healthline.com/nutrition/17-tips-to-sleep-better'));
                    },
                ),
                new TextSpan(
                  text:'     • Headspace\n\n',
                  style: new TextStyle(color:Colors.blue, fontSize: 18, fontWeight: FontWeight.w600),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      launchUrl(Uri.parse(
                          'https://www.headspace.com/sleep/how-to-sleep-better'));
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


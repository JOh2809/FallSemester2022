import 'package:flutter/material.dart';
import '../presenter/alarm_presenter.dart';
import 'dart:async';
import 'dart:core';
import 'package:audioplayers/audioplayers.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:math';

class AlarmPage extends StatefulWidget {
  final AlarmPresenter presenter;
  const AlarmPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {

  TimeOfDay selectedTime = TimeOfDay.now();
  String displayText = "";
  final player = AudioPlayer();
  int checkButton = 0;

  void changeText() {
    setState(() {
      displayText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Page'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Click on the clock to set an alarm",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
          Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: IconButton(
                    icon: const Icon(
                      Icons.access_alarm_rounded,
                      size: 80,
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    tooltip: '!',
                    onPressed: () async {
                      _selectTime(context);
                      setState(() {
                        displayText = "You have an alarm set for: \n ${selectedTime.hour}:${selectedTime.minute}";
                      });
                    }
                    ),
              ),
            ],
          ),
          const SizedBox(
            width: 32.0,
            height: 32.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  displayText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 25),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    changeText();
                    //await player.play(AssetSource('.../assets/AlarmNoise.mp3'));
                    checkButton = 1;
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent
                      ,
                      shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 5.0,
                            color: Colors.white,
                          ),
                          borderRadius: BorderRadius.circular(360)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 60),
                      textStyle: const TextStyle(
                          color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                  child: const Text("Delete Alarm"),  ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _selectTime(BuildContext context) async {
    final  TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );

    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
      });
    }

    const fiveSec = Duration(seconds: 5);
    Timer.periodic(fiveSec, (Timer t) => checkTimer(selectedTime));
  }

  checkTimer(TimeOfDay selectedTime) {
    int alarmId = 1;

    final DateTime timeSystem;
    timeSystem = DateTime.now();
    if (timeSystem.hour == selectedTime.hour &&
        timeSystem.minute == selectedTime.minute && checkButton == 0) {

      AndroidAlarmManager.oneShotAt(
          DateTime(selectedTime.hour, selectedTime.minute),
          alarmId,
          //fireAlarm(player));
          fireAlarm(player));
      checkButton = 1;
    }
  }
}

fireAlarm(player) {
 player.play(AssetSource('AlarmNoise.mp3'));
}

extension TimeOfDayExtension on TimeOfDay {
  TimeOfDay add(int hour, int minute) {
    Random rnd;
    int min = 1;
    int max = 5;
    rnd = Random();
    minute = minute + min + rnd.nextInt(max - min);
    if (minute >= 60) {
      minute = minute - 60;
      hour = hour + 1;
    }

    return replacing(hour: hour, minute: minute);
  }
}

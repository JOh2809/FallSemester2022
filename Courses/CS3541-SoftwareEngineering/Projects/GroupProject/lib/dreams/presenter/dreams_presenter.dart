
import 'dart:ffi';

import '../views/dreams_view.dart';
import '../viewmodel/dreams_viewmodel.dart';
import '../utils/dreams_constant.dart';
import '../utils/dreams_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UNITSPresenter {
  void onCalculateClicked(String hourString, String minuteString, String sleepMinuteString, String sleepHourString){

  }

  void onRecordClicked(String qualityRatingString) {}

  void onOptionChanged(int value, {required String sleepMinuteString, required String sleepHourString}) {

  }
  void onTimeOptionChanged(int value) {

  }
  set unitsView(UNITSView value){}

  void onQualityRatingSubmitted(String qualityRating){}

  void onHourSubmitted(String hour){}
  void onMinuteSubmitted(String minute){}
  void onSleepHourSubmitted(String sleepHour){}
  void onSleepMinuteSubmitted(String sleepMinute){}
}

class SleepCalculatorPresenter implements UNITSPresenter{
  UNITSViewModel _viewModel = UNITSViewModel();
  UNITSView _view = UNITSView();

  SleepCalculatorPresenter() {
    this._viewModel = _viewModel;
    _loadUnit();
  }

  void _loadUnit() async{
    _viewModel.value = await loadValue();
    _viewModel.valueTime = await loadValue();
    _view.updateUnit(_viewModel.value);
    _view.updateTimeUnit(_viewModel.valueTime);
  }

  @override
  set unitsView(UNITSView value) {
    _view = value;
    _view.updateUnit(_viewModel.value);
    _view.updateTimeUnit(_viewModel.valueTime);
  }


  @override
  void onCalculateClicked(String hourString, String minuteString, String sleepMinuteString, String sleepHourString) {
    var hour = 0.0;
    var minute = 0.0;
    var sleepHour = 0.0;
    var sleepMinute = 0.0;
    try {
      hour = double.parse(hourString);
    } catch (e){

    }
    try {
      minute = double.parse(minuteString);
    } catch (e){

    }
    try {
      sleepHour = double.parse(sleepHourString);
    } catch (e){

    }
    try {
      sleepMinute = double.parse(sleepMinuteString);
    } catch (e) {

    }

    List temp = new List.filled(3, null, growable: false);
    _viewModel.hour = hour;
    _viewModel.minute = minute;
    _viewModel.sleepHour = sleepHour;
    _viewModel.sleepMinute = sleepMinute;
    temp = calculator(hour,minute,sleepHour, sleepMinute, _viewModel.unitType, _viewModel.unitTypeTime);
    //  temp returns a List of the time, AM or PM, and WAKE or BED.
    //  The time that is returned is in the format of a double ex) 12.30 is 12:30.

    _viewModel.units = temp[0];
    UnitType tempTime = temp[1];
    UnitType tempMessage = temp[2];

    if(tempTime == UnitType.AM) {
      _viewModel.timeType = "AM";
    } else if (tempTime == UnitType.PM) {
      _viewModel.timeType = "PM";
    }

    if(tempMessage == UnitType.BED) {
      _viewModel.message = "You should wake up at";
    } else if (tempMessage == UnitType.WAKE) {
      _viewModel.message = "You should go to bed at";
    }
    _view.updateMessage(_viewModel.message);
    _view.updateTimeString(_viewModel.timeType);
    _view.updateResultValue(_viewModel.resultInString);
  }

  @override
  void onOptionChanged(int value, {required String sleepMinuteString, required String sleepHourString})  {

    if (value != _viewModel.value) {
      _viewModel.value = value;
      saveValue(_viewModel.value);
      var curOdom = 0.0;
      var fuelUsed = 0.0;
      if (!isEmptyString(sleepHourString)) {
        try {
          curOdom = double.parse(sleepHourString);
        } catch (e) {
        }
      }
      if (!isEmptyString(sleepMinuteString)) {
        try {
          fuelUsed = double.parse(sleepMinuteString);
        } catch (e) {

        }
      }
      _view.updateUnit(_viewModel.value);
      _view.updateSleepHour(sleepHour: _viewModel.sleepHourInString);
      _view.updateSleepMinute(sleepMinute: _viewModel.sleepMinuteInString);
    }
  }

  @override
  void onTimeOptionChanged(int value)  {

    if (value != _viewModel.valueTime) {
      _viewModel.valueTime = value;
      saveValue(_viewModel.valueTime);

      _view.updateTimeUnit(_viewModel.valueTime);
    }
  }

  @override
  void onHourSubmitted(String hour) {
    try{
      _viewModel.hour = double.parse(hour);
    }catch(e){

    }
  }

  @override
  void onMinuteSubmitted(String minute) {
    try{
      _viewModel.minute = double.parse(minute);
    }catch(e){

    }
  }

  @override
  void onSleepHourSubmitted(String sleepHour) {
    try {
      _viewModel.sleepHour = double.parse(sleepHour);
    } catch (e){

    }
  }

  @override
  void onSleepMinuteSubmitted(String sleepMinute) {
    try {
      _viewModel.sleepMinute = double.parse(sleepMinute);
    } catch (e){

    }
  }

  @override
  void onRecordClicked(String qualityRatingString) {
    // TODO: implement onRecordClicked
  }

  @override
  void onQualityRatingSubmitted(String qualityRating) {
    // TODO: implement onQualityRatingSubmitted
  }
}

class SleepLogPresenter { //May have to implement UNITSPresenter or new presenter for values specific for sleep log.
  final databaseReference = FirebaseFirestore.instance.collection('Sleep Logs');
  UNITSViewModel _viewModel = UNITSViewModel();
  UNITSView _view = UNITSView();

  DATABASEViewModel _databaseViewModel = DATABASEViewModel();
  DATABASEView _databaseView = DATABASEView();

  //Initialize DatabaseViewModel within this presenter.
  // Create separate view model for getting database values from DatabaseViewModel.
  //Format got database value, along with message, and display it to the user.
  //Could use datetimenow/datetimeyesterday methods to assign historical data to specific dates.
  //Put images in assets folder and assign background image to that asset using container.

  SleepLogPresenter() {
    this._viewModel = _viewModel;
    _loadUnit();
    this._databaseViewModel = _databaseViewModel;
    _loadUnit();
  }

  void _loadUnit() async{
    _viewModel.value = await loadValue();
    //_viewModel.valueTime = await loadValue();
    _view.updateUnit(_viewModel.value);
    // _view.updateTimeUnit(_viewModel.valueTime);

  }

  @override
  set unitsView(UNITSView value) {
    _view = value;
    _view.updateUnit(_viewModel.value);
  }

  @override
  void onRecordClicked(String hoursSleptString, String qualityRatingString) {
    var qualityRating = 0.0;
    var hoursSlept = 0.0;
    try {
      hoursSlept = double.parse(hoursSleptString);
    } catch (e){}
    try {
      qualityRating = double.parse(qualityRatingString);
    } catch (e){}

    List temp = new List.filled(2, null, growable: false);
    _viewModel.qualityRating = qualityRating;
    temp = recorder(hoursSlept, qualityRating);

    _viewModel.units = temp[0];

    _view.updateResultValue(_viewModel.resultInString);
  }

  void createLog(String _sleepLogDate, String _hoursSlept, String _qualityRating, String _timesNapped, String _timeFellAsleep) {
    final data = {"Sleep Log Date": _sleepLogDate, "Hours Slept": _hoursSlept, "Quality Rating": _qualityRating, "Times Napped": _timesNapped, "Time it Took to Fall Asleep": _timeFellAsleep};
    databaseReference.add(data);
  }

  Future<DocumentSnapshot> retrieveData() async{
    return databaseReference.doc("1").get();
  }

  @override
  void onOptionChanged(int value, {required String qualityRatingString})  {

    if (value != _viewModel.value) {
      _viewModel.value = value;
      saveValue(_viewModel.value);
      var qualityRating= 0.0;
      if (!isEmptyString(qualityRatingString)) {
        try {
          qualityRating = double.parse(qualityRatingString);
        } catch (e) {
        }
      }
      /*
      if (!isEmptyString(fuelUsedString)) {
        try {
          fuelUsed = double.parse(fuelUsedString);
        } catch (e) {
        }
      }
 */
      _view.updateUnit(_viewModel.value);
      _view.updateResultValue(_viewModel.resultInString);
    }
  }


  @override
  void onQualityRatingSubmitted(String qualityRating) {
    try{
      _viewModel.qualityRating = double.parse(qualityRating);
    }catch(e){

    }
  }
}

class SleepDiaryPresenter {
  final databaseReference = FirebaseFirestore.instance.collection('Sleep Diaries');

  void archiveEntries(String _diaryEntryOne, String _diaryEntryTwo, String _diaryEntryThree, String _diaryEntryFour, String _diaryEntryFive, String _behaviorEntryOne, String _behaviorEntryTwo, String _behaviorEntryThree, String _behaviorEntryFour, String _behaviorEntryFive) {
    final data = {
      "Sleep Diary Entry 1": _diaryEntryOne,
      "Sleep Diary Entry 2": _diaryEntryTwo,
      "Sleep Diary Entry 3": _diaryEntryThree,
      "Sleep Diary Entry 4": _diaryEntryFour,
      "Sleep Diary Entry 5": _diaryEntryFive,
      "Behavior Entry 1": _behaviorEntryOne,
      "Behavior Entry 2": _behaviorEntryTwo,
      "Behavior Entry 3": _behaviorEntryThree,
      "Behavior Entry 4": _behaviorEntryFour,
      "Behavior Entry 5": _behaviorEntryFive,
    };
    databaseReference.add(data);
  }

  void removeEntry() {
    databaseReference.doc("1").delete();
  }
}

class SleepDiaryHistoryPresenter {}

class SleepMusicPresenter {}

class SleepGraphPresenter {}

class SettingPresenter {}

class NotificationSettingPresenter {}

class SleepInfoPresenter {}

class SleepBenefitsPresenter {}

class SleepAdvicePresenter {}
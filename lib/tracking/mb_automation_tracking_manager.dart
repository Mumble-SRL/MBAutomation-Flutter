import 'dart:async';

class MBAutomationTrackingManager {
  static final MBAutomationTrackingManager shared =
      MBAutomationTrackingManager._internal();

  MBAutomationTrackingManager._internal();

  int _timerTime = 10;

  set timerTime(int timerTime) {
    _timerTime = timerTime;
    if (_timer != null) {
      _timer.cancel();
      startTimer();
    }
  }

  int get timerTimer => _timerTime;

  Timer _timer;

  bool _sendingData = false;

  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(
      Duration(seconds: _timerTime),
      (timer) => _checkQueue(),
    );
  }

  void stopTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }

  void _checkQueue() {
    // If already sending data skip this cycle and do the task on next
    if (_sendingData) {
      return;
    }
    _sendingData = true;
    //TODO: check queue
    print('Check queue');
  }
}

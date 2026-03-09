import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class MeditationSession {
  final DateTime date;
  final Duration duration;

  MeditationSession({required this.date, required this.duration});
}

class TimerProvider with ChangeNotifier {
  int _defaultDurationSeconds = 25 * 60; // 25 minutes
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<MeditationSession> _history = [];

  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  List<MeditationSession> get history => _history;

  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void setTimer(int minutes, int seconds) {
    if (_isRunning) _pauseTimer();
    _defaultDurationSeconds = minutes * 60 + seconds;
    _remainingSeconds = _defaultDurationSeconds;
    notifyListeners();
  }

  Duration getTotalMeditationTime() {
    return _history.fold(Duration.zero, (prev, session) => prev + session.duration);
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _playChime();
        _stopTimerAndSave();
      }
    });
    notifyListeners();
  }

  void _pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void rewind10Seconds() {
    _remainingSeconds = (_remainingSeconds + 10).clamp(0, _defaultDurationSeconds);
    notifyListeners();
  }

  void forward10Seconds() {
    _remainingSeconds = (_remainingSeconds - 10).clamp(0, _defaultDurationSeconds);
    if (_remainingSeconds == 0) {
       _playChime();
       _stopTimerAndSave();
    }
    notifyListeners();
  }

  Future<void> _playChime() async {
    await _audioPlayer.play(AssetSource('audio/bowl_chime.mp3'));
  }

  void _stopTimerAndSave() {
    _pauseTimer();
    // Save session
    _history.add(MeditationSession(
      date: DateTime.now(),
      duration: Duration(seconds: _defaultDurationSeconds - _remainingSeconds),
    ));
    _remainingSeconds = _defaultDurationSeconds; // Reset
    notifyListeners();
  }

  // Helper for mock data later if needed
  void addMockSession(MeditationSession session) {
    _history.add(session);
    notifyListeners();
  }
}

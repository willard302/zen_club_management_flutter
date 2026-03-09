import 'package:flutter/material.dart';

enum EventType { meditation, workshop, meeting, birthday }

class ClubEvent {
  final String id;
  final String title;
  final String location;
  final DateTime dateTime;
  final int participants;
  final EventType type;
  final IconData icon;

  ClubEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.participants,
    required this.type,
    required this.icon,
  });
}

class CalendarProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime(2023, 11, 10); // Mocking active date to match design
  
  final List<ClubEvent> _events = [
    ClubEvent(
      id: "1",
      title: "早晨禪定",
      location: "主大廳",
      dateTime: DateTime(2023, 11, 10, 9, 0),
      participants: 45,
      type: EventType.meditation,
      icon: Icons.self_improvement,
    ),
    ClubEvent(
      id: "2",
      title: "園藝工作坊",
      location: "戶外露台",
      dateTime: DateTime(2023, 11, 10, 14, 30),
      participants: 12,
      type: EventType.workshop,
      icon: Icons.eco,
    ),
    ClubEvent(
      id: "3",
      title: "委員會會議",
      location: "會議室",
      dateTime: DateTime(2023, 11, 10, 18, 0),
      participants: 8,
      type: EventType.meeting,
      icon: Icons.group,
    ),
    // Mock birthday for demonstration on another day (e.g. Nov 4)
    ClubEvent(
      id: "4",
      title: "Alex 的生日",
      location: "社團休息室",
      dateTime: DateTime(2023, 11, 4),
      participants: 0,
      type: EventType.birthday,
      icon: Icons.cake,
    ),
     ClubEvent(
      id: "5",
      title: "Sam 的生日",
      location: "社團休息室",
      dateTime: DateTime(2023, 11, 14),
      participants: 0,
      type: EventType.birthday,
      icon: Icons.cake,
    ),
    ClubEvent(
      id: "6",
      title: "Kim 的生日",
      location: "社團休息室",
      dateTime: DateTime(2023, 11, 17),
      participants: 0,
      type: EventType.birthday,
      icon: Icons.cake,
    ),
  ];

  DateTime get selectedDate => _selectedDate;

  List<ClubEvent> getEventsForDate(DateTime date) {
    return _events.where((e) => isSameDay(e.dateTime, date)).toList();
  }

  bool hasEvents(DateTime date) {
    return _events.any((e) => isSameDay(e.dateTime, date));
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

import 'package:campus_updates/Models/club.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final dateFormatter = DateFormat.yMd();
final timeFormatter = DateFormat.Hm();
class Event {
  Event({
    required this.title,
    required this.club,
    required this.date,
    required this.id,
    this.description = '',
  });

  final String title;
  final Club club;
  final DateTime date;
  final String id;
  final String description;
  String get formattedDate {
    return dateFormatter.format(date);
  }
  String get formattedTime {
    return timeFormatter.format(date);
  }
}

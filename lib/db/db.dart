import 'dart:typed_data';

import 'package:hive/hive.dart';
part 'db.g.dart';

@HiveType(typeId: 1)
class Email {
  Email(
      {required this.sender,
      required this.reciever,
      required this.title,
      required this.description});

  @HiveField(0)
  Account sender;

  @HiveField(1)
  Account reciever;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;
}

@HiveType(typeId: 2)
class Account {
  Account(
      {required this.email,
      required this.name,
      this.password,
      this.id,
      required this.events});
  @HiveField(0)
  String email;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? password;

  @HiveField(3)
  String? id;

  @HiveField(4)
  List<Event> events;
}

// item, location, timeEnding, description
@HiveType(typeId: 3)
class Event {
  Event(
      {required this.item,
      required this.latitude,
      required this.longitude,
      required this.timeEnding,
      required this.description,
      required this.imgs,
      required this.userEmail,
      this.rsvpee, this.rsvpTime});

  @HiveField(0)
  String item;

  @HiveField(1)
  double latitude;

  @HiveField(2)
  double longitude;

  @HiveField(3)
  DateTime timeEnding;

  @HiveField(4)
  String description;

  @HiveField(5)
  List<String> imgs;

  @HiveField(6)
  String userEmail;

  @HiveField(7)
  Account? rsvpee;

  @HiveField(8)
  DateTime? rsvpTime;
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import '../db/db.dart';

// ignore: must_be_immutable
class EventDescript extends StatelessWidget {
  EventDescript(
      {Key? key,
      required this.e,
      required this.currLocation,
      required this.placemark,
      required this.user})
      : super(key: key);

  Account user;
  Event e;
  LatLng currLocation;
  Placemark placemark;

  final Box box = Hive.box("events12");
  final Box box2 = Hive.box("accounts10");
  final Box box3 = Hive.box("emails5");

  static const double latitudeRatio = 68.93; // one degree of latitude to mi
  static const double longitudeRatio = 54.58;

  final titleController = TextEditingController();
  final descController = TextEditingController();

  String? _title;
  String? _description;
  DateTime? _dateTime;
  TimeOfDay? _time;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );
    if (newTime != null) {
      _time = newTime;
    }
  }

  // for rsvp
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 7)));

    if (picked != null && picked != _dateTime) {
      _dateTime = picked;
    }
  }

  Widget _showMessage(BuildContext context, Event e) {
    return Scaffold(
      appBar: AppBar(
          title: Text("dddd", style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xffb099e1)),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.title), labelText: "Title"),
              maxLines: 1,
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.title), labelText: "Description"),
              maxLines: 2,
            ),
            TextButton(
                child: const Text("SUBMIT"),
                onPressed: () {
                  Account eAcc = box2.get(e.userEmail);
                  Email newEmail = Email(
                      sender: user,
                      reciever: eAcc,
                      title: _title as String,
                      description: _description as String);
                  box3.put(DateTime.now().toString(), newEmail);
                  Navigator.pop(context, true);
                })
          ],
        ),
      ),
    );
  }

  Widget _showRSVP(BuildContext context, Event e) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dddd", style: GoogleFonts.lexend()),
        backgroundColor: const Color(0xffb099e1),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.title), labelText: "Title"),
            maxLines: 1,
          ),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.title), labelText: "Description"),
            maxLines: 2,
          ),
          Center(
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: (() => _selectDate(context).then),
                    child: const Text("Select Date"),
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xff99cae1))),
                ElevatedButton(
                    onPressed: (() => _selectTime(context).then),
                    child: const Text("Select Time"),
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xff99cae1))),
              ],
            ),
          ),
          TextButton(
              child: const Text("Submit"),
              onPressed: () {
                if (_dateTime != null && _time != null) {
                  Account eAcc = box2.get(e.userEmail);
                  DateTime dt = DateTime(_dateTime!.year, _dateTime!.month,
                      _dateTime!.day, _time!.hour, _time!.minute);
                  e.rsvpTime = dt;
                  e.rsvpee = user;
                  Email newEmail = Email(
                      sender: eAcc,
                      reciever: user,
                      title: "${user.name} has RSVPed for ${e.item}",
                      description: e.rsvpTime.toString());
                  box3.put(DateTime.now().toString(), newEmail);
                  Navigator.pop(context, true);
                }
              })
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double heightScreen = MediaQuery.of(context).size.height;
    final double widthScreen = MediaQuery.of(context).size.width;
    double diffLat = (currLocation.latitude - e.latitude).abs() * latitudeRatio;
    double diffLong =
        (currLocation.longitude - e.longitude).abs() * longitudeRatio;
    String dist =
        (sqrt((diffLat * diffLat) + (diffLong * diffLong))).toStringAsFixed(2);
    return Scaffold(
        appBar: AppBar(
            title: Text(
              e.item,
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: const Color(0xffb099e1)),
        body: Column(children: [
          SizedBox(
              child: GridView.builder(
                primary: false,
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10),
                itemCount: e.imgs.length,
                itemBuilder: (context, index) {
                  return Image.memory(base64Decode(e.imgs[index]));
                },
              ),
              height: heightScreen * 0.3,
              width: widthScreen),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
          Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(children: [
                        Center(
                          child: Text(
                            e.item,
                            style: GoogleFonts.lexend(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        SizedBox(
                          height: 75,
                          width: 150,
                          child: Text(
                            placemark.street! +
                                ", " +
                                placemark.locality! +
                                ", " +
                                placemark.administrativeArea! +
                                " " +
                                placemark.postalCode!,
                            style: GoogleFonts.lexend(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(4)),
                        Text(dist + "mi",
                            style: GoogleFonts.lexend(
                                fontWeight: FontWeight.w200, fontSize: 18)),
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                              e.latitude,
                              e.longitude,
                            ),
                            zoom: 14),
                        markers: {
                          Marker(
                              position: LatLng(e.latitude, e.longitude),
                              markerId: MarkerId("${e.latitude}${e.longitude}"))
                        },
                        indoorViewEnabled: true,
                        trafficEnabled: true),
                  )
                ]),
          ),
          Expanded(
              child: Center(
                  child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Description:", style: GoogleFonts.montserrat()),
              Text(
                e.description,
                style: GoogleFonts.montserrat(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              Text(
                  "Listing ends on ${e.timeEnding.month}/${e.timeEnding.day}/${e.timeEnding.year}",
                  style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w200, fontSize: 12)),
              (e.userEmail != user.email)
                  ? (e.rsvpee == null)
                      ? Row(
                          children: [
                            Expanded(
                                child: Center(
                                  child: Text(
                                    e.userEmail,
                                    style: GoogleFonts.lexend(fontSize: 16),
                                    softWrap: true,
                                  ),
                                ),
                                flex: 3),
                            Expanded(
                              child: TextButton(
                                  child: const Text("Message"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                _showMessage(context, e))));
                                  }),
                              flex: 1,
                            ),
                            Expanded(
                              child: TextButton(
                                  child: const Text("RSVP"),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                _showRSVP(context, e))));
                                  }),
                              flex: 1,
                            ),
                          ],
                        )
                      : Text("This event has already been RSVPed!",
                          style: GoogleFonts.montserrat())
                  : Text("This is your listing!",
                      style: GoogleFonts.montserrat())
            ],
          ))),
        ]));
  }
}

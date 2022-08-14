import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../db/db.dart';
import 'package:hive/hive.dart';
import '../login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../components/eventDescript.dart';
import 'dart:convert';

class Profile extends StatelessWidget {
  Profile({Key? key, required this.user}) : super(key: key);

  final Account user;

  final Box emailsBox = Hive.box("emails5");
  final Box eventsBox = Hive.box("events12");

  final AssetImage? defaultImage = const AssetImage('assets/default_photo.jpg');

  Future<LatLng> determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return LatLng(position.latitude, position.longitude);
  }

  Widget eventsMade(BuildContext context) {
    List<Event> _events = user.events;

    Widget _buildRow(int index) {
      return ListTile(
          leading: ConstrainedBox(
              constraints: const BoxConstraints(
                  minHeight: 50, maxHeight: 50, minWidth: 50, maxWidth: 50),
              child: Image.memory(base64Decode(_events[index].imgs.first))),
          title: Column(
            children: [
              Text(_events[index].item,
                  style: GoogleFonts.lexend(fontSize: 16)),
              Text(_events[index].description,
                  style: GoogleFonts.lexend(fontSize: 10)),
              (_events[index].rsvpee != null)
                  ? Text(
                      "${_events[index].rsvpee} will come at ${_events[index].rsvpTime.toString()}",
                      style: GoogleFonts.lexend(fontSize: 10))
                  : (_events[index].timeEnding.isAfter(DateTime.now()))
                      ? Text("No RSVP yet, check back later!",
                          style: GoogleFonts.lexend(fontSize: 10))
                      : Text("No one RSVPed before the deadline.",
                          style: GoogleFonts.lexend(fontSize: 10))
            ],
          ),
          onTap: () async {
            if (_events[index].timeEnding.isAfter(DateTime.now())) {
              List<Placemark> p = await placemarkFromCoordinates(
                  _events[index].latitude, _events[index].longitude);
              Placemark fp = p.first;
              LatLng curr = await determinePosition();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: ((context) => EventDescript(
                          e: _events[index],
                          currLocation: curr,
                          placemark: fp,
                          user: user))));
            }
          });
    }

    return Scaffold(
      appBar: AppBar(
          title: Text("Events", style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xffb099e1)),
      body: (_events.isNotEmpty)
          ? ListView.builder(
              itemCount: _events.length * 2,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int i) {
                if (i.isOdd) {
                  return const Divider(color: Color(0xffcae199), thickness: 2);
                }
                final index = i ~/ 2;
                return _buildRow(_events.length - index - 1);
              })
          : const Center(child: Text("You haven't made any events!")),
    );
  }

  Widget upcomingRSVPs(BuildContext context) {
    Iterable<Event> _events = eventsBox.values.cast();
    List<Event> _available = [];

    for (Event e in _events) {
      if (e.rsvpee != null) {
        if (e.rsvpee == user) {
          _available.add(e);
        }
      }
    }

    Widget _buildRow(int index) {
      return ListTile(
          leading: ConstrainedBox(
              constraints: const BoxConstraints(
                  minHeight: 50, maxHeight: 50, minWidth: 50, maxWidth: 50),
              child: Image.memory(base64Decode(_available[index].imgs.first))),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(_available[index].item,
                  style: GoogleFonts.lexend(fontSize: 16)),
              Text(_available[index].description,
                  style: GoogleFonts.lexend(fontSize: 10)),
              (_available[index].rsvpee != null)
                  ? Text(
                      "${_available[index].rsvpee!.name} will come at ${_available[index].rsvpTime.toString()}",
                      style: GoogleFonts.lexend(fontSize: 10))
                  : (_available[index].timeEnding.isAfter(DateTime.now()))
                      ? const Text("No RSVP yet, check back later!")
                      : const Text("No one RSVPed before the deadline.")
            ],
          ),
          onTap: () async {
            List<Placemark> p = await placemarkFromCoordinates(
                _available[index].latitude, _available[index].longitude);
            Placemark fp = p.first;
            LatLng curr = await determinePosition();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: ((context) => EventDescript(
                        e: _available[index],
                        currLocation: curr,
                        placemark: fp,
                        user: user))));
          });
    }

    return Scaffold(
      appBar: AppBar(
          title: Text("RSVPs", style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xffb099e1)),
      body: (_available.isNotEmpty)
          ? ListView.builder(
              itemCount: _available.length * 2,
              padding: const EdgeInsets.all(16),
              itemBuilder: (BuildContext context, int i) {
                if (i.isOdd) {
                  return const Divider(color: Color(0xffcae199), thickness: 2);
                }
                final index = i ~/ 2;
                return _buildRow(_available.length - index - 1);
              })
          : const Center(child: Text("You haven't RSVPed for anything!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Profile", style: GoogleFonts.lexend()),
            backgroundColor: const Color(0xffb099e1)),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Container(
              color: Colors.grey[300],
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 16)),
                  CircleAvatar(foregroundImage: defaultImage, radius: 32),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 32)),
                  Column(
                    children: [
                      Text(user.name, style: GoogleFonts.lexend()),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                      Text(user.email, style: GoogleFonts.lexend()),
                    ],
                  ),
                ],
              ),
            ),
            Container(
                color: Colors.grey[200],
                child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => eventsMade(context))),
                    child: const Text("Events"))),
            Container(
                color: Colors.grey[200],
                child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => upcomingRSVPs(context))),
                    child: const Text("RSVPs"))),
            TextButton(
                child: const Text("log out!"),
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Login()),
                    ((route) => false)))
          ],
        ));
  }
}

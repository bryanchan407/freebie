import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_checklist/components/eventDescript.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../db/db.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';

class SearchEvents extends SearchDelegate<String> {
  final double latitudeRatio = 68.93; // one degree of latitude to mi
  final double longitudeRatio = 54.58;
  final List<Event> events;
  final Account user;
  final LatLng currentLocation;

  SearchEvents(
      {required this.events,
      required this.user,
      required this.currentLocation});

  Future returnPlacemarks() async {
    List<Placemark> placemarks = [];
    final Iterable<Event> _list = events.cast();
    for (Event e in _list) {
      if (e.timeEnding.isAfter(DateTime.now())) {
        List<Placemark> _placemarks =
            await placemarkFromCoordinates(e.latitude, e.longitude);
        placemarks.add(_placemarks.first);
      }
    }
    return placemarks;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, query);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<String> eventsString =
        events.map((event) => event.item).toList();
    final List<String> allEvents = eventsString
        .where((event) => event.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: allEvents.length,
      itemBuilder: (context, index) => ListTile(
          title: Text(allEvents[index]),
          onTap: () {
            query = allEvents[index];
            close(context, query);
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<String> eventsString =
        events.map((event) => event.item).toList();
    final List<String> _eventSuggestions = eventsString
        .where((eventS) => eventS.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return FutureBuilder(
        future: returnPlacemarks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasError) {
              return const Text("Something went wrong.");
            }
            List<Placemark> innerPlacemarks = snapshot.data as List<Placemark>;
            return ListView.builder(
                itemCount: _eventSuggestions.length,
                itemBuilder: (context, index) => ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_eventSuggestions[index],
                              style: GoogleFonts.lexend(fontSize: 18)),
                          Text(
                              innerPlacemarks[index].street! +
                                  ", " +
                                  innerPlacemarks[index].locality! +
                                  ", " +
                                  innerPlacemarks[index].administrativeArea! +
                                  ' ' +
                                  innerPlacemarks[index].postalCode!,
                              style: GoogleFonts.lexend(
                                  fontSize: 14, color: Colors.grey)),
                          Text(events[index].description,
                              style: GoogleFonts.lexend(
                                  fontSize: 12, color: Colors.black))
                        ],
                      ),
                      leading: ConstrainedBox(
                          constraints: const BoxConstraints(
                              minHeight: 50,
                              maxHeight: 50,
                              minWidth: 50,
                              maxWidth: 50),
                          child: Image.memory(
                              base64Decode(events[index].imgs.first))),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => EventDescript(
                                  e: events[index],
                                  currLocation: currentLocation,
                                  placemark: innerPlacemarks[index],
                                  user: user)))),
                    ));
          } else if (snapshot.hasError) {
            return const Text("Something went wrong.");
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

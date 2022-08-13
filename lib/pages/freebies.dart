import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import '../db/db.dart';
import '../components/eventDescript.dart';

class FreebieDash extends StatelessWidget {
  FreebieDash({Key? key, required this.user, required this.type})
      : super(key: key);

  final bool type;
  final Account user;
  final Box box = Hive.box("events11");
  final Box box2 = Hive.box("accounts10");
  final Box box3 = Hive.box("emails5");

  final double latitudeRatio = 68.93; // one degree of latitude to mi
  final double longitudeRatio = 54.57;

  GoogleMapController? mapController;

  LatLng? latlng;

  List<Marker> _listOfMarkers = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<LatLng> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    return LatLng(position.latitude, position.longitude);
  }

  Future addMarkers(BuildContext context) async {
    LatLng l = await determinePosition();
    final Iterable<Event> _list = box.values.cast();
    for (Event e in _list) {
      if (e.timeEnding.isAfter(DateTime.now()) && e.rsvpee == null) {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(e.latitude, e.longitude);
        double diffLat = (l.latitude - e.latitude).abs() * latitudeRatio;
        double diffLong = (l.longitude - e.longitude).abs() * longitudeRatio;
        String dist = (sqrt((diffLat * diffLat) + (diffLong * diffLong)))
            .toStringAsFixed(1);
        Marker placeholder = Marker(
            markerId: MarkerId(e.item),
            infoWindow: InfoWindow(title: "${e.item} ($dist mi away)"),
            icon: (e.userEmail == user.email)
                ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen)
                : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
            position: LatLng(e.latitude, e.longitude),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventDescript(
                          user: user,
                          e: e,
                          placemark: placemarks.first,
                          currLocation: l)));
            });
        _listOfMarkers.add(placeholder);
      }
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: addMarkers(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.hasError) {
              return const Text("Something went wrong.");
            }
            LatLng loc = snapshot.data as LatLng;
            Marker currentLocation = Marker(
                markerId: const MarkerId("Current location"),
                infoWindow: const InfoWindow(title: "Current location"),
                icon: BitmapDescriptor.defaultMarker,
                position: loc,
                onTap: () {});

            return GoogleMap(
              markers: {currentLocation, ..._listOfMarkers},
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(target: loc, zoom: 14),
              onMapCreated: _onMapCreated,
            );
          } else if (snapshot.hasError) {
            return const Text("Something went wrong.");
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

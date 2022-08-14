

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_checklist/components/search.dart';
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../components/email.dart';

import 'freebies.dart';
import 'profile.dart';
import '/db/db.dart';
import '../components/thrift.dart';

import 'dart:async';
import 'package:geolocator/geolocator.dart';

class Dashboard extends StatefulWidget {
  final Account user;
  Dashboard({Key? key, required this.user}) : super(key: key);

  final Box box2 = Hive.box("accounts10");
  final Box box = Hive.box("events12");

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 0;
  bool listingType = false; // false for map, true for list

  final _formKey = GlobalKey<FormState>();

  String? _eventName;
  LatLng? _coordinates;
  DateTime? _dateTime;
  String? _description;

  List<String> _images = [];
  List<Widget> insertedWidgets = [];

  final ImagePicker picker = ImagePicker();

  Future<LatLng> determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 7)));

    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
      });
    }
  }

  Future _pickImage(bool type) async {
    try {
      XFile? image;
      if (type) {
        image = await picker.pickImage(source: ImageSource.camera);
      } else {
        image = await picker.pickImage(source: ImageSource.gallery);
      }
      if (image == null) return;

      final File imageTemporary = File(image.path);
      List<int> imageBytes = imageTemporary.readAsBytesSync();
      return base64Encode(imageBytes);
    } on PlatformException catch (e) {
      throw 'Failed to pick image: $e';
    }
  }

  Widget createEvent() {
    double paddingSize = 16;
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Listing", style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xffb099e1),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.symmetric(vertical: paddingSize)),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.local_shipping),
                      hintText: 'What are you giving away?',
                      labelText: 'Item Name',
                    ),
                    onSaved: (String? value) => _eventName = value,
                    validator: (String? value) {
                      if (value?.isEmpty ?? false) {
                        return 'Name is required.';
                      }
                      final RegExp nameExp = RegExp(r'^[A-Za-z ]+$');
                      if (!nameExp.hasMatch(value!)) {
                        return 'Please enter only alphabetical characters.';
                      }
                      return null;
                    },
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: paddingSize)),
                  ElevatedButton(
                      onPressed: (() => _selectDate(context).then),
                      child: const Text("Select Date"),
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0xff99cae1))),
                  Padding(padding: EdgeInsets.symmetric(vertical: paddingSize)),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.person),
                      hintText: 'Where are you giving away your item?',
                      labelText: 'Location',
                    ),
                    onSaved: (String? value) async {
                      List<Location> locations =
                          await locationFromAddress(value as String);
                      _coordinates = LatLng(
                          locations.first.latitude, locations.first.longitude);
                    },
                    validator: (String? value) {
                      if (value?.isEmpty ?? false) {
                        return 'Address is required.';
                      }
                      final RegExp nameExp = RegExp(
                          '/[0-9]+ [a-zA-Z]+ [a-zA-Z]+, [a-zA-Z]+, [a-zA-Z]+ [0-9]+/gm');
                      if (!nameExp.hasMatch(value!)) {
                        return 'Please enter an address in the correct format';
                      }
                      return null;
                    },
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24)),
                  TextFormField(
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        filled: true,
                        hintText: "Give a description of your item",
                        labelText: "Description"),
                    maxLines: 4,
                    onSaved: (String? value) {
                      _description = value;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          child: const Text("Take image"),
                          onPressed: () async {
                            _pickImage(true).then((result) {
                              setState(() => {_images.add(result)});
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              primary: const Color(0xff99cae1))),
                      ElevatedButton(
                          child: const Text("Select image"),
                          onPressed: () async {
                            _pickImage(false).then((result) {
                              setState(() => {_images.add(result)});
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              primary: const Color(0xff99cae1))),
                    ],
                  ),
                  ElevatedButton(
                      child: const Text("Submit"),
                      onPressed: () {
                        Form.of(primaryFocus!.context!)!.save();
                        if (_eventName != null &&
                            _coordinates != null &&
                            _description != null &&
                            _dateTime != null &&
                            _images.isNotEmpty) {
                          List<Event> eventTable = widget.user.events;
                          Event event = Event(
                            description: _description as String,
                            latitude: _coordinates!.latitude,
                            longitude: _coordinates!.longitude,
                            item: _eventName as String,
                            timeEnding: _dateTime as DateTime,
                            imgs: List.from(_images), //FIXED: I referenced the _events in the db and it made the photos for every listing the same. This instead creates a copy and stores it in the db :)
                            userEmail: widget.user.email,
                          );
                          eventTable.add(event);
                          widget.box
                              .put(DateTime.now().toUtc().toString(), event);
                          widget.user.events = eventTable;
                          Navigator.pop(context, false);

                          setState(() {
                            _images.clear();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0xff99cae1)))
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffb099e1),
        title: Text(
          "Freebie",
          style: GoogleFonts.lexend(),
        ),
        leading: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(user: widget.user)))),
        actions: [
          IconButton(
              icon: const Icon(Icons.storefront),
              onPressed: () async {
                LatLng ll = await determinePosition();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ThriftPage(coord: ll)));
              }),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EmailW(user: widget.user))),
          ),
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                showSearch(
                    context: context,
                    delegate: SearchEvents(
                      events: widget.box.values
                          .map((event) => event as Event)
                          .where((e) => e.timeEnding.isAfter(DateTime.now()))
                          .toList(),
                      user: widget.user,
                      currentLocation: await determinePosition(),
                    ));
              }),
        ],
      ),
      body: SizedBox.expand(
          child: FreebieDash(user: widget.user, type: listingType)),
      backgroundColor: Colors.grey,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => createEvent())),
        child: const Icon(Icons.add, color: Colors.black),
        backgroundColor: const Color(0xff99cae1),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

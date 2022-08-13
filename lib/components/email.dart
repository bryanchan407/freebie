import '../db/db.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailW extends StatefulWidget {
  EmailW({Key? key, required this.user}) : super(key: key);

  final Account user;

  final Box emailsBox = Hive.box("emails5");

  @override
  State<EmailW> createState() => _EmailWState();
}

class _EmailWState extends State<EmailW> {
  AssetImage? defaultImage = const AssetImage('assets/default_photo.jpg');

  Widget inbox() {
    List<Email> emails = [];
    for (Email e in widget.emailsBox.values) {
      if (e.reciever.email == widget.user.email) {
        emails.add(e);
      }
    }

    Widget _buildRow(int index) {
      return ListTile(
        leading: CircleAvatar(
          foregroundImage: defaultImage,
        ),
        title: Column(
          children: [
            Text(emails[index].reciever.email,
                style: GoogleFonts.lexend(fontSize: 16)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            Text(emails[index].title, style: GoogleFonts.lexend(fontSize: 12)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            Text(emails[index].description,
                style: GoogleFonts.lexend(fontSize: 10))
          ],
        ),
      );
    }

    return ListView.builder(
        itemCount: emails.length * 2,
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext context, int i) {
          if (i.isOdd) {
            return const Divider(color: Color(0xffcae199), thickness: 2);
          }
          final index = i ~/ 2;
          return _buildRow(emails.length - index - 1);
        });
  }

  Widget sent() {
    List<Email> emails = [];

    for (Email e in widget.emailsBox.values) {
      if (e.sender.email == widget.user.email) {
        emails.add(e);
      }
    }

    Widget _buildRow(int index) {
      return ListTile(
        leading: CircleAvatar(
          foregroundImage: defaultImage,
        ),
        title: Column(
          children: [
            Text(emails[index].sender.email,
                style: GoogleFonts.lexend(fontSize: 16)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            Text(emails[index].title, style: GoogleFonts.lexend(fontSize: 12)),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            Text(emails[index].description,
                style: GoogleFonts.lexend(fontSize: 10))
          ],
        ),
      );
    }

    return ListView.builder(
        itemCount: emails.length * 2,
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext context, int i) {
          if (i.isOdd) {
            return const Divider(color: Color(0xffcae199), thickness: 2);
          }
          final index = i ~/ 2;
          return _buildRow(emails.length - index - 1);
        });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.email)),
                  Tab(icon: Icon(Icons.send_outlined))
                ],
              ),
              backgroundColor: const Color(0xffb099e1),
            ),
            body: TabBarView(
              children: [inbox(), sent()],
            )));
  }
}

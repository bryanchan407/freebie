import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ThriftPage extends StatelessWidget {
  const ThriftPage({Key? key, required this.coord}) : super(key: key);

  final LatLng coord;

  Widget searchBuilder(String txt, String _uri, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
              Flexible(child: Text(txt)),
              IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final Uri uri = Uri.parse(
                        _uri);
                    if (await canLaunchUrl(uri)) {
                      launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Could not launch"),
                      ));
                    }
                  })]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Other Options", style: GoogleFonts.lexend()),
        backgroundColor: const Color(0xffb099e1),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              searchBuilder("Donate to a thrift store:", "https://www.google.com/maps/search/thrift+store/@${coord.latitude},${coord.longitude},13z/data=!3m1!4b1", context),
              searchBuilder("Sell to a consignment store:", "https://www.google.com/maps/search/consignment+store/@${coord.latitude},${coord.longitude},13z/data=!3m1!4b1", context),
              searchBuilder("Donate books to a library:", "https://www.google.com/maps/search/library/@${coord.latitude},${coord.longitude},13z/data=!3m1!4b1", context),
              searchBuilder("Donate household goods to Habitat for Humanity:", "https://www.google.com/maps/search/habitat+for+humanity+restore/@${coord.latitude},${coord.longitude},13z/data=!3m1!4b1", context),
              searchBuilder("Donate baby toys and supplies to Baby2Baby:", "https://www.google.com/maps/search/baby+2+baby/@${coord.latitude},${coord.longitude},13z/data=!3m1!4b1", context),
              searchBuilder("Donate food to a food bank:", "https://www.google.com/maps/search/food+bank/@${coord.latitude},${coord.longitude},13z/data=!3m1!4b1", context),
              searchBuilder("Donate anything to a donation center:", "https://www.google.com/maps/search/donation+center/@${coord.latitude},${coord.longitude},13z/data=!3m1!4b1", context)
          ],
        ),
      ),
    );
  }
}

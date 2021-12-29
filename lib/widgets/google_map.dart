import 'package:flutter/material.dart';
import 'package:google_maps/google_maps.dart';
import 'dart:ui' as ui;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

class GoogleMap extends StatelessWidget {
  const GoogleMap({
    Key? key,
    required this.id,
    required this.locations,
  }) : super(key: key);

  final String id;
  final List<LatLng> locations;

  @override
  Widget build(BuildContext context) {
    String htmlId = id;

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      var mapOptions = MapOptions()
        ..zoom = 10
        ..center = locations.first;

      var elem = DivElement()
        ..id = htmlId
        ..style.width = "100%"
        ..style.height = "100%"
        ..style.border = 'none';

      var map = GMap(elem, mapOptions);

      for (LatLng item in locations) {
        Marker(
          MarkerOptions()
            ..position = item
            ..map = map,
        );
      }

      return elem;
    });

    return HtmlElementView(viewType: htmlId);
  }
}

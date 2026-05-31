import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

Future<List<LatLng>> getRoadRoute(List<LatLng> waypoints) async {
  log('Way Points LatLng   $waypoints');
  if (waypoints.length < 2) return [];

  final coords = waypoints
      .map((p) => '${p.longitude.toStringAsFixed(6)},${p.latitude.toStringAsFixed(6)}')
      .join(';');

  final url = 'https://router.project-osrm.org/route/v1/driving/'
      '$coords?overview=full&geometries=polyline';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['code'] == 'Ok' &&
          data['routes'] != null &&
          data['routes'].isNotEmpty) {
        final geometry = data['routes'][0]['geometry'] as String;
        return _decodePolyline(geometry);
      }
    }
  } catch (e) {
    log('OSRM route error: $e');
  }
  return [];
}

List<LatLng> _decodePolyline(String encoded) {
  final List<LatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int shift = 0, result = 0;
    int b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    poly.add(LatLng(lat / 1E5, lng / 1E5));
  }
  return poly;
}

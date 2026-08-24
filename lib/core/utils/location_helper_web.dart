// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_location_address.dart';

Future<UserLocationAddress> detectUserLocationAddress() async {
  if (html.window.navigator.geolocation == null) {
    return UserLocationAddress(error: 'Geolocation is not supported by this browser.');
  }

  try {
    final html.Geoposition position = await html.window.navigator.geolocation!.getCurrentPosition(
      enableHighAccuracy: true,
      timeout: const Duration(seconds: 10),
    );

    final double? lat = position.coords?.latitude?.toDouble();
    final double? lng = position.coords?.longitude?.toDouble();

    if (lat == null || lng == null) {
      return UserLocationAddress(error: 'Could not retrieve location coordinates.');
    }

    final Uri url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng');
    final response = await http.get(url, headers: {'User-Agent': 'CosmyraApp/1.0'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final Map<String, dynamic> addr = data['address'] as Map<String, dynamic>? ?? {};

      final String road = (addr['road'] ?? addr['residential'] ?? addr['pedestrian'] ?? addr['suburb'] ?? '').toString();
      final String neighbourhood = (addr['neighbourhood'] ?? addr['suburb'] ?? addr['quarter'] ?? '').toString();
      final String houseNo = (addr['house_number'] ?? '').toString();

      final String fullStreet = [houseNo, road, neighbourhood]
          .where((s) => s.trim().isNotEmpty)
          .join(', ');

      final String city = (addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['county'] ?? addr['state_district'] ?? '').toString();
      final String state = (addr['state'] ?? '').toString();
      final String pincode = (addr['postcode'] ?? '').toString();
      final String country = (addr['country'] ?? '').toString();

      return UserLocationAddress(
        street: fullStreet.isNotEmpty ? fullStreet : (data['display_name'] ?? ''),
        city: city,
        state: state,
        pincode: pincode,
        country: country,
        latitude: lat,
        longitude: lng,
      );
    } else {
      return UserLocationAddress(
        latitude: lat,
        longitude: lng,
        error: 'Failed to reverse geocode location.',
      );
    }
  } catch (e) {
    return UserLocationAddress(
      error: 'Location access denied or unavailable. Please allow location permission in your browser.',
    );
  }
}

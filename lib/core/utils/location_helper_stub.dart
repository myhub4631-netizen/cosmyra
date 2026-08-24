import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'user_location_address.dart';

Future<UserLocationAddress> detectUserLocationAddress() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return UserLocationAddress(
      error: 'Location services are disabled on your device. Please turn on GPS location.',
    );
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return UserLocationAddress(
        error: 'Location permission was denied. Please grant location permission to autofill address.',
      );
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return UserLocationAddress(
      error: 'Location permissions are permanently denied in device settings. Please enable location permission.',
    );
  }

  try {
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );

    final double lat = position.latitude;
    final double lng = position.longitude;

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
        error: 'Failed to reverse geocode location coordinates.',
      );
    }
  } catch (e) {
    return UserLocationAddress(
      error: 'Error retrieving device location. Please try again.',
    );
  }
}

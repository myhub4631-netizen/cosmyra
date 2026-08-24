import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('=== TESTING NOMINATIM REVERSE GEOCODING ===');
  // Sample coordinates for Kota, Rajasthan (25.2138, 75.8648)
  final double lat = 25.2138;
  final double lng = 75.8648;

  final Uri url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng');
  final response = await http.get(url, headers: {'User-Agent': 'CosmyraApp/1.0'});

  print('Status Code: ${response.statusCode}');
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    print('Display Name: ${data['display_name']}');
    print('Address Details: ${data['address']}');
  }

  print('\n=== TESTING IP GEOLOCATION FALLBACK ===');
  final ipUrl = Uri.parse('https://ipapi.co/json/');
  final ipRes = await http.get(ipUrl);
  print('IP Status: ${ipRes.statusCode}');
  if (ipRes.statusCode == 200) {
    final Map<String, dynamic> ipData = json.decode(ipRes.body);
    print('IP City: ${ipData['city']}, Region: ${ipData['region']}, Postcode: ${ipData['postal']}');
  }
}

import 'user_location_address.dart';

Future<UserLocationAddress> detectUserLocationAddress() async {
  return UserLocationAddress(
    error: 'Location detection is supported in Web & Mobile browsers.',
  );
}

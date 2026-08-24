import 'user_location_address.dart';
import 'location_helper_stub.dart'
    if (dart.library.html) 'location_helper_web.dart';

class LocationHelper {
  static Future<UserLocationAddress> getCurrentLocationAddress() {
    return detectUserLocationAddress();
  }
}

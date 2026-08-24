class UserLocationAddress {
  final String street;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? error;

  UserLocationAddress({
    this.street = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.country = '',
    this.latitude,
    this.longitude,
    this.error,
  });

  bool get hasError => error != null && error!.isNotEmpty;
}

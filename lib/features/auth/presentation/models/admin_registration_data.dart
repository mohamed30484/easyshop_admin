import 'dart:io';

class AdminRegistrationData {
  const AdminRegistrationData({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.nationalId = '',
    this.businessName = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.commercialRegister,
    this.taxCard,
    this.picture,
    this.password = '',
    this.passwordConfirmation = '',
  });

  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String businessName;
  final String address;
  final double? latitude;
  final double? longitude;
  final File? commercialRegister;
  final File? taxCard;
  final File? picture;
  final String password;
  final String passwordConfirmation;

  AdminRegistrationData copyWith({
    String? name,
    String? email,
    String? phone,
    String? nationalId,
    String? businessName,
    String? address,
    double? latitude,
    double? longitude,
    File? commercialRegister,
    File? taxCard,
    File? picture,
    String? password,
    String? passwordConfirmation,
  }) {
    return AdminRegistrationData(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      commercialRegister: commercialRegister ?? this.commercialRegister,
      taxCard: taxCard ?? this.taxCard,
      picture: picture ?? this.picture,
      password: password ?? this.password,
      passwordConfirmation: passwordConfirmation ?? this.passwordConfirmation,
    );
  }
}

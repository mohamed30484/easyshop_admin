import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  const AdminEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.businessName,
    this.address,
    this.latitude,
    this.longitude,
    this.commercialRegister,
    this.taxCard,
    this.picture,
  });

  final int id;
  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String businessName;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? commercialRegister;
  final String? taxCard;
  final String? picture;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    nationalId,
    businessName,
    address,
    latitude,
    longitude,
    commercialRegister,
    taxCard,
    picture,
  ];
}

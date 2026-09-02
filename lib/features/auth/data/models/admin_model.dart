import '../../domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  const AdminModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.nationalId,
    required super.businessName,
    super.address,
    super.latitude,
    super.longitude,
    super.commercialRegister,
    super.taxCard,
    super.picture,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      nationalId: json['national_id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      address: json['address']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      commercialRegister: json['commercial_register']?.toString(),
      taxCard: json['tax_card']?.toString(),
      picture: json['picture']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'national_id': nationalId,
      'business_name': businessName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'commercial_register': commercialRegister,
      'tax_card': taxCard,
      'picture': picture,
    };
  }
}

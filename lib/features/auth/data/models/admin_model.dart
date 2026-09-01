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
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      nationalId: json['national_id'] as String,
      businessName: json['business_name'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      commercialRegister: json['commercial_register'] as String?,
      taxCard: json['tax_card'] as String?,
      picture: json['picture'] as String?,
    );
  }
}

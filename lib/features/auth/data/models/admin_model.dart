import '../../../../core/utils/media_url_resolver.dart';
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
    // الـ API الفعلي بيرجّع الحقول دي باسم `..._url` (وكرابط كامل جاهز)،
    // مش بنفس اسم حقل الرفع (`picture`/`commercial_register`/`tax_card`).
    // بنجرّب اسم الـ `_url` الأول، وبعدين أسماء بديلة كـ fallback احتياطي.
    final rawPicture =
        json['picture_url'] ??
        json['picture'] ??
        json['profile_picture'] ??
        json['avatar'];
    final rawCommercialRegister =
        json['commercial_register_url'] ??
        json['commercial_register'] ??
        json['commercial_register_path'];
    final rawTaxCard =
        json['tax_card_url'] ?? json['tax_card'] ?? json['tax_card_path'];

    return AdminModel(
      id: _parseInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      nationalId: json['national_id']?.toString() ?? '',
      businessName: json['business_name']?.toString() ?? '',
      address: json['address']?.toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      commercialRegister: resolveMediaUrl(rawCommercialRegister),
      taxCard: resolveMediaUrl(rawTaxCard),
      picture: resolveMediaUrl(rawPicture),
    );
  }

  /// يحوّل القيمة لـ int سواء رجعت من الـ API كرقم أو كنص (Laravel أحيانًا
  /// بيرجّع الحقول الرقمية كـ String في الـ JSON).
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// نفس الفكرة لكن لـ double — بيحل مشكلة latitude/longitude لما
  /// تيجي كـ String بدل ما تيجي كـ number.
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
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

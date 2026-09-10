class UpdateProfileParams {
  const UpdateProfileParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.businessName,
    this.address,
    this.latitude,
    this.longitude,
    this.picturePath,
    this.commercialRegisterPath,
    this.taxCardPath,
  });

  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String businessName;
  final String? address;
  final double? latitude;
  final double? longitude;

  /// تكون null إذا المستخدم لم يغيّر صورة البروفايل،
  /// وبالتالي نحتفظ بالصورة القديمة في السيرفر.
  final String? picturePath;

  /// تكون null إذا المستخدم لم يختر ملف سجل تجاري جديد،
  /// وبالتالي نحتفظ بالملف القديم في السيرفر.
  final String? commercialRegisterPath;

  /// تكون null إذا المستخدم لم يختر ملف بطاقة ضريبية جديد،
  /// وبالتالي نحتفظ بالملف القديم في السيرفر.
  final String? taxCardPath;
}

import '../constants/api_constants.dart';

/// بيحوّل أي قيمة راجعة من الـ API لصورة أو مستند (picture / commercial_register
/// / tax_card) لرابط كامل قابل للعرض بـ `Image.network` أو الفتح في المتصفح.
///
/// بيتعامل مع الحالتين:
/// - لو القيمة أصلاً رابط كامل (`http://` أو `https://`) بيرجّعها زي ما هي.
/// - لو القيمة مسار نسبي (مثلاً `uploads/admins/xyz.jpg` أو
///   `/storage/uploads/admins/xyz.jpg`) بيبني رابط كامل بإضافة دومين السيرفر،
///   ويتأكد إن فيه `/storage/` في المسار (النمط المعتاد في Laravel للملفات
///   المرفوعة عبر `php artisan storage:link`).
String? resolveMediaUrl(dynamic rawValue) {
  final raw = rawValue?.toString().trim();
  if (raw == null || raw.isEmpty) return null;

  // القيمة رابط كامل بالفعل.
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  // شيل أي '/' في الأول عشان منكررهاش لما نضيف الدومين.
  var path = raw.startsWith('/') ? raw.substring(1) : raw;

  // لو المسار مش شايل 'storage/' أصلاً وميبقاش شكله كامل، ضيفها زي النمط
  // المعتاد في Laravel (public disk بيتخزن في storage/app/public ويتعرض
  // عبر /storage/...).
  if (!path.startsWith('storage/')) {
    path = 'storage/$path';
  }

  return '${ApiConstants.storageBaseUrl}/$path';
}

# ملف واحد نهائي — صفحة البروفايل + رفع المستندات + موقع الخريطة

ده الأرشيف **النهائي الوحيد** اللي محتاج تستخدمه. بيجمع كل حاجة اتسلمت في الثلاث
ملفات اللي فاتت في مكان واحد، وكل ملف فيه هو **آخر نسخة** منه (مفيش تعارض أو
نسخ قديمة). يعني متحتاجش ترجع لأي زيب قديم تاني.

## هتعمل إيه بيه

فك الضغط، وانسخ المجلدات دي فوق نفس المسار بالظبط في مشروعك (استبدال أي ملف
موجود بنفس الاسم):

```
lib/app/injection_container.dart
lib/features/profile/...   (كل اللي جوه مجلد profile)
pubspec.yaml
android/app/src/main/AndroidManifest.xml
ios/Runner/Info.plist
```

بعدها شغّل:

```
flutter pub get
```

## اتعمله إيه بالظبط

1. **صفحة البروفايل بالكامل** (Clean Architecture: domain/data/presentation +
   Cubit + DI) — بتشتغل على الـ API الحقيقي بدل البيانات الوهمية، مع الحفاظ
   على نفس الشكل والـ bottom navigation.
2. **رفع مستندات حقيقي** (السجل التجاري / البطاقة الضريبية) عبر `file_picker`.
3. **اختيار موقع المتجر من خريطة مجانية** (`flutter_map` + OpenStreetMap،
   من غير أي API key) بدل كتابة Latitude/Longitude يدويًا، مع عرض العنوان
   كنص مقروء بدل الأرقام (في صفحة التعديل وصفحة العرض الاثنين).

## التحقق

اتأكد من كل ده عمليًا بتثبيت Flutter SDK حقيقي (3.47.2) وتشغيل
`flutter pub get` و`flutter analyze` على المشروع بالكامل بعد دمج هذه الملفات
تحديدًا — **صفر أخطاء**. التحذيرين البسيطين الموجودين (حقول غير مستخدمة في
`profile_page.dart`) قديمين ومالهمش علاقة بالتعديلات.

## مشكلة "الحفظ مابيشتغلش" — السبب الحقيقي والحل ✅

طلعت لي اتسببان مختلفين واتصلحوا الاتنين:

**1. السيرفر بيرفض PDF للسجل التجاري/البطاقة الضريبية.**
rule الـ validation عندك في الـ Laravel بتقبل صور فقط للحقلين دول
(jpeg, png, jpg, gif, webp, bmp) ومش PDF. لما المستخدم كان يختار ملف PDF
التطبيق كان يسمحله، بس السيرفر يرفضه. → **الحل**: شيلنا PDF من قائمة
الامتدادات المسموحة في `edit_profile_page.dart`، فالمستخدم دلوقتي مش حيقدر
يختار إلا صورة من الأصل (مفيش محاولة رفع مستحيل السيرفر يرفضها). **لو
عاوزوا يقبلوا PDF فعلاً للسجل التجاري/البطاقة الضريبية (الشائع إنها PDF في
الواقع)، لازم تعدّلوا قاعدة الـ validation في الـ Laravel backend نفسه (إضافة `pdf`
للـ mimes) — ده خارج نطاق الـ Flutter.

**2. الـ API بيرجّع latitude/longitude كـ String مش رقم.**
بعد ما الحفظ ينجح في السيرفر، التطبيق كان بيحاول يقرأ الرد ويفشل بخطأ
`type 'String' is not a subtype of type 'num?'` لأن `AdminModel.fromJson` كان بيعمل
 cast مباشر (`as num?`) لـ latitude/longitude، والسيرفر بيرجّعهم كـ String.
→ **الحل**: `admin_model.dart` دلوقتي بيحوّل القيمة لـ double/int سواء رجعت كرقم
أو كنص من الـ API.

**تحسين إضافي**: رسائل الـ validation من السيرفر (زي "the field must be an image")
دلوقتي بتطلع للمستخدم كرسالة واضحة دلوقتي بدل ما تتطبع بصيغة Map غير
مقروءة زي `{field: [msg]}` (`profile_repository_impl.dart`). وللتشخيص المستقبلي،
لسه موجود سطر `debugPrint('SAVE_ERROR: ...')` في `edit_profile_page.dart` بيطبع أي
رسالة خطأ في الـ console/logcat مباشرة.

تم التحقق من الحلين بـ `flutter analyze` (صفر أخطاء). جرّب دلوقتي تحفظ
بصورة تاني بعد اختيار مستند/صورة ووريني لو فيه أي حاجة مستجدة.

## صفحة البروفايل مش بترجّع الصورة/الملفات — السبب الحقيقي والحل النهائي ✅

بفضل لوج تشخيصي طبعنا الرد الخام الفعلي من الـ API، اتأكد السبب بالظبط: الـ
`GET /admin/profile` (وكمان رد الحفظ `PUT /admin/profile/update`) بيرجّعوا
فعليًا باسم **`picture_url`، `commercial_register_url`، `tax_card_url`**
(وكروابط كاملة جاهزة فعلاً، مش مسارات نسبية)، مش بنفس اسم حقل الرفع
(`picture`، `commercial_register`، `tax_card`) اللي كان التطبيق بيدور عليه.
لما مبيلاقيش الاسم الصحيح، كان دايمًا بيرجع `null`، حتى لو الصورة/الملفات
مرفوعة فعلاً على السيرفر وراجعة في روابط كاملة جاهزة (تأكدنا من ده بلوج مفصّل
طبعناه مؤقتًا بمساعدتك).

**الحل:** `lib/features/auth/data/models/admin_model.dart` دلوقتي بيدور على
`picture_url` / `commercial_register_url` / `tax_card_url` الأولاً، وبرجع
للأسماء القديمة (`picture`/`commercial_register`/`tax_card`) كـ fallback
احتياطي فقط لو الفرونت رجع اسم مختلف يومًا ما. ولإضافة مرونة مستقبلية ضد أي
تغيير مماثل من الباكإند، أضيف أيضًا دالة `resolveMediaUrl()` في ملف جديد
`lib/core/utils/media_url_resolver.dart`: بتعرض الرابط الكامل زي ما هو (زي
الحالة دلوقتي)، أو لو السيرفر رجع مسار نسبي في أي وقت لاحقًا بتبني رابط كامل
بإضافة دومين السيرفر.

اللوج التشخيصي المؤقت الذي استخدمناه في التشخيص (`ADMIN_JSON`/`[GET]`/`[UPDATE]`)
تم شيله دلوقتي بعد ما خدم غرضه وأكد السبب الحقيقي بنجاح.

## صفحة الهوم بقت ديناميكية بالكامل من الـ API ✅

صفحة الهوم كانت شاشة عرض ثابتة (mock data): 4 كروت إحصائيات ثابتة (منتجات/طلبات/طلبات معلّقة/تصنيفات)، طلبين ثابتين تحت "Recent Orders"، ومنتجين ثابتين تحت "Products Overview". دلوقتي كل الأرقام والقوائم بتيجي فعليًا من الـ API، مع الحفاظ الكامل على نفس التصميم المرئي والـ Bottom Navigation Bar.

**لا يوجد endpoint مخصص للـ dashboard في الـ Postman collection** — فبنبني كل الإحصائيات من نفس الـ 3 endpoints اللي بتستخدمهم صفحات المنتجات/الطلبات/التصنيفات بالفعل:

- `GET /admin/products` → إجمالي عدد المنتجات + قائمة "Products Overview" (أحدث 3 منتجات).
- `GET /admin/orders` → إجمالي عدد الطلبات + عدد الطلبات اللي حالتها `pending` + قائمة "Recent Orders" (أحدث 3 طلبات).
- `GET /admin/categories` → إجمالي عدد التصنيفات.

**إزاي اتعمل (مفيش أي endpoints/use cases جديدة، الثلاثة كانوا مسجلين في `injection_container.dart` بالفعل)**:

- ملف جديد `lib/features/home/presentation/cubit/home_state.dart`: حالة `HomeLoaded` بتخزن الأرقام المحسوبة (totalProducts, totalOrders, pendingOrders, totalCategories) وقوائم `recentOrders`/`productsOverview` الجاهزة للعرض، بالإضافة لـ `HomeInitial`/`HomeLoading`/`HomeFailure`.
- ملف جديد `lib/features/home/presentation/cubit/home_cubit.dart`: بيجيب المنتجات والطلبات والتصنيفات الثلاثة مع بعض عن طريق الـ use cases الموجودة فعلاً (`GetProductsUseCase`, `GetOrdersUseCase`, `GetCategoriesUseCase`)، وبيحسب منهم كل الإحصائيات المطلوبة.
- `lib/app/injection_container.dart`: إضافة تسجيل `HomeCubit` جديد (قسم "Home - Presentation") بيستخدم نفس الـ use cases المسجلة بالفعل.
- `lib/features/home/presentation/pages/home_page.dart`: `HomePage` بقت `StatelessWidget` بتلف `_HomeView` بـ `BlocProvider<HomeCubit>` بيستدعي `loadDashboard()` أول ما الصفحة تفتح. كل منطق البروفايل (تحميل بيانات الأدمن) والـ Bottom Navigation Bar فضلوا زي ما هما تمامًا من غير أي تغيير. الكروت الأربعة، وكروت الطلبات والمنتجات دلوقتي بتعرض بيانات حقيقية بدل الأرقام والأسماء الثابتة، وحالة كل طلب (Pending/Processing/Completed/Cancelled...) بتتلوّن ديناميكيًا زي ما بالظبط بيحصل في صفحة الـ Orders، وبادچ "Visible/Hidden" في كارت المنتج بقى فعليًا مربوط بحقل `visible` الحقيقي للمنتج بدل ما يكون "Visible" ثابت دايمًا.
- تمت إضافة `RefreshIndicator` (سحب للتحديث) حوالين قسم الإحصائيات/الطلبات/المنتجات، وفي حالة فشل تحميل البيانات بتظهر رسالة خطأ واضحة مع زرار "Try again" بدل الأرقام، بنفس أسلوب صفحتي الـ Products/Orders الحاليتين.
- قسم "Quick Actions" (زرار Add Product وزرار Categories) فضل زي ما هو تمامًا من غير أي تغيير في السلوك، لأنه مش جزء من طلب هذا التعديل.

تم التحقق بـ `flutter analyze` على نسخة نظيفة تمامًا من الريبو (clone منفصل) — نفس الـ 3 ملاحظات الموجودة أصلاً في الكود من قبل (مش متعلقة بهذا التعديل)، وصفر أخطاء جديدة.

## زرار تسجيل الخروج (Logout) في صفحة البروفايل ✅

اتضاف زرار "Log Out" في آخر صفحة البروفايل (تحت زرار "Edit Profile" بنفس التصميم)، مع تأكيد قبل الخروج فعليًا (Dialog "هل أنت متأكد؟") عشان محدش يخرج بالغلط بضغطة واحدة:

- **استدعاء API**: تمت إضافة `logoutAdmin()` بالكامل عبر الطبقات (`AuthRemoteDataSource` → `AuthRepository` → `LogoutAdminUseCase` → `AuthCubit`) بينادي `POST /admin/logout` بنفس الـ endpoint المعرّف بالفعل في `api_constants.dart`.
- **تسجيل الخروج بيتم محليًا دايمًا** حتى لو نداء السيرفر فشل (مثلاً مفيش إنترنت وقت الضغط على الزرار) — عشان المستخدم يقدر يخرج من حسابه في كل الأحوال. بيتم مسح التوكن المحفوظ (`admin_token`) وبيانات البروفايل المحفوظة محليًا (`AdminProfileStorage`)، وبعدها التنقل لصفحة تسجيل الدخول (`LoginPage`) مع مسح كل الصفحات اللي فاتت من الـ navigation stack، عشان زرار الرجوع مايرجعش لصفحات محتاجة تسجيل دخول.
- **الملفات الجديدة/المعدلة**: `logout_admin_usecase.dart` (جديد)، `auth_repository.dart`/`auth_remote_data_source.dart`/`auth_repository_impl.dart` (إضافة `logoutAdmin`)، `auth_state.dart` (إضافة `AuthLogoutSuccess`)، `auth_cubit.dart` (إضافة `logoutAdmin()`)، `injection_container.dart` (تسجيل `LogoutAdminUseCase` وتحديث تسجيل `AuthCubit`)، و`profile_page.dart` (زرار الخروج + الـ Dialog).

تم التحقق بـ `flutter analyze` على نسخة نظيفة تمامًا من الريبو (clone منفصل مع كل التعديلات السابقة) — نفس الـ 3 ملاحظات الموجودة أصلاً في الكود من قبل، وصفر أخطاء جديدة.

## رفع الموقع/السجل التجاري/البطاقة الضريبية والصورة الشخصية أثناء التسجيل ✅

خطوات إنشاء الحساب ("Create Account") في صفحتي "Business Information" و"Security" كانت بتحاكي الرفع فقط (checkbox وهمي بدون ملف حقيقي، وموقع ثابت مربوط بإحداثيات Cairo الافتراضية). دلوقتي الثلاث حقول دي بترفع فعليًا زي صفحة تعديل البروفايل بالظبط:

- **Store Location** (في `register_business_page.dart`): بدل الزرار اللي كان بيحط إحداثيات ثابتة ويطلع رسالة "Maps will be connected later"، دلوقتي بيفتح نفس صفحة الخريطة `LocationPickerPage` (فري، OpenStreetMap، من غير API key) وبيرجع إحداثيات حقيقية + عنوان مقروء بعد الـ reverse geocoding، ويتحفظوا في الفورم.
- **Commercial Register / Tax Card** (في نفس الصفحة): بدل ما الزرار يحط علامة صح وهمية، دلوقتي بيفتح `FilePicker` حقيقي (بنفس قيد الصيغ اللي السيرفر بيقبلها: jpg, jpeg, png, gif, webp, bmp — مش PDF) وبيعرض اسم الملف المختار فعليًا، مع إمكانية إزالته واختيار غيره.
- **Upload Photo** (في `register_security_page.dart`، خطوة Security): بدل الزرار اللي كان بيحط علامة صح وهمية، دلوقتي بيفتح نفس الـ Bottom Sheet المستخدم في تعديل البروفايل (اختيار من المعرض أو تصوير مباشر بالكاميرا) وبيعرض معاينة حقيقية للصورة المختارة داخل الدائرة.
- **الإرسال للسيرفر**: `AdminRegistrationData` كان عنده الحقول دي (`commercialRegister`, `taxCard`, `picture`) من الأول بس من غير ما يتم تعبئتها أو إرسالها فعليًا — دلوقتي بيتم تمريرها من الصفحتين، و`auth_remote_data_source.dart` بيرفقها كملفات `multipart` باسم الحقول `commercial_register`, `tax_card`, `picture` (نفس التسمية بالظبط اللي الـ API بيتوقعها في `POST /admin/register` حسب الـ Postman collection).

تم التحقق بـ `flutter analyze` على نسخة نظيفة تمامًا من الريبو (clone منفصل مع كل التعديلات السابقة + الـ pubspec المحدّث) — نفس الـ 3 ملاحظات الموجودة أصلاً في الكود من قبل، وصفر أخطاء جديدة.

## رسالة "national_id field format is invalid" عند التسجيل ✅

التحقق القديم في صفحة "Personal Info" كان بيأكد بس إن الرقم القومي 14 رقم، فكان ممكن المستخدم يعدي الفورم برقم 14 خانة شكليًا بس مش رقم قومي حقيقي، ويوصل للسيرفر ويرجع رفض ("national_id field format is invalid") بعد ما المستخدم يكون خلص ملء كل خطوات التسجيل. دلوقتي في `register_personal_page.dart` دالة `_validateNationalId` بتتحقق من شكل الرقم القومي المصري بالكامل قبل ما يوصل للسيرفر:

- أول رقم (القرن) لازم يكون 2 (مواليد 1900‑ألف) أو 3 (مواليد 2000‑ألف).
- الأرقام اللي بعده لازم تكون تاريخ ميلاد حقيقي وموجود (شهر من 1 لـ 12، ويوم صحيح في الشهر ده مثلاً مفيش 31 في فبراير).

لو الرقم مش مطابق الشروط دي، المستخدم هيعرف فورًا قبل ما يكمل التسجيل مش بعد ما يدخل الباسورد ويضغط "Create Account". التحقق ده لا يمنع خطأ في رقم قومي موجود بالفعل بس ممكن مطبوع الرقم اللي لم يمر عليه طبقًا للتنسيق الحقيقي الفعلي (مثل المحافظة/التسلسل الفرعي) لا يزال يرجع رفض من السيرفر بنفس الرسالة.

تم التحقق بـ `flutter analyze` في الريبو وفي نسخة منفصلة تمامًا — صفر أخطاء جديدة.

## بعد Create Account مكانش بينقل للوجين ✅

لما التسجيل ينجح فعليًا ويرجع رد `AuthRegisterSuccess`، الكود كان بيعرض رسالة نجاح بس مش بينتقل لأي مكان (الانتقال للوجين كان معلق في الكود كخطوة مستقبلية). دلوقتي في `register_security_page.dart`: بعد رسالة النجاح، الأبليكيشن دلوقتي بتنتقل لـ `LoginPage` وتمسح كل خطوات التسجيل من الـ stack (`pushAndRemoveUntil`) بنفس الطريقة المستخدمة في زرار اللوج أوت.

تم التحقق بـ `flutter analyze` في الريبو وفي نسخة منفصلة تمامًا — صفر أخطاء جديدة.

## شاشة البداية (Splash) والانتقال للوجين تلقائيًا ✅

كان في صفحة `SplashPage` جاهزة في الكود بشعار البراند والتنقيط المتحرك، بس مش موصولة بالأبليكيشن أبدًا — اللوجين كان بيفتح بشكل مباشر كـ `home`. دلوقتي:

- `app.dart`: الـ `home` بتاع `MaterialApp` دلوقتي `SplashPage` بدل من `LoginPage`.
- `splash_page.dart`: بعد 2 ثانية، بينتقل تلقائيًا لـ `LoginPage` (`pushReplacement`) فيمسح السبلاش من الـ stack فمافيش رجوع للبلاش من اللوجين بالسحب للخلف.

تم التحقق بـ `flutter analyze` — صفر أخطاء جديدة.

## إخفاء API Base URL و API Key في ملف `.env` ✅

`api_constants.dart` كان فيه الـ `baseUrl`/`storageBaseUrl`/`apiKey` مكتوبين مباشرة في الكود والـ API key بالذات مرفوع على GitHub مع كل commit. دلوقتي باستخدام باكدج `flutter_dotenv`:

- ملف `.env` جديد في جذر المشروع بيحمل `API_BASE_URL`، `STORAGE_BASE_URL`، `API_KEY` — **مضاف لـ `.gitignore`** عشان مايترفعش على الريبو مرة تانية.
- ملف `.env.example` مرفوع بدلاً (بقيم وهمية) لأي مطور جديد يعرف يعمل نسخة باسم `.env` ويملاها.
- `pubspec.yaml`: ضافة `flutter_dotenv` للديبندنسيز و`.env` للـ assets.
- `main.dart`: بيعمل `dotenv.load()` أول أي حاجة قبل ما الأبليكيشن يقوم.
- `api_constants.dart`: `baseUrl`/`storageBaseUrl`/`apiKey` بقوا `getters` بتقرا من `dotenv.env[...]` بدل من قيم مكتوبة ثابتة.
- `api_client.dart`: الـ `headers` map بقت بدون `const` لأن قيمة الـ `apiKey` دلوقتي مش ثابتة وقت الترجمة.

**مهم للبناء النهائي (release build)**: لما تجهز المشروع للمتاجر، إما تحدّد `--dart-define` للقيم الحقيقية أو تتأكد إن ملف `.env` الصحيح (مش `.env.example`) موجود في جذر المشروع ومدرج في `pubspec.yaml` قبل الـ build — ملف `.env` مابيترفعش مع Git لوحده فالمفروض إن كل مطور يطبق الملف ده محليًا قبل ما يبني.

تم التحقق بـ `flutter analyze` في الريبو وفي نسخة منفصلة تمامًا (`git clone` جديد + `flutter pub get`) — صفر أخطاء جديدة.

## المصادر (توثيق الباكدجات)

- flutter_dotenv: https://pub.dev/packages/flutter_dotenv
- file_picker: https://pub.dev/packages/file_picker
- flutter_map: https://pub.dev/packages/flutter_map
- latlong2: https://pub.dev/packages/latlong2
- geolocator: https://pub.dev/packages/geolocator
- geocoding: https://pub.dev/packages/geocoding

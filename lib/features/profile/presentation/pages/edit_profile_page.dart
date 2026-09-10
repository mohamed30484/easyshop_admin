import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/injection_container.dart';
import '../../../auth/domain/entities/admin_entity.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../domain/usecases/update_profile_params.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'location_picker_page.dart';
import 'profile_page.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key, required this.admin});

  final AdminEntity admin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: _EditProfileView(admin: admin),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView({required this.admin});

  final AdminEntity admin;

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  static const Color _orange = Color(0xFFFF821D);
  static const Color _background = Color(0xFFF8F8FA);
  static const Color _fieldBackground = Color(0xFFF4F3F7);
  static const Color _textPrimary = Color(0xFF20212B);
  static const Color _textSecondary = Color(0xFF92939D);

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _addressController;

  double? _latitude;
  double? _longitude;
  String? _locationAddress;
  bool _isResolvingAddress = false;

  PlatformFile? _commercialRegisterFile;
  PlatformFile? _taxCardFile;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.admin.name);
    _emailController = TextEditingController(text: widget.admin.email);
    _phoneController = TextEditingController(text: widget.admin.phone);
    _nationalIdController = TextEditingController(
      text: widget.admin.nationalId,
    );
    _businessNameController = TextEditingController(
      text: widget.admin.businessName,
    );
    _addressController = TextEditingController(
      text: widget.admin.address ?? '',
    );

    _latitude = widget.admin.latitude;
    _longitude = widget.admin.longitude;

    if (_latitude != null && _longitude != null) {
      _resolveAddress(_latitude!, _longitude!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String? _nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _resolveAddress(double latitude, double longitude) async {
    setState(() => _isResolvingAddress = true);

    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((part) => part != null && part.trim().isNotEmpty).toList();

        setState(() {
          _locationAddress = parts.isNotEmpty ? parts.join('، ') : null;
          _isResolvingAddress = false;
        });
        return;
      }
    } catch (_) {
      // نتجاهل خطأ تحويل الإحداثيات للعنوان ونعرض الإحداثيات كحل بديل فقط.
    }

    if (!mounted) return;
    setState(() => _isResolvingAddress = false);
  }

  Future<void> _openLocationPicker() async {
    final initialLocation = (_latitude != null && _longitude != null)
        ? LatLng(_latitude!, _longitude!)
        : null;

    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialLocation: initialLocation),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
      _locationAddress = result.address;
    });
  }

  Future<void> _pickDocument({required bool isCommercialRegister}) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        // ملحوظة: السيرفر بيرفض PDF لحقلي السجل التجاري/البطاقة الضريبية
        // وبيطلب صورة فقط (رسالة الخطأ: "must be an image ... jpeg, png,
        // jpg, gif, webp, bmp") — لذلك شيلنا pdf من هنا عشان مايطلعشش المستخدم
        // يختار ملف مستحيل يقبله السيرفر. لو عاوز تقبل PDF لازم تعديل قاعدة الـ
        // validation في الـ Laravel backend (mimes:...,pdf) مش الـ Flutter.
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
      );

      if (file == null || !mounted || file.path == null) return;

      setState(() {
        if (isCommercialRegister) {
          _commercialRegisterFile = file;
        } else {
          _taxCardFile = file;
        }
      });
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Unable to pick this file.');
    }
  }

  void _removeDocument({required bool isCommercialRegister}) {
    setState(() {
      if (isCommercialRegister) {
        _commercialRegisterFile = null;
      } else {
        _taxCardFile = null;
      }
    });
  }

  void _saveChanges() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<ProfileCubit>().updateProfile(
      UpdateProfileParams(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        nationalId: _nationalIdController.text.trim(),
        businessName: _businessNameController.text.trim(),
        address: _nullableText(_addressController.text),
        latitude: _latitude,
        longitude: _longitude,
        picturePath: _selectedImage?.path,
        commercialRegisterPath: _commercialRegisterFile?.path,
        taxCardPath: _taxCardFile?.path,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null || !mounted) return;

      setState(() => _selectedImage = image);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Unable to pick this image.');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Wrap(
              children: [
                const Center(
                  child: Text(
                    'Change profile photo',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: _orange,
                  ),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: _orange,
                  ),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  void _openProducts() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProductsPage()),
      (route) => false,
    );
  }

  void _openOrders() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OrdersPage()),
      (route) => false,
    );
  }

  void _openProfile() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProfilePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          Navigator.of(context).pop(state.admin);
          return;
        }

        if (state is ProfileUpdateFailure) {
          // TEMP DEBUG: نطبع رسالة الخطأ في الـ console/logcat كمان تقدر تنسخها من هناك
          // بدل ما توخذ سكرين شوت. ابحث عن السطر اللي فيه "SAVE_ERROR:".
          debugPrint('SAVE_ERROR: ${state.message}');
          _showSnackBar(state.message);
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final isSaving = state is ProfileUpdating;

          return _buildScaffold(isSaving: isSaving);
        },
      ),
    );
  }

  Widget _buildScaffold({required bool isSaving}) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: isSaving ? null : () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textPrimary,
            size: 20,
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFEDEDF0)),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 122),
            children: [
              _buildProfilePhoto(),
              const SizedBox(height: 18),
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 17),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return 'Email is required.';
                  }

                  if (!email.contains('@')) {
                    return 'Enter a valid email address.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 17),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 17),
              _buildTextField(
                controller: _nationalIdController,
                label: 'National ID',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'National ID is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 17),
              _buildTextField(
                controller: _businessNameController,
                label: 'Business Name',
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Business name is required.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 17),
              _buildTextField(
                controller: _addressController,
                label: 'Business Address',
                optional: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 17),
              _buildLocationCard(),
              const SizedBox(height: 17),
              _buildDocumentField(
                title: 'Commercial Register',
                fileName: _commercialRegisterFile?.name,
                hasExistingUpload: _hasValue(widget.admin.commercialRegister),
                onTap: () => _pickDocument(isCommercialRegister: true),
                onRemove: () => _removeDocument(isCommercialRegister: true),
              ),
              const SizedBox(height: 17),
              _buildDocumentField(
                title: 'Tax Card',
                fileName: _taxCardFile?.name,
                hasExistingUpload: _hasValue(widget.admin.taxCard),
                onTap: () => _pickDocument(isCommercialRegister: false),
                onRemove: () => _removeDocument(isCommercialRegister: false),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomArea(isSaving: isSaving),
    );
  }

  Widget _buildProfilePhoto() {
    final imageUrl = widget.admin.picture?.trim() ?? '';
    final hasImage = imageUrl.isNotEmpty;
    final selectedImage = _selectedImage;

    return Column(
      children: [
        GestureDetector(
          onTap: _showImageSourceSheet,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8E8EC),
              border: Border.all(color: Colors.white, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: selectedImage != null
                ? Image.file(
                    File(selectedImage.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _photoPlaceholder(),
                  )
                : hasImage
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _photoPlaceholder(),
                  )
                : _photoPlaceholder(),
          ),
        ),
        const SizedBox(height: 9),
        InkWell(
          onTap: _showImageSourceSheet,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_a_photo_outlined, color: _orange, size: 17),
                SizedBox(width: 7),
                Text(
                  'Change Photo',
                  style: TextStyle(
                    color: _orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return const Icon(Icons.person_rounded, color: Color(0xFFB9BBC4), size: 40);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool optional = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(title: label, optional: optional),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _fieldBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _fieldBackground),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _orange, width: 1.3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel({required String title, bool optional = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          fontFamily: 'Roboto',
        ),
        children: [
          TextSpan(text: title),
          if (optional)
            const TextSpan(
              text: ' (Optional)',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: _textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final hasLocation = _latitude != null && _longitude != null;

    String subtitle;
    if (_isResolvingAddress) {
      subtitle = 'جارِ تحديد العنوان...';
    } else if (hasLocation) {
      subtitle =
          _locationAddress ??
          '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
    } else {
      subtitle = 'Tap to select store location on the map';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(title: 'Store Location', optional: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: _openLocationPicker,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F1),
              border: Border.all(color: const Color(0xFFFFD5B2), width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: _orange,
                  size: 21,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _orange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.map_outlined, color: _orange, size: 19),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentField({
    required String title,
    required String? fileName,
    required bool hasExistingUpload,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final hasNewSelection = fileName != null;
    final isUploaded = hasNewSelection || hasExistingUpload;

    final label = hasNewSelection
        ? fileName
        : hasExistingUpload
        ? '$title uploaded'
        : 'Upload $title';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(title: title, optional: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isUploaded ? const Color(0xFFFFFBF7) : _fieldBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUploaded ? _orange : const Color(0xFFD5D4DA),
                width: isUploaded ? 1.7 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUploaded ? Icons.check_rounded : Icons.file_upload_outlined,
                  color: isUploaded ? _orange : _textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUploaded ? _orange : _textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (hasNewSelection)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _textSecondary,
                      size: 19,
                    ),
                    splashRadius: 19,
                    tooltip: 'Remove file',
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomArea({required bool isSaving}) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F0F2))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFFFC99B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.3,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
            _EditProfileBottomNavigation(
              onHomeTap: _openHome,
              onProductsTap: _openProducts,
              onOrdersTap: _openOrders,
              onProfileTap: _openProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileBottomNavigation extends StatelessWidget {
  const _EditProfileBottomNavigation({
    required this.onHomeTap,
    required this.onProductsTap,
    required this.onOrdersTap,
    required this.onProfileTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onProductsTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onProfileTap;

  static const Color _orange = Color(0xFFFF821D);
  static const Color _inactive = Color(0xFF9699A5);

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
      (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Orders'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    final actions = [onHomeTap, onProductsTap, onOrdersTap, onProfileTap];

    return SizedBox(
      height: 72,
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = index == 3;

          return Expanded(
            child: InkWell(
              onTap: actions[index],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected ? item.$2 : item.$1,
                    color: selected ? _orange : _inactive,
                    size: 23,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      color: selected ? _orange : _inactive,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: selected ? 28 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

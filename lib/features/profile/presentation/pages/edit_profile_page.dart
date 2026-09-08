import 'package:flutter/material.dart';

import '../../../auth/domain/entities/admin_entity.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import 'profile_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.admin});

  final AdminEntity admin;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color _orange = Color(0xFFFF821D);
  static const Color _background = Color(0xFFF8F8FA);
  static const Color _fieldBackground = Color(0xFFF4F3F7);
  static const Color _textPrimary = Color(0xFF20212B);
  static const Color _textSecondary = Color(0xFF92939D);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  bool _commercialRegisterUploaded = false;
  bool _taxCardUploaded = false;
  bool _isSaving = false;

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
    _latitudeController = TextEditingController(
      text: _coordinateText(widget.admin.latitude),
    );
    _longitudeController = TextEditingController(
      text: _coordinateText(widget.admin.longitude),
    );

    _commercialRegisterUploaded =
        widget.admin.commercialRegister != null &&
        widget.admin.commercialRegister!.trim().isNotEmpty;

    _taxCardUploaded =
        widget.admin.taxCard != null && widget.admin.taxCard!.trim().isNotEmpty;

    _latitudeController.addListener(_refreshLocationCard);
    _longitudeController.addListener(_refreshLocationCard);
  }

  @override
  void dispose() {
    _latitudeController.removeListener(_refreshLocationCard);
    _longitudeController.removeListener(_refreshLocationCard);

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    super.dispose();
  }

  void _refreshLocationCard() {
    if (mounted) {
      setState(() {});
    }
  }

  String _coordinateText(double? value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  String? _nullableText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  double? _parseCoordinate(String value) {
    final text = value.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
  }

  bool _hasValidCoordinates() {
    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();

    final latitude = _parseCoordinate(latitudeText);
    final longitude = _parseCoordinate(longitudeText);

    if (latitudeText.isEmpty && longitudeText.isEmpty) {
      return true;
    }

    if (latitude == null || longitude == null) {
      return false;
    }

    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_hasValidCoordinates()) {
      _showSnackBar(
        'Please enter valid latitude and longitude values, or leave both empty.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final updatedAdmin = AdminEntity(
      id: widget.admin.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
      businessName: _businessNameController.text.trim(),
      address: _nullableText(_addressController.text),
      latitude: _parseCoordinate(_latitudeController.text),
      longitude: _parseCoordinate(_longitudeController.text),
      commercialRegister: _commercialRegisterUploaded
          ? (widget.admin.commercialRegister ?? 'commercial_register_uploaded')
          : null,
      taxCard: _taxCardUploaded
          ? (widget.admin.taxCard ?? 'tax_card_uploaded')
          : null,
      picture: widget.admin.picture,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pop(updatedAdmin);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showImagePickerMessage() {
    _showSnackBar(
      'Photo picker will be connected when we add image upload support.',
    );
  }

  void _updateStoreLocation() {
    _showSnackBar(
      'Location picker will be connected later. You can enter latitude and longitude below.',
    );
  }

  void _toggleCommercialRegister() {
    setState(() {
      _commercialRegisterUploaded = !_commercialRegisterUploaded;
    });

    _showSnackBar(
      _commercialRegisterUploaded
          ? 'Commercial Register selected.'
          : 'Commercial Register removed.',
    );
  }

  void _toggleTaxCard() {
    setState(() {
      _taxCardUploaded = !_taxCardUploaded;
    });

    _showSnackBar(
      _taxCardUploaded ? 'Tax Card selected.' : 'Tax Card removed.',
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
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
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
              _buildTextField(
                controller: _latitudeController,
                label: 'Latitude',
                optional: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 17),
              _buildTextField(
                controller: _longitudeController,
                label: 'Longitude',
                optional: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
              ),
              const SizedBox(height: 17),
              _buildDocumentField(
                title: 'Commercial Register',
                uploaded: _commercialRegisterUploaded,
                uploadedText: 'Commercial Register uploaded',
                uploadText: 'Upload Commercial Register',
                onTap: _toggleCommercialRegister,
                onRemove: _toggleCommercialRegister,
              ),
              const SizedBox(height: 17),
              _buildDocumentField(
                title: 'Tax Card',
                uploaded: _taxCardUploaded,
                uploadedText: 'Tax Card uploaded',
                uploadText: 'Upload Tax Card',
                onTap: _toggleTaxCard,
                onRemove: _toggleTaxCard,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomArea(),
    );
  }

  Widget _buildProfilePhoto() {
    final imageUrl = widget.admin.picture?.trim() ?? '';
    final hasImage = imageUrl.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: _showImagePickerMessage,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8E8EC),
              border: Border.all(color: Colors.white, width: 3),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasImage
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
          onTap: _showImagePickerMessage,
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
    final latitude = _latitudeController.text.trim();
    final longitude = _longitudeController.text.trim();

    final hasLocation = latitude.isNotEmpty && longitude.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(title: 'Store Location', optional: true),
        const SizedBox(height: 8),
        InkWell(
          onTap: _updateStoreLocation,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    hasLocation
                        ? '$latitude, $longitude'
                        : 'Tap to update store location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _orange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentField({
    required String title,
    required bool uploaded,
    required String uploadedText,
    required String uploadText,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
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
              color: uploaded ? const Color(0xFFFFFBF7) : _fieldBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: uploaded ? _orange : const Color(0xFFD5D4DA),
                width: uploaded ? 1.7 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  uploaded ? Icons.check_rounded : Icons.file_upload_outlined,
                  color: uploaded ? _orange : _textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    uploaded ? uploadedText : uploadText,
                    style: TextStyle(
                      color: uploaded ? _orange : _textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (uploaded)
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

  Widget _buildBottomArea() {
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
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFFFC99B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
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

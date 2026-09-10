import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../profile/presentation/pages/location_picker_page.dart';
import '../../models/admin_registration_data.dart';
import 'register_security_page.dart';

class RegisterBusinessPage extends StatefulWidget {
  const RegisterBusinessPage({super.key, required this.registrationData});

  final AdminRegistrationData registrationData;

  @override
  State<RegisterBusinessPage> createState() => _RegisterBusinessPageState();
}

class _RegisterBusinessPageState extends State<RegisterBusinessPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _businessNameController;
  late final TextEditingController _addressController;

  PlatformFile? _commercialRegisterFile;
  PlatformFile? _taxCardFile;

  double? _latitude;
  double? _longitude;
  String? _locationAddress;
  bool _isPickingDocument = false;

  @override
  void initState() {
    super.initState();

    _businessNameController = TextEditingController(
      text: widget.registrationData.businessName,
    );

    _addressController = TextEditingController(
      text: widget.registrationData.address,
    );

    _latitude = widget.registrationData.latitude;
    _longitude = widget.registrationData.longitude;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    return _businessNameController.text.trim().isNotEmpty;
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
    setState(() => _isPickingDocument = true);

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        // السيرفر بيرفض PDF لحقلي السجل التجاري/البطاقة الضريبية وبيطلب صورة
        // بس (jpeg, png, jpg, gif, webp, bmp) - نفس القيد المطبق في تعديل البروفايل.
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pick this file.')),
      );
    } finally {
      if (mounted) setState(() => _isPickingDocument = false);
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

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedData = widget.registrationData.copyWith(
      businessName: _businessNameController.text.trim(),
      address: _addressController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      commercialRegister: _commercialRegisterFile?.path != null
          ? File(_commercialRegisterFile!.path!)
          : null,
      taxCard: _taxCardFile?.path != null ? File(_taxCardFile!.path!) : null,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterSecurityPage(registrationData: updatedData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth = constraints.maxWidth >= 600
                ? 460.0
                : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                  child: Form(
                    key: _formKey,
                    onChanged: () => setState(() {}),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _RegisterProgressIndicator(currentStep: 2),
                        const SizedBox(height: 17),
                        const Text(
                          'Step 2 of 3 — Business',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Business Information',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _LabeledTextField(
                          label: 'Business Name',
                          controller: _businessNameController,
                          hint: 'My Digital Store',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your business name';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        _LabeledTextField(
                          label: 'Business Address',
                          optional: true,
                          controller: _addressController,
                          hint: 'Optional',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel(
                          label: 'Store Location',
                          optional: true,
                        ),
                        const SizedBox(height: 9),
                        _LocationPickerTile(
                          isSelected: _latitude != null && _longitude != null,
                          label: _locationAddress,
                          onTap: _openLocationPicker,
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel(
                          label: 'Commercial Register',
                          optional: true,
                        ),
                        const SizedBox(height: 9),
                        _DocumentPickerTile(
                          isUploaded: _commercialRegisterFile != null,
                          uploadedLabel:
                              _commercialRegisterFile?.name ??
                              'Commercial Register uploaded',
                          emptyLabel: _isPickingDocument
                              ? 'Opening file picker...'
                              : 'Upload Commercial Register',
                          onTap: () =>
                              _pickDocument(isCommercialRegister: true),
                          onRemove: () =>
                              _removeDocument(isCommercialRegister: true),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel(label: 'Tax Card', optional: true),
                        const SizedBox(height: 9),
                        _DocumentPickerTile(
                          isUploaded: _taxCardFile != null,
                          uploadedLabel:
                              _taxCardFile?.name ?? 'Tax Card uploaded',
                          emptyLabel: _isPickingDocument
                              ? 'Opening file picker...'
                              : 'Upload Tax Card',
                          onTap: () =>
                              _pickDocument(isCommercialRegister: false),
                          onRemove: () =>
                              _removeDocument(isCommercialRegister: false),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _canContinue ? _continue : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.textInputAction,
    this.optional = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputAction textInputAction;
  final bool optional;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, optional: optional),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          textInputAction: textInputAction,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.optional = false});

  final String label;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
        children: [
          TextSpan(text: label),
          if (optional)
            const TextSpan(
              text: ' (Optional)',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationPickerTile extends StatelessWidget {
  const _LocationPickerTile({
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isSelected
                    ? (label ?? 'Location set')
                    : 'Tap to set store location',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _DocumentPickerTile extends StatelessWidget {
  const _DocumentPickerTile({
    required this.isUploaded,
    required this.uploadedLabel,
    required this.emptyLabel,
    required this.onTap,
    required this.onRemove,
  });

  final bool isUploaded;
  final String uploadedLabel;
  final String emptyLabel;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploaded ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.primary : AppColors.border,
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUploaded ? Icons.check_rounded : Icons.file_upload_outlined,
              color: isUploaded ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isUploaded ? uploadedLabel : emptyLabel,
                style: TextStyle(
                  color: isUploaded
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: isUploaded ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isUploaded)
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RegisterProgressIndicator extends StatelessWidget {
  const _RegisterProgressIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index < currentStep;

        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : const Color(0xFFECEAF0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }
}

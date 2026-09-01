import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../models/admin_registration_data.dart';
import 'register_business_page.dart';

class RegisterPersonalPage extends StatefulWidget {
  const RegisterPersonalPage({super.key});

  @override
  State<RegisterPersonalPage> createState() => _RegisterPersonalPageState();
}

class _RegisterPersonalPageState extends State<RegisterPersonalPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nationalIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  void _continue() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final registrationData = AdminRegistrationData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      nationalId: _nationalIdController.text.trim(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            RegisterBusinessPage(registrationData: registrationData),
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
          onPressed: () => Navigator.of(context).maybePop(),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _RegisterProgressIndicator(currentStep: 1),
                        const SizedBox(height: 17),
                        const Text(
                          'Step 1 of 3 — Personal',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 22),
                        AppTextField(
                          label: 'Full Name',
                          hint: 'Ahmed Khalil',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: 'Email',
                          hint: 'ahmed@business.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'Please enter your email';
                            }

                            final emailPattern = RegExp(
                              r'^[\w\.-]+@[\w\.-]+\.\w{2,}$',
                            );

                            if (!emailPattern.hasMatch(email)) {
                              return 'Please enter a valid email';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: 'Phone Number',
                          hint: '+20 100 000 0000',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final phone = value?.trim() ?? '';

                            if (phone.isEmpty) {
                              return 'Please enter your phone number';
                            }

                            if (phone.length < 10) {
                              return 'Please enter a valid phone number';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          label: 'National ID',
                          hint: '14-digit national ID',
                          controller: _nationalIdController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 14,
                          onFieldSubmitted: (_) => _continue(),
                          validator: (value) {
                            final nationalId = value?.trim() ?? '';

                            if (nationalId.isEmpty) {
                              return 'Please enter your national ID';
                            }

                            if (!RegExp(r'^\d{14}$').hasMatch(nationalId)) {
                              return 'National ID must be 14 digits';
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
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

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    this.maxLength,
    this.onFieldSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?) validator;
  final int? maxLength;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLength: maxLength,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
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

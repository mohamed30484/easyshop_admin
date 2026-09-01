import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';
import '../../models/admin_registration_data.dart';

class RegisterSecurityPage extends StatefulWidget {
  const RegisterSecurityPage({super.key, required this.registrationData});

  final AdminRegistrationData registrationData;

  @override
  State<RegisterSecurityPage> createState() => _RegisterSecurityPageState();
}

class _RegisterSecurityPageState extends State<RegisterSecurityPage> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _pictureSelected = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _canCreateAccount {
    return _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
  }

  void _selectProfilePicture() {
    setState(() {
      _pictureSelected = true;
    });
  }

  void _createAccount() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final registrationData = widget.registrationData.copyWith(
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    context.read<AuthCubit>().registerAdmin(registrationData);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created successfully. Please verify your OTP.',
              ),
              backgroundColor: AppColors.success,
            ),
          );

          // بعد إنشاء صفحة OTP سننتقل إليها من هنا.
          // Navigator.of(context).pushReplacement(...);
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
                          const _RegisterProgressIndicator(currentStep: 3),
                          const SizedBox(height: 17),
                          const Text(
                            'Step 3 of 3 — Security',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Security',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const SizedBox(height: 22),
                          const _FieldLabel(
                            label: 'Profile Picture',
                            optional: true,
                          ),
                          const SizedBox(height: 12),
                          _ProfilePicturePicker(
                            isSelected: _pictureSelected,
                            onTap: _selectProfilePicture,
                          ),
                          const SizedBox(height: 24),
                          const _FieldLabel(label: 'Password'),
                          const SizedBox(height: 9),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final password = value ?? '';

                              if (password.isEmpty) {
                                return 'Please enter a password';
                              }

                              if (password.length < 6) {
                                return 'Password must be at least 6 characters';
                              }

                              return null;
                            },
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Create a strong password',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _FieldLabel(label: 'Confirm Password'),
                          const SizedBox(height: 9),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _createAccount(),
                            validator: (value) {
                              final confirmPassword = value ?? '';

                              if (confirmPassword.isEmpty) {
                                return 'Please confirm your password';
                              }

                              if (confirmPassword != _passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Repeat your password',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;

                              return SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _canCreateAccount && !isLoading
                                      ? _createAccount
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor:
                                        AppColors.primaryLight,
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              );
                            },
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
      ),
    );
  }
}

class _ProfilePicturePicker extends StatelessWidget {
  const _ProfilePicturePicker({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Icon(
              isSelected ? Icons.check_rounded : Icons.camera_alt_outlined,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 25,
            ),
          ),
        ),
        const SizedBox(width: 16),
        TextButton.icon(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          ),
          icon: Icon(
            isSelected
                ? Icons.check_circle_outline_rounded
                : Icons.camera_alt_outlined,
            size: 19,
          ),
          label: Text(
            isSelected ? 'Photo selected' : 'Upload photo',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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

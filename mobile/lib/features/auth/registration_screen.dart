import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/api_exception.dart';
import '../../core/app_scope.dart';
import '../../design/brand/spartan_emblem.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'sign_in_validators.dart';

/// Registration screen for new Spartan trainees.
/// Collects Full Name, Gender, Email, and Password with validation.
/// Connects to the real Laravel API for registration.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({
    required this.onSwitchToSignIn,
    super.key,
  });

  final VoidCallback onSwitchToSignIn;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _gender = 'male';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;
  String? _topError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _topError = 'Passwords do not match');
      return;
    }

    final controller = AppScope.of(context);
    setState(() {
      _loading = true;
      _topError = null;
    });

    try {
      await controller.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        gender: _gender,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      String message;
      if (error.isValidation && error.fieldErrors.isNotEmpty) {
        message = error.firstFieldError;
      } else {
        message = error.message;
      }
      setState(() {
        _loading = false;
        _topError = message;
      });
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _topError = 'Registration failed. Please try again.';
      });
      return;
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.contentMax,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    // Spartan Emblem
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.metallicGold.withValues(alpha: 0.22),
                              blurRadius: 28,
                            ),
                          ],
                        ),
                        child: const SpartanEmblem(size: 76, emphasis: 1.1),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      strings.registerTitle,
                      textAlign: TextAlign.center,
                      style: AppText.display.copyWith(
                        fontSize: 23,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      strings.registerSubtitle,
                      textAlign: TextAlign.center,
                      style: AppText.secondary,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Full Name
                    OmrTextField(
                      label: strings.fullNameLabel,
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Gender Selector
                    Text(strings.genderLabel, style: AppText.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: _GenderChip(
                            label: strings.genderMale,
                            selected: _gender == 'male',
                            onTap: () => setState(() => _gender = 'male'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _GenderChip(
                            label: strings.genderFemale,
                            selected: _gender == 'female',
                            onTap: () => setState(() => _gender = 'female'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Email
                    OmrTextField(
                      label: strings.emailLabel,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final code = validateEmailField(value);
                        if (code == null) return null;
                        return strings.errInvalidEmail;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    OmrTextField(
                      label: strings.passwordLabel,
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Confirm Password
                    OmrTextField(
                      label: strings.confirmPasswordLabel,
                      controller: _confirmPasswordController,
                      obscure: _obscureConfirmPassword,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
                        ),
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (_topError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          _topError!,
                          style: AppText.secondary.copyWith(
                            color: AppColors.danger,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    PrimaryButton(
                      label: strings.registerButton,
                      loading: _loading,
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Google OAuth preparation
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Google sign-in integration arrives in the future cloud release.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: Text(strings.continueWithGoogle),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Switch to Sign In
                    TextButton(
                      onPressed: widget.onSwitchToSignIn,
                      child: Text(
                        strings.alreadyHaveAccount,
                        style: AppText.secondary.copyWith(
                          color: AppColors.metallicGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.metallicGold.withValues(alpha: 0.18)
              : AppColors.secondaryBlack,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: selected
                ? AppColors.metallicGold
                : AppColors.border,
            width: selected ? 1.6 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppText.title.copyWith(
            fontSize: 14,
            color: selected ? AppColors.metallicGold : AppColors.neutralGray,
          ),
        ),
      ),
    );
  }
}

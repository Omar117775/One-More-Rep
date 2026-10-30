import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/api_exception.dart';
import '../../core/app_scope.dart';
import '../../design/brand/spartan_emblem.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'forgot_password_screen.dart';
import 'registration_screen.dart';
import 'sign_in_validators.dart';

/// Minimal sign-in gate. Email/password validation, error surfacing,
/// guest exploration, registration, and recovery.
/// API base URL is resolved automatically from the build environment.
class SignInScreen extends StatefulWidget {
  const SignInScreen({
    this.onSwitchToRegister,
    this.onSwitchToForgotPassword,
    this.onSwitchToOnboarding,
    super.key,
  });

  final VoidCallback? onSwitchToRegister;
  final VoidCallback? onSwitchToForgotPassword;
  final VoidCallback? onSwitchToOnboarding;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _topError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    final controller = AppScope.of(context);
    setState(() {
      _loading = true;
      _topError = null;
    });
    try {
      await controller.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _topError = _describeError(error);
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _topError = AppStrings.of(context).errWrongCredentials;
      });
      return;
    }
    if (mounted) setState(() => _loading = false);
    // Success: AppScope notifies the root gate and AppShell appears.
  }

  String _describeError(ApiException error) {
    final strings = AppStrings.of(context);
    if (error.isValidation && error.fieldErrors.isNotEmpty) {
      return error.firstFieldError;
    }
    if (error.isNetwork) return error.message;
    return '${strings.errWrongCredentials}\n${error.message}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
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
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: 88,
                      height: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.25),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const SpartanEmblem(size: 84, emphasis: 1.2),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      strings.signInTitle,
                      textAlign: TextAlign.center,
                      style: AppText.display.copyWith(
                        fontSize: 25,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      strings.signInSubtitle,
                      textAlign: TextAlign.center,
                      style: AppText.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xl),
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
                    OmrTextField(
                      label: strings.passwordLabel,
                      controller: _passwordController,
                      obscure: _obscurePassword,
                      validator: (value) => validatePasswordField(value) == null
                          ? null
                          : strings.errPasswordRequired,
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
                    if (_topError != null)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _topError!,
                                style: AppText.secondary.copyWith(
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_topError != null)
                      const SizedBox(height: AppSpacing.md),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      label: strings.signInButton,
                      loading: _loading,
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Auxiliary Auth Links
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (widget.onSwitchToForgotPassword != null) {
                              widget.onSwitchToForgotPassword!();
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ForgotPasswordScreen(
                                    onBackToSignIn: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            strings.forgotPasswordLink,
                            style: AppText.secondary.copyWith(
                              color: AppColors.metallicGold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Text('•', style: TextStyle(color: AppColors.neutralGray)),
                        TextButton(
                          onPressed: () {
                            if (widget.onSwitchToRegister != null) {
                              widget.onSwitchToRegister!();
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => RegistrationScreen(
                                    onSwitchToSignIn: () => Navigator.of(context).pop(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            strings.signUpLink,
                            style: AppText.secondary.copyWith(
                              color: AppColors.metallicGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => AppScope.of(context).enterAsGuestMock(),
                      child: Text(
                        strings.guestDemoButton,
                        style: AppText.caption.copyWith(
                          color: AppColors.neutralGray,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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

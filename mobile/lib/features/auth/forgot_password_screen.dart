import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../design/brand/spartan_emblem.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'sign_in_validators.dart';

/// Forgot password & recovery screen with mock code dispatch.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    required this.onBackToSignIn,
    super.key,
  });

  final VoidCallback onBackToSignIn;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _codeSent = false;
  bool _loading = false;
  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _sendCode(AppStrings strings) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.resetSentToast),
          backgroundColor: AppColors.secondaryBlack,
        ),
      );
    });
  }

  void _resetPassword(AppStrings strings) {
    if (_codeController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 4-digit code (e.g. 1234)')),
      );
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Sign in with your new password.'),
          backgroundColor: AppColors.secondaryBlack,
        ),
      );
      widget.onBackToSignIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToSignIn,
        ),
      ),
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
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.metallicGold.withValues(alpha: 0.2),
                              blurRadius: 26,
                            ),
                          ],
                        ),
                        child: const SpartanEmblem(size: 72, emphasis: 1.0),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      strings.forgotPasswordTitle,
                      textAlign: TextAlign.center,
                      style: AppText.display.copyWith(
                        fontSize: 22,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      strings.forgotPasswordSubtitle,
                      textAlign: TextAlign.center,
                      style: AppText.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Email input
                    OmrTextField(
                      label: strings.emailLabel,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_codeSent,
                      validator: (value) {
                        final code = validateEmailField(value);
                        if (code == null) return null;
                        return strings.errInvalidEmail;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (!_codeSent) ...[
                      PrimaryButton(
                        label: strings.sendResetLink,
                        loading: _loading,
                        onPressed: _loading ? null : () => _sendCode(strings),
                      ),
                    ] else ...[
                      OmrTextField(
                        label: 'RECOVERY CODE',
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OmrTextField(
                        label: 'NEW PASSWORD',
                        controller: _newPasswordController,
                        obscure: _obscureNewPassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureNewPassword = !_obscureNewPassword,
                          ),
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(
                        label: 'CONFIRM NEW PASSWORD',
                        loading: _loading,
                        onPressed: _loading ? null : () => _resetPassword(strings),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),
                    TextButton(
                      onPressed: widget.onBackToSignIn,
                      child: Text(
                        strings.alreadyHaveAccount,
                        style: AppText.secondary.copyWith(
                          color: AppColors.metallicGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

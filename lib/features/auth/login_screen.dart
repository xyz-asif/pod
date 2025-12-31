// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pod/features/auth/login_controller.dart';
import 'package:pod/features/auth/models/user_model.dart'; // Added
import 'package:pod/core/utils/snackbar.dart'; // Added
import 'package:pod/core/routing/navigation_extensions.dart'; // Added

import 'package:pod/core/theme/app_colors.dart';
import 'package:pod/core/theme/app_text_styles.dart';
import 'package:pod/core/constants/app_sizes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accountController = TextEditingController(text: 'user');
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(loginControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          account: _accountController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ADD THIS: This handles the "Actions" (Side Effects)
    ref.listen<AsyncValue<UserModel?>>(
      loginControllerProvider,
      (previous, next) {
        next.when(
          data: (user) {
            if (user != null) {
              AppSnackBar.success(context, 'Welcome back, ${user.name}!');
              context.goToHome(); // Navigate to Home on success
            }
          },
          error: (error, stackTrace) {
            AppSnackBar.error(context, error.toString()); // Show error toast
          },
          loading: () {}, // Handled by the button UI
        );
      },
    );

    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSizes.paddingAll24,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Text('Welcome Back!', style: AppTextStyles.h1),
                SizedBox(height: 8.h),
                Text('Login to continue', style: AppTextStyles.bodyMedium),
                SizedBox(height: 48.h),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined)),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                SizedBox(height: 16.h),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) =>
                      (val == null || val.length < 6) ? 'Min 6 chars' : null,
                ),
                SizedBox(height: 32.h),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: _buildGradientButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Login', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      {required VoidCallback? onPressed, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? const LinearGradient(
                colors: [AppColors.gradient1, AppColors.gradient2])
            : null,
        color: onPressed == null ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            child: Center(child: child)),
      ),
    );
  }
}

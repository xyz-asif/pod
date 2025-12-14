// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pod/features/auth/login_controller.dart';
import 'package:pod/core/routing/navigation_extensions.dart';
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

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(loginControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          account: _accountController.text.trim(),
        );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateAccount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Account is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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

                // Welcome Text
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Login to continue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 48.h),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      size: AppSizes.iconMedium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: _validateEmail,
                ),

                SizedBox(height: 16.h),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: AppSizes.iconMedium,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: AppSizes.iconMedium,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),

                SizedBox(height: 16.h),

                // Account Field
                TextFormField(
                  controller: _accountController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: 'Account',
                    hintText: 'Enter account name',
                    prefixIcon: Icon(
                      Icons.business_outlined,
                      size: AppSizes.iconMedium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: _validateAccount,
                ),

                SizedBox(height: 32.h),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: loginState.when(
                    data: (_) => _buildGradientButton(
                      onPressed: _login,
                      child: Text('Login', style: AppTextStyles.button),
                    ),
                    loading: () => _buildGradientButton(
                      onPressed: null,
                      child: SizedBox(
                        height: 24.r,
                        width: 24.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    error: (error, _) => _buildGradientButton(
                      onPressed: _login,
                      child: Text('Retry Login', style: AppTextStyles.button),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Register Link
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.goToRegister(),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Register',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? const LinearGradient(
                colors: [AppColors.gradient1, AppColors.gradient2],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: onPressed == null ? AppColors.grey.withOpacity(0.3) : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.gradient2.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Center(child: child),
        ),
      ),
    );
  }
}

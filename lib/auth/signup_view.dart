import 'package:flutter/material.dart';
import 'package:outtadebt/auth/signup_view_model.dart';
import 'package:outtadebt/core/services/auth_service.dart';
import 'package:outtadebt/core/ui/app_theme.dart';
import 'package:outtadebt/core/utils/internal_notification/notify_service.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  late final SignupViewModel _viewModel = SignupViewModel(
    routerService: locator<RouterService>(),
    notifyService: locator<NotifyService>(),
    authService: locator<AuthService>(),
  );

  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.xl,
              vertical: context.spacing.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                Center(
                  child: Text(
                    'OuttaDebt',
                    style: context.textStyles.xxxl.copyWith(
                      color: context.kitColors.green600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Create account',
                  style: context.textStyles.xxl.copyWith(
                    color: context.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Get OuttaDebt',
                  style: context.textStyles.standard.copyWith(
                    color: context.kitColors.neutral500,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Full Name',
                  style: context.textStyles.lg.copyWith(
                    color: context.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _viewModel.nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: 'John Doe',
                    hintStyle: context.textStyles.standard.copyWith(
                      color: context.kitColors.neutral400,
                    ),
                    filled: true,
                    fillColor: context.theme.brightness == Brightness.dark
                        ? context.kitColors.neutral800
                        : context.kitColors.neutral100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.kitColors.green600,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                      vertical: context.spacing.md,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Email',
                  style: context.textStyles.lg.copyWith(
                    color: context.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _viewModel.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'your@email.com',
                    hintStyle: context.textStyles.standard.copyWith(
                      color: context.kitColors.neutral400,
                    ),
                    filled: true,
                    fillColor: context.theme.brightness == Brightness.dark
                        ? context.kitColors.neutral800
                        : context.kitColors.neutral100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.kitColors.green600,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                      vertical: context.spacing.md,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Password',
                  style: context.textStyles.lg.copyWith(
                    color: context.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _viewModel.passwordController,
                  obscureText: _passwordObscured,
                  decoration: InputDecoration(
                    hintText: 'Min. 8 characters',
                    hintStyle: context.textStyles.standard.copyWith(
                      color: context.kitColors.neutral400,
                    ),
                    filled: true,
                    fillColor: context.theme.brightness == Brightness.dark
                        ? context.kitColors.neutral800
                        : context.kitColors.neutral100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.kitColors.green600,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                      vertical: context.spacing.md,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: context.kitColors.neutral500,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordObscured = !_passwordObscured;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Confirm Password',
                  style: context.textStyles.lg.copyWith(
                    color: context.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _viewModel.confirmPasswordController,
                  obscureText: _confirmPasswordObscured,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    hintStyle: context.textStyles.standard.copyWith(
                      color: context.kitColors.neutral400,
                    ),
                    filled: true,
                    fillColor: context.theme.brightness == Brightness.dark
                        ? context.kitColors.neutral800
                        : context.kitColors.neutral100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.theme.brightness == Brightness.dark
                            ? context.kitColors.neutral700
                            : context.kitColors.neutral200,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.kitColors.green600,
                        width: 2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                      vertical: context.spacing.md,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _confirmPasswordObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: context.kitColors.neutral500,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmPasswordObscured = !_confirmPasswordObscured;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Password must be at least 8 characters',
                  style: context.textStyles.xs.copyWith(
                    color: context.kitColors.neutral500,
                  ),
                ),

                const SizedBox(height: 32),

                ValueListenableBuilder<bool>(
                  valueListenable: _viewModel.isLoading,
                  builder: (context, isLoading, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading ? null : _viewModel.signup,
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    context.kitColors.neutral50,
                                  ),
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: context.textStyles.lg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: context.textStyles.standard.copyWith(
                          color: context.theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: _viewModel.navigateToLogin,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Log In',
                          style: context.textStyles.standard.copyWith(
                            color: context.kitColors.green600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

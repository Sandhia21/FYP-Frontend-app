import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants/constants.dart';
import 'package:app/widgets/widgets.dart';
import 'package:app/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(
          _usernameController.text,
          _passwordController.text,
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Back Button
            // Padding(
            //   padding: const EdgeInsets.all(Dimensions.md),
            //   child: IconButton(
            //     icon: const Icon(Icons.arrow_back, color: AppColors.white),
            //     onPressed: () => Navigator.pop(context),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyles.h1.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: Dimensions.sm),
                  Text(
                    'Please sign in to continue',
                    style:
                        TextStyles.bodyMedium.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.md),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return LoadingOverlay(
                      isLoading: authProvider.isLoading,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(Dimensions.lg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: Dimensions.xl),
                              CustomTextField(
                                controller: _usernameController,
                                labelText: 'Username',
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Dimensions.md),
                              CustomTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: !_isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: Dimensions.xl),
                              SizedBox(
                                height: Dimensions.buttonHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.borderRadiusLg,
                                      ),
                                    ),
                                  ),
                                  onPressed: _handleLogin,
                                  child: Text(
                                    'Login',
                                    style: TextStyles.buttonText.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (authProvider.error != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: Dimensions.md),
                                  child: Text(
                                    authProvider.error!,
                                    style: TextStyles.error,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              const SizedBox(height: Dimensions.md),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/register',
                                ),
                                child: Text(
                                  'Create Account?',
                                  style: TextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

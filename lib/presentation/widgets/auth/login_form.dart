import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password) onLogin;
  final bool isLoading;
  
  const LoginForm({
    Key? key,
    required this.onLogin,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      widget.onLogin(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Masukkan email Anda',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email tidak boleh kosong';
              }
              if (!RegExp(AppConstants.regexEmail).hasMatch(value)) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Masukkan password Anda',
            prefixIcon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password tidak boleh kosong';
              }
              if (value.length < 8) {
                return 'Password minimal 8 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          CustomButton(
            text: 'Login',
            onPressed: widget.isLoading ? null : _handleLogin,
            isLoading: widget.isLoading,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
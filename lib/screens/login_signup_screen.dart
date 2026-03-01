import 'package:flutter/material.dart';
import 'package:healtime_app/models/auth_provider.dart';
import 'package:healtime_app/theme/app_theme.dart';
import 'package:healtime_app/widgets/primary_button.dart';
import 'package:healtime_app/widgets/text_input_field.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLoginMode = true;
  String _selectedRole = 'patient';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!_isLoginMode) {
                        setState(() => _isLoginMode = true);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Symbols.arrow_back,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/app_logo.png',
                        height: 32,
                        width: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Heal Time',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 32),
              // Hero Image
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/clinic_interior.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Welcome Text
              Text(
                _isLoginMode ? 'Welcome Back' : 'Create Account',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLoginMode
                    ? 'Step back into your wellness journey'
                    : 'Start your journey to better health',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              // Form
              if (!_isLoginMode) ...[
                TextInputField(
                  label: 'Full Name',
                  placeholder: 'John Doe',
                  prefixIcon: Symbols.person,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Join as',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleOption(
                        'patient',
                        'Patient',
                        Symbols.person,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRoleOption(
                        'doctor',
                        'Doctor',
                        Symbols.medical_services,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextInputField(
                label: 'Email Address',
                placeholder: 'yourname@example.com',
                prefixIcon: Symbols.mail,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              TextInputField(
                label: 'Password',
                placeholder: '••••••••',
                prefixIcon: Symbols.lock,
                isPassword: true,
                controller: _passwordController,
              ),
              if (_isLoginMode) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Action Button
              PrimaryButton(
                text: _isLoading
                    ? (_isLoginMode ? 'Logging in...' : 'Creating account...')
                    : (_isLoginMode ? 'Login' : 'Sign Up'),
                icon: _isLoading ? null : Symbols.arrow_forward,
                onPressed: _isLoading ? null : _handleSubmit,
              ),
              const SizedBox(height: 24),
              // Footer
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isLoginMode = !_isLoginMode);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: _isLoginMode
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontFamily: 'Manrope',
                      ),
                      children: [
                        TextSpan(
                          text: _isLoginMode ? 'Sign Up' : 'Login',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLoginMode && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    bool success;
    if (_isLoginMode) {
      success = await auth.login(email, password);
    } else {
      success = await auth.register(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
      );
    }

    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLoginMode ? 'Invalid credentials' : 'Registration failed',
          ),
        ),
      );
    }
  }

  Widget _buildRoleOption(String role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

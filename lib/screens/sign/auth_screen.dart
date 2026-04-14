import 'package:app_locale/app_locale.dart';
import 'package:auth_bloc/auth_bloc.dart';
import 'package:duskmoon_theme/duskmoon_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gsmlg/screens/home/home_screen.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  static const name = 'Auth';
  static const path = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _usernameController.text;
    final password = _passwordController.text;

    // Simulate login delay
    await Future.delayed(loginTime);

    if (!mounted) return;

    if (name == 'gsmlg' && password == 'gsmlg') {
      context.read<AuthBloc>().add(AuthSignedIn(name));
      context.goNamed(HomeScreen.name);
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid username or password'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate signup delay
    await Future.delayed(loginTime);

    if (!mounted) return;

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sign up successful! Please sign in.'),
        backgroundColor:
            Theme.of(context).extension<DmColorExtension>()!.success,
      ),
    );
    setState(() => _isSignUp = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.goNamed(HomeScreen.name);
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo/Title Section
                      Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.appName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          if (value != 'test' && value.length < 5) {
                            return 'Username must contain at least 5 characters';
                          }
                          final reg = RegExp(r'^[^a-zA-Z]+$');
                          if (reg.hasMatch(value)) {
                            return 'Username must be alphanumeric';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            _isSignUp ? _handleSignUp() : _handleLogin(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      FilledButton(
                        onPressed: _isLoading
                            ? null
                            : (_isSignUp ? _handleSignUp : _handleLogin),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            : Text(_isSignUp ? 'SIGN UP' : 'SIGN IN'),
                      ),
                      const SizedBox(height: 16),

                      // Toggle Sign In/Sign Up
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() => _isSignUp = !_isSignUp);
                              },
                        child: Text(
                          _isSignUp
                              ? 'Already have an account? Sign In'
                              : "Don't have an account? Sign Up",
                        ),
                      ),

                      if (!_isSignUp) ...[
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Password recovery is not implemented yet',
                                      ),
                                    ),
                                  );
                                },
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

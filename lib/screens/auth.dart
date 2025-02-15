import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fleet_ease/screens/home.dart';
import 'package:fleet_ease/utils/secure_storage.dart';
import 'package:fleet_ease/screens/forgot_password.dart';

import 'package:fleet_ease/api/auth_functions.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final storage = FlutterSecureStorage();

  bool _isLogin = true;
  bool isAuthenticated = false;
  var _enteredName = '';
  var _accountType = '';
  var _enteredEmail = '';
  var _enteredPassword = '';

  @override
  void initState() {
    super.initState();
    _checkAuthToken();
  }

  void _checkAuthToken() async {
    final token = await SecureStorageService().getToken();
    final userType = await SecureStorageService().getUserType();
    if (token != null && userType != null) {
      setState(() {
        isAuthenticated = true;
      });
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(userType: userType)),
      );
    }
  }

  void _submitForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;

    _form.currentState!.save();

    try {
      final response = _isLogin
          ? await login(_enteredEmail, _enteredPassword)
          : await register(
              _enteredName, _accountType, _enteredEmail, _enteredPassword);

      if (_isLogin) {
        if (response == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );
          if (!mounted) return;
          final userType = await SecureStorageService().getUserType();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(userType: userType!)),
          );
        } else if (response == 422) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to login')),
          );
        }
      } else {
        if (response == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully')),
          );
          if (!mounted) return;
          setState(() {
            _isLogin = true;
          });
        } else if (response == 422) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create account')),
          );
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!isKeyboardVisible)
                  SizedBox(
                    height: screenHeight * 0.2,
                    child: Image.asset('assets/fleet_ease_logo.png',
                        fit: BoxFit.contain),
                  ),
                Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 20),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Full Name'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter your name' : null,
                              onSaved: (value) => _enteredName = value!,
                            ),
                          if (!_isLogin)
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  labelText: 'Account Type'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'driver', child: Text('Driver')),
                                DropdownMenuItem(
                                    value: 'manager',
                                    child: Text('Fleet Manager')),
                              ],
                              onChanged: (value) => _accountType = value!,
                              onSaved: (value) => _accountType = value!,
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                !EmailValidator.validate(value!)
                                    ? 'Enter a valid email'
                                    : null,
                            onSaved: (value) => _enteredEmail = value!,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) => (value!.length < 8)
                                ? 'Password must be at least 8 characters'
                                : null,
                            onSaved: (value) => _enteredPassword = value!,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(_isLogin ? 'Login' : 'Sign Up'),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _isLogin = !_isLogin),
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'Login instead'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen()),
                            ),
                            child: const Text('Forgot Password?'),
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
}

import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'package:fleet_ease/screens/home.dart';
import 'package:fleet_ease/utils/secure_storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
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
          MaterialPageRoute(builder: (_) => HomeScreen(userType: userType)));
    }
  }

  void _submitForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }

    _form.currentState!.save();
    try {
      if (_isLogin) {
        // Implement Login Logic
        final url =
            Uri.parse('https://fleet-ease-backend.vercel.app/api/auth/login');
        final response = await post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'emailAddress': _enteredEmail,
            'password': _enteredPassword,
          }),
        );

        if (response.statusCode != 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid credentials. Please try again.'),
            ),
          );
          return;
        }
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        final userType = responseData['user']['accountType'];
        final userId = responseData['user']['_id'];
        final emailAddress = responseData['user']['emailAddress'];
        final userName = responseData['user']['name'];
        await SecureStorageService()
            .saveUserData(token, userType, userId, userName, emailAddress);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
          ),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(userType: userType)));
      } else {
        // Implement Sign Up Logic
        final url = Uri.parse(
            'https://fleet-ease-backend.vercel.app/api/auth/register');
        final response = await post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _enteredName,
            'accountType': _accountType,
            'emailAddress': _enteredEmail,
            'password': _enteredPassword,
          }),
        );
        if (response.statusCode != 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong. Please try again later.'),
            ),
          );
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
          ),
        );
        setState(() {
          _isLogin = true;
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Something went wrong. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Image.asset(
                'assets/fleet_ease_logo.png',
                fit: BoxFit.cover,
              ),
            ),
            Card(
              margin: EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (!_isLogin)
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                            ),
                            validator: (value) {
                              if (value == '') {
                                return 'Kindly enter a name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredName = value!;
                            },
                          ),
                        if (!_isLogin)
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Account Type',
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'driver',
                                child: Text('Driver'),
                              ),
                              DropdownMenuItem(
                                value: 'manager',
                                child: Text('Fleet Manager'),
                              ),
                            ],
                            onChanged: (value) {
                              _accountType = value!;
                            },
                            onSaved: (value) {
                              _accountType = value!;
                            },
                          ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            bool isValid = EmailValidator.validate(value!);
                            if (value == '' || !isValid) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value!.trim().length < 8) {
                              return 'Password must have at least 8 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _submitForm();
                            });
                          },
                          child: Text(_isLogin ? 'Login' : 'Sign Up'),
                        ),
                        const Text('or'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'Create a New Account'
                              : 'Login to Existing Account'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

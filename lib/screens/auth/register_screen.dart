import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  String _errorMessage = '';

  Future<void> _register(String email, String password, String username) async {
    final prefs = await SharedPreferences.getInstance();
    final backendUrl = prefs.getString('backend_url');

    if (backendUrl == null || backendUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Backend URL is not set.';
      });
      return;
    }

    final registerUrl = '$backendUrl/auth/register';
    final response = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'username': username,
        'client': 'flutter_frontend',
      }),
    );

    if (response.statusCode == 201) {
      // Clear the error message
      setState(() {
        _errorMessage = '';
      });
      // Show success dialog with countdown
      int countdown = 5;
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Registration Successful'),
                  content: Text('Redirecting to login screen in $countdown seconds...'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('Redirect Now'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }
      // Countdown timer
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          countdown--;
        });
        // Update the dialog content with the new countdown value
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('Registration Successful'),
                    content: Text('Redirecting to login screen in $countdown seconds...'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text('Redirect Now'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }
      }
      // Navigate to Login screen after successful registration
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      setState(() {
        _errorMessage = 'Registration failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create an Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final email = _emailController.text;
                  final password = _passwordController.text;
                  final confirmPassword = _confirmPasswordController.text;
                  final username = _usernameController.text;
                  if (email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty && username.isNotEmpty) {
                    if (password == confirmPassword) {
                      _register(email, password, username);
                    } else {
                      setState(() {
                        _errorMessage = 'Passwords do not match';
                      });
                    }
                  } else {
                    setState(() {
                      _errorMessage = 'Please fill in all fields';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Register'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: TextButton.styleFrom(
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Already registered? Login'),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final backendUrl = prefs.getString('backend_url');

    if (backendUrl == null || backendUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Backend URL is not set.';
      });
      return;
    }

    final loginUrl = '$backendUrl/auth/login';
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final token = responseBody['token'];

      if (token != null) {
        // Save the token to SharedPreferences
        await prefs.setString('auth_token', token);
        
        // Navigate to Home screen after successful login
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to login. No token received.';
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Login failed. Please check your credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text;
                final password = _passwordController.text;
                if (email.isNotEmpty && password.isNotEmpty) {
                  _login(email, password);
                } else {
                  setState(() {
                    _errorMessage = 'Please enter both email and password';
                  });
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/token');
              },
              child: Text('Have a token?'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

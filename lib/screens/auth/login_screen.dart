import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/backend_url');
      }
      return;
    }

    final loginUrl = '$backendUrl/auth/login';
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'client': 'flutter_frontend',
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final token = responseBody['token'];
      final role = responseBody['role'];

      if (token != null) {
        // Save the token and role to SharedPreferences
        await prefs.setString('auth_token', token);
        await prefs.setString('role', role);

        // Navigate to the appropriate home screen after successful login
        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin_home');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
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

  Future<void> _resetBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_url');
  }

  void _navigateToBackendUrlScreen(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/backend_url', (route) => false);
  }

  Future<void> _showResetBackendUrlConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Backend URL Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to reset the backend URL?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Reset URL'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetBackendUrl();
                if (!context.mounted) return;
                _navigateToBackendUrlScreen(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final prefs = snapshot.data;
          final role = prefs?.getString('role') ?? '';

          if (role == 'admin') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/admin_home');
              }
            });
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Login'),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert), // Three-dot menu
                onSelected: (String result) {
                  if (result == 'reset_backend_url') {
                    _showResetBackendUrlConfirmationDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'reset_backend_url',
                    child: Text('Reset Backend URL'),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back',
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
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
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
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Login'),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text("Don't have an account? Register"),
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
      },
    );
  }
}

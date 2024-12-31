import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/setup/backend_url_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_screen.dart' as login; // Import the login screen with a prefix
import 'screens/home_screen.dart'; // This is a screen you should create for after login
import 'screens/admin/admin_home_screen.dart'; // Import the admin home screen
import 'screens/auth/logout_screen.dart'; // Import the logout screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget _initialScreen = Center(child: CircularProgressIndicator());

  @override
  void initState() {
    super.initState();
    _checkIfBackendUrlSaved();
  }

  Future<void> _checkIfBackendUrlSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final backendUrl = prefs.getString('backend_url');
    final authToken = prefs.getString('auth_token');
    if (!mounted) return;

    setState(() {
      if (backendUrl == null || backendUrl.isEmpty) {
        _initialScreen = BackendUrlScreen();  // Ask user to input backend URL
      } else if (authToken != null && authToken.isNotEmpty) {
        _initialScreen = HomeScreen();  // Go to home screen if token is saved
      } else {
        _initialScreen = RegisterScreen();  // Go to register screen if no token is saved
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Brain Database',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _initialScreen,
        '/login': (context) => login.LoginScreen(), // Add this route
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(), // After login, the user is directed to this screen
        '/backend_url': (context) => BackendUrlScreen(), // Add this route
        '/admin_home': (context) => AdminHomeScreen(), // Add this route
        '/logout': (context) => LogoutScreen(), // Add this route
      },
    );
  }
}

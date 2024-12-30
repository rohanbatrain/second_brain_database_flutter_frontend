import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/backend_url_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart' as login; // Import the login screen with a prefix
import 'screens/home_screen.dart'; // This is a screen you should create for after login

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Second Brain Database',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _checkIfBackendUrlSaved(),
        '/login': (context) => login.LoginScreen(), // Add this route
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(), // After login, the user is directed to this screen
        '/backend_url': (context) => BackendUrlScreen(), // Add this route
      },
    );
  }

  // Checks if the backend URL and token are saved and navigates accordingly
  Widget _checkIfBackendUrlSaved() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          final prefs = snapshot.data;
          final backendUrl = prefs?.getString('backend_url');
          final authToken = prefs?.getString('auth_token');
          if (backendUrl == null || backendUrl.isEmpty) {
            return BackendUrlScreen();  // Ask user to input backend URL
          } else if (authToken != null && authToken.isNotEmpty) {
            return HomeScreen();  // Go to home screen if token is saved
          } else {
            return RegisterScreen();  // Go to register screen if no token is saved
          }
        }
      },
    );
  }
}

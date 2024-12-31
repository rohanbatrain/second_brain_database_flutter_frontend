import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  AdminHomeScreenState createState() => AdminHomeScreenState();
}

class AdminHomeScreenState extends State<AdminHomeScreen> {
  String _adminData = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    final adminData = prefs.getString('admin_data') ?? 'No data available';
    if (!mounted) return;

    setState(() {
      _adminData = adminData;
    });
  }

  Future<void> _resetBackendUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backend_url');
    if (!mounted) return;

    _navigateToBackendUrlScreen();
  }

  void _navigateToBackendUrlScreen() {
    Navigator.pushNamedAndRemoveUntil(context, '/backend_url', (route) => false);
  }

  Future<void> _showResetBackendUrlConfirmationDialog() async {
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
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              child: Icon(Icons.person),
            ),
            onSelected: (String result) {
              if (result == 'logout') {
                Navigator.pushNamed(context, '/logout');
              } else if (result == 'reset_backend_url') {
                _showResetBackendUrlConfirmationDialog();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
              const PopupMenuItem<String>(
                value: 'reset_backend_url',
                child: Text('Reset Backend URL'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text(_adminData),
      ),
    );
  }
}
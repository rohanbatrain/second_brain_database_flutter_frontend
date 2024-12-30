import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Text('Hello, Admin!'),
      ),
    );
  }
}
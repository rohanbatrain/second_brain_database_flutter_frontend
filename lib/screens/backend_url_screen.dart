import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendUrlScreen extends StatefulWidget {
  const BackendUrlScreen({super.key});

  @override
  BackendUrlScreenState createState() => BackendUrlScreenState();
}

class BackendUrlScreenState extends State<BackendUrlScreen> {
  final _controller = TextEditingController();

  Future<void> _saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('backend_url', url);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter Backend URL')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Backend URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  _saveUrl(_controller.text);
                }
              },
              child: Text('Save URL'),
            ),
          ],
        ),
      ),
    );
  }
}

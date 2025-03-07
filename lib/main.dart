import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein BSSB App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _responseDisplay = '';
  bool _isLoading = false;

  Future<void> _handleApiRequest() async {
    setState(() {
      _isLoading = true;
      _responseDisplay = '';
    });

    final response = await ApiService.sendPostRequest();

    setState(() {
      _responseDisplay = response;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein BSSB App'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'send_request') {
                _handleApiRequest();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'send_request',
                child: Text('Send POST Request'),
              ),
            ],
            icon: const Icon(Icons.menu), // Hamburger menu icon
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Response:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_responseDisplay),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

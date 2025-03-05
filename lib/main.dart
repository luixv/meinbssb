import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String _requestBodyDisplay = '';
  String _responseDisplay = '';
  bool _isLoading = false;

  Future<void> _sendPostRequest() async {
    setState(() {
      _isLoading = true;
      _requestBodyDisplay = '';
      _responseDisplay = '';
    });

    final String apiUrl = 'http://172.23.48.1:3001/mock-register';
    final requestBody = {
      'vorname': 'Luis',
      'nachname': 'Mandel',
      'email': 'luismandel@gmail.com',
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      setState(() {
        _requestBodyDisplay = requestBody.entries
            .map((entry) => '${entry.key}: ${entry.value}')
            .join('\n');
      });

      if (response.statusCode == 200) {
        setState(() {
          _responseDisplay = 'Status Code: ${response.statusCode}\nBody: ${response.body}';
        });
      } else {
        setState(() {
          _responseDisplay = 'Error: ${response.statusCode}\nBody: ${response.body}';
        });
        // Log the error to the console
        debugPrint('HTTP Error: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _responseDisplay = 'Error: $e';
      });
      // Log the exception to the console
      debugPrint('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mein BSSB App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                onPressed: _isLoading ? null : _sendPostRequest,
                child: const Text('Send POST Request'),
              ),
              const SizedBox(height: 20),
              const Text('Request Body:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_requestBodyDisplay),
              const SizedBox(height: 20),
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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'localization_service.dart';

class ApiService {
  final String baseIp;
  final String port;
  late final String baseUrl;

  ApiService({this.baseIp = '127.0.0.1', this.port = '3001'}) {
    baseUrl = 'http://$baseIp:$port';
  }

  Future<dynamic> _makeRequest(Future<http.Response> request) async {
    try {
      final response = await request.timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Server timeout");
      });

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Return dynamic, can be List or Map
      } else {
        return {"ResultType": 0, "ResultMessage": "Request failed: ${response.statusCode}"};
      }
    } catch (e) {
      debugPrint('Exception: $e');
      return {"ResultType": 0, "ResultMessage": "Network error: $e"};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final String apiUrl = '$baseUrl/LoginMyBSSB';
    final requestBody = jsonEncode({"email": email, "password": password});

    debugPrint('Sending login request to: $apiUrl');
    debugPrint('Request body: $requestBody');

    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    )).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

  Future<Map<String, dynamic>> fetchPassdaten(int personId) async {
    final String apiUrl = '$baseUrl/Passdaten/$personId';
    return _makeRequest(http.get(Uri.parse(apiUrl))).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

  Future<Map<String, dynamic>> getPersonId(String email) async {
    final url = Uri.parse('$baseUrl/GetPersonID?Email=$email');
    return _makeRequest(http.get(url)).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

  Future<List<dynamic>> fetchAngemeldeteSchulungen(int personId, String abDatum) async {
    final String apiUrl = '$baseUrl/AngemeldeteSchulungen/$personId/$abDatum';
    final response = await _makeRequest(http.get(Uri.parse(apiUrl)));

    if (response is List<dynamic>) {
      return response;
    } else if (response is Map<String, dynamic>) {
      if (response['ResultType'] == 0) {
        return [];
      } else {
        if (response.containsKey('schulungen') && response['schulungen'] is List) {
          return List<dynamic>.from(response['schulungen']);
        } else {
          debugPrint("Error: 'schulungen' key not found or not a list.");
          return [];
        }
      }
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String passNumber,
    required String email,
    required String birthDate,
    required String zipCode,
  }) async {
    final String apiUrl = '$baseUrl/RegisterMyBSSB';
    final requestBody = jsonEncode({
      "firstName": firstName,
      "lastName": lastName,
      "passNumber": passNumber,
      "email": email,
      "birthDate": birthDate,
      "zipCode": zipCode,
    });

    debugPrint('Sending registration request to: $apiUrl');
    debugPrint('Request body: $requestBody');

    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    )).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

  Future<Map<String, dynamic>> fetchPassdatenWithString(String passdaten) async {
    final String apiUrl = '$baseUrl/PassdatenString/$passdaten';
    return _makeRequest(http.get(Uri.parse(apiUrl))).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

  Future<Map<String, dynamic>> resetPassword(String passNumber) async {
    final String apiUrl = '$baseUrl/PasswordReset/$passNumber';
    final requestBody = jsonEncode({"passNumber": passNumber});
    return _makeRequest(http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    )).then((value) => value is Map<String, dynamic> ? value : {}); // Ensure it's a Map
  }

Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String to,
    required String subject,
    required String content,
  }) async {
    // Extract SMTP server credentials from your configuration
    String smtpServerAddress = LocalizationService.getString('smtp'); // The SMTP server URL
    String username = LocalizationService.getString('smtp_username'); // Your SMTP username
    String password = LocalizationService.getString('smtp_password'); // Your SMTP password

    // Create the SMTP server
    final smtpServer = SmtpServer(smtpServerAddress, username: username, password: password);

    // Create the message
    final message = Message()
      ..from = Address(from)
      ..recipients.add(to)
      ..subject = subject
      ..text = content;

    try {
      // Send the message
      final sendReport = await send(message, smtpServer);
      debugPrint('Message sent: ${sendReport.toString()}');

      return {"ResultType": 1, "ResultMessage": "Email sent successfully"};
    } catch (e) {
      debugPrint('Error sending email: $e');
      return {
        "ResultType": 0,
        "ResultMessage": "Error sending email: $e",
      };
    }
  }

}
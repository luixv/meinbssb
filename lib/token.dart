import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String tokenServerURL =
      'https://webintern.bssb.bayern:56400/rest/zmi/token';

  final Map<String, String> body = {
    'username': 'webuser',
    'password':
        '8702973BCE08DB9DC590BF3CDBBA1873E8B7C7296CB641F7012E123041AE4CC3',
  };
  final String jsonBody = jsonEncode(body);
  print(jsonBody);

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Content-Length': utf8.encode(jsonBody).length.toString(),
    'Host': 'webintern.bssb.bayern:56400',
  };

  print('Sending GET Request to: $tokenServerURL');
  print('Headers: $headers');
  print('Body: $jsonBody');

  try {
    final request = http.Request('GET', Uri.parse(tokenServerURL));
    request.headers.addAll(headers);
    request.body = jsonBody;

    final http.StreamedResponse streamedResponse =
        await http.Client().send(request);

    final http.Response response =
        await http.Response.fromStream(streamedResponse);

    print('Response Status Code: ${response.statusCode}');
    print('Response body: ${response.body}');
  } catch (e) {
    print('GET Request Error: $e');
  } finally {
    http.Client().close();
  }
}

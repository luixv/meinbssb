import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String url =
      'https://webintern.bssb.bayern:56400/rest/zmi/api/LoginMyBSSB';

  final Map<String, String> body = {
    'Email': 'kostas@rizoudis1.de',
    'Passwort': 'test1',
  };
  final String jsonBody = jsonEncode(body);
  print(jsonBody);

  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJSb2xlcyI6InN0YW5kYXJkLHdlYix3aWVzbix3ZWJCYXVrYXN0ZW4sYWNjZXNzIiwiZHVyYXRpb24iOiIxODk5LTEyLTMxIiwiaXNzIjoiTUFSUy1DdXJpb3NpdHkiLCJleHAiOjE3NDczOTQ3ODMsImlhdCI6MTc0NzMwODM4MywiVXNlck5hbWUiOiJ3ZWJVc2VyIiwiQkVOVVRaRVJJRCI6Nn0.nyrknugJrTj77N1xPyA4NQLjrK2Zn89qBgKl_VErL5U';
  String cookieValue = 'access_token=$token';

  String authorization = 'Bearer $token';

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Content-Length': utf8.encode(jsonBody).length.toString(),
    'Host': 'webintern.bssb.bayern:56400',
    'Cookie': cookieValue,
    'Authorization': authorization,
  };

  print('Sending GET Request to: $url');
  print('Headers: $headers');
  print('Body: $jsonBody');

  try {
    final request = http.Request('GET', Uri.parse(url));
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

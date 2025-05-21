import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

void main() async {
  final logger = Logger('main');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ignore: avoid_print
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  const String url =
      'https://webintern.bssb.bayern:56400/rest/zmi/api/LoginMyBSSB';

  final Map<String, String> body = {
    'Email': 'kostas@rizoudis1.de',
    'Passwort': 'test1',
  };
  final String jsonBody = jsonEncode(body);
  logger.fine(jsonBody);

  String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJSb2xlcyI6InN0YW5kYXJkLHdlYix3aWVzbix3ZWJCYXVrYXN0ZW4sYWNjZXNzIiwiZHVyYXRpb24iOiIxODk5LTEyLTMxIiwiaXNzIjoiTUFSUy1DdXJpb3NpdHkiLCJleHAiOjE3NDczOTQ3ODMsImlhdCI6MTc0NzMwODM4MywiVXNlck5hbWUiOiJ3ZWJVc2VyIiwiQkVOVVRaRVJJRCI6Nn0.nyrknugJrTj77N1xPyA4NQLjrK2Zn89qBgKl_VErL5U';
  
  String authorization = 'Bearer $token';

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Content-Length': utf8.encode(jsonBody).length.toString(),
    'Host': 'webintern.bssb.bayern:56400',
    'Authorization': authorization,
  };

  logger.fine('Sending GET Request to: $url');
  logger.fine('Headers: $headers');
  logger.fine('Body: $jsonBody');

  try {
    final request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);
    request.body = jsonBody;

    final http.StreamedResponse streamedResponse =
        await http.Client().send(request);

    final http.Response response =
        await http.Response.fromStream(streamedResponse);

    logger.fine('Response Status Code: ${response.statusCode}');
    logger.fine('Response body: ${response.body}');
  } catch (e) {
    logger.fine('GET Request Error: $e');
  } finally {
    http.Client().close();
  }
}

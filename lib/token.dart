import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

void main() async {
  final logger = Logger('main');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  const String tokenServerURL =
      'https://webintern.bssb.bayern:56400/rest/zmi/token';

  final Map<String, String> formFields = {
    'username': 'webuser',
    'password':
        '8702973BCE08DB9DC590BF3CDBBA1873E8B7C7296CB641F7012E123041AE4CC3',
  };

  // Create a multipart request.
  var request = http.MultipartRequest('POST', Uri.parse(tokenServerURL));

  // Add the form fields to the request.
  formFields.forEach((key, value) {
    request.fields[key] = value;
  });

  //Log
  logger.fine('url: ${request.url}');
  logger.fine('fields: ${request.fields}');

  // Send the request.
  try {
    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response =
        await http.Response.fromStream(streamedResponse);

    logger.fine('Response Status Code: ${response.statusCode}');
    logger.fine('Response body: ${response.body}');
  } catch (e) {
    logger.fine('POST Request Error: $e');
  }
}

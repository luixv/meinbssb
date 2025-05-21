import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

void main() async {
  final logger = Logger('main');
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    // ignore: avoid_print
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  const String pingServerURL =
      'https://webintern.bssb.bayern:56400/rest/zmi/api/serverping';

  var request = http.Request('GET', Uri.parse(pingServerURL));
  logger.fine('Request URL: ${request.url}');

  try {
    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response =
        await http.Response.fromStream(streamedResponse);

    logger.fine('Status Code: ${response.statusCode}');
    logger.fine('Response Body: ${response.body}');

    // Log ALL headers
    logger.fine('==== Response Headers ====');
    response.headers.forEach((key, value) {
      logger.fine('$key: $value'); // Log each header line
    });

    if (response.headers.containsKey('set-cookie')) {
      logger.fine('\n==== Cookies (from set-cookie) ====');
      response.headers['set-cookie']!.split(',').forEach((cookie) {
        logger.fine(cookie.trim());
      });
    }
  } catch (e) {
    logger.fine('GET Request Error: $e');
  }
}

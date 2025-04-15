import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind('localhost', 3001);
  print('Mock server running on http://localhost:3001');

  await for (HttpRequest request in server) {
    try {
      if (request.method == 'POST') {
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body);

        if (request.uri.path == '/LoginMyBSSB') {
          if (data['email'] == 'test@example.com' && data['password'] == 'password123') {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode({
                'ResultType': 1,
                'PersonID': 123,
                'VORNAME': 'John',
                'NAMEN': 'Doe',
                'PASSNUMMER': 'ABC123',
                'VEREINNAME': 'Test Club',
              }))
              ..close();
          } else {
            request.response
              ..statusCode = HttpStatus.ok
              ..write(jsonEncode({
                'ResultType': 0,
                'ResultMessage': 'Invalid credentials',
              }))
              ..close();
          }
        } else if (request.uri.path == '/Passdaten/123') {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode({
              'PASSNUMMER': 'ABC123',
              'VEREINNR': '456',
              'NAMEN': 'Doe',
              'VORNAME': 'John',
              'TITEL': 'Mr.',
              'GEBURTSDATUM': '1990-01-01',
              'GESCHLECHT': 'M',
              'VEREINNAME': 'Test Club',
              'PASSDATENID': 789,
              'MITGLIEDSCHAFTID': 101,
              'PERSONID': 123,
            }))
            ..close();
        }
      } else if (request.method == 'GET') {
        if (request.uri.path == '/Schuetzenausweis/JPG/123') {
          // Return a mock image
          final image = File('assets/images/myBSSB-logo.png');
          if (await image.exists()) {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType('image', 'png')
              ..add(await image.readAsBytes())
              ..close();
          } else {
            request.response
              ..statusCode = HttpStatus.notFound
              ..close();
          }
        } else if (request.uri.path == '/Zweitmitgliedschaften/123') {
          request.response
            ..statusCode = HttpStatus.ok
            ..write(jsonEncode([
              {'VEREINID': 1, 'VEREINNAME': 'Club 1'},
              {'VEREINID': 2, 'VEREINNAME': 'Club 2'},
            ]))
            ..close();
        }
      }
    } catch (e) {
      print('Error handling request: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('Internal server error')
        ..close();
    }
  }
} 
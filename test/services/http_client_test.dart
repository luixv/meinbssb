import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:meinbssb/services/http_client.dart';
import 'http_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late HttpClient httpClient;
  late MockClient mockClient;
  const String baseUrl = 'https://api.example.com';
  const int serverTimeout = 30;

  setUp(() {
    mockClient = MockClient();
    httpClient = HttpClient(baseUrl: baseUrl, serverTimeout: serverTimeout);
  });

  group('HttpClient Tests', () {
    group('POST Requests', () {
      test('successful POST request returns decoded JSON', () async {
        final responseBody = {'message': 'success'};
        when(mockClient.post(
          Uri.parse('$baseUrl/test'),
          headers: {'Content-Type': 'application/json'},
          body: '{"key":"value"}',
        )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

        final result = await httpClient.post('test', {'key': 'value'});
        expect(result, responseBody);
      });

      test('POST request with non-200 status code throws exception', () async {
        when(mockClient.post(
          Uri.parse('$baseUrl/test'),
          headers: {'Content-Type': 'application/json'},
          body: '{"key":"value"}',
        )).thenAnswer((_) async => http.Response('Error', 404));

        expect(
          () => httpClient.post('test', {'key': 'value'}),
          throwsException,
        );
      });

      test('POST request with invalid JSON response throws exception', () async {
        when(mockClient.post(
          Uri.parse('$baseUrl/test'),
          headers: {'Content-Type': 'application/json'},
          body: '{"key":"value"}',
        )).thenAnswer((_) async => http.Response('Invalid JSON', 200));

        expect(
          () => httpClient.post('test', {'key': 'value'}),
          throwsException,
        );
      });
    });

    group('GET Requests', () {
      test('successful GET request returns decoded JSON', () async {
        final responseBody = {'data': 'test'};
        when(mockClient.get(
          Uri.parse('$baseUrl/test'),
        )).thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

        final result = await httpClient.get('test');
        expect(result, responseBody);
      });

      test('GET request with non-200 status code throws exception', () async {
        when(mockClient.get(
          Uri.parse('$baseUrl/test'),
        )).thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => httpClient.get('test'),
          throwsException,
        );
      });
    });

    group('GET Bytes Requests', () {
      test('successful GET bytes request returns Uint8List', () async {
        final bytes = [1, 2, 3, 4];
        when(mockClient.get(
          Uri.parse('$baseUrl/test'),
        )).thenAnswer((_) async => http.Response.bytes(bytes, 200));

        final result = await httpClient.getBytes('test');
        expect(result, bytes);
      });

      test('GET bytes request with non-200 status code throws exception', () async {
        when(mockClient.get(
          Uri.parse('$baseUrl/test'),
        )).thenAnswer((_) async => http.Response('Error', 404));

        expect(
          () => httpClient.getBytes('test'),
          throwsException,
        );
      });
    });

    group('Timeout Handling', () {
      test('request times out after specified duration', () async {
        when(mockClient.get(
          Uri.parse('$baseUrl/test'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(seconds: serverTimeout + 1));
          return http.Response('{}', 200);
        });

        expect(
          () => httpClient.get('test'),
          throwsA(isA<TimeoutException>()),
        );
      });
    });

    group('Error Handling', () {
      test('network error is properly logged and rethrown', () async {
        when(mockClient.get(
          Uri.parse('$baseUrl/test'),
        )).thenThrow(Exception('Network error'));

        expect(
          () => httpClient.get('test'),
          throwsException,
        );
      });
    });
  });
} 
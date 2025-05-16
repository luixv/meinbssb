import 'package:http/http.dart' as http;

void main() async {
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
  print("url: ${request.url}");
  print("fields: ${request.fields}");

  // Send the request.
  try {
    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response =
        await http.Response.fromStream(streamedResponse);

    print('Response Status Code: ${response.statusCode}');
    print('Response body: ${response.body}');
  } catch (e) {
    print('POST Request Error: $e'); // Changed to POST
  } finally {
    // No need to close the client here, as we are not creating one.
  }
}

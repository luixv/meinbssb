import 'dart:async';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/logger_service.dart';

class OktoberfestService {
  OktoberfestService({
    required HttpClient httpClient,
  }) : _httpClient = httpClient;

  final HttpClient _httpClient;
}

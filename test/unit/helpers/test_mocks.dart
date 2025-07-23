import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/http_client.dart';

@GenerateMocks([
  AuthService,
  ApiService,
  ConfigService,
  EmailService,
  CacheService,
  NetworkService,
  HttpClient,
  FlutterSecureStorage,
  PostgrestService,
])
void main() {}

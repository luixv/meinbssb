import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/http_client.dart';

@GenerateMocks([EmailSender, ConfigService, HttpClient])
void main() {
  // All email service tests are disabled
} 
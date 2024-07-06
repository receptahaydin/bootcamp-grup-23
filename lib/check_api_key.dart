import 'dart:io';

void main() {
  final apiKey = Platform.environment['AIzaSyA6GjJeLlSM_EFA9KuFec5cSSQubqhB44k'];
  if (apiKey != null) {
    print('API Key found: $apiKey');
  } else {
    print('No \$API_KEY environment variable found');
  }
}

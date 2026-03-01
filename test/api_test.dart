import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healtime_app/utils/api_service.dart';

void main() {
  test('Test get chat contacts', () async {
    try {
      final docId = '69a3509b629bf166cf2edb36'; // test ID
      debugPrint('Fetching contacts for $docId...');
      final contacts = await ApiService.getChatContacts(docId);
      debugPrint('Contacts: $contacts');
    } catch (e, st) {
      debugPrint('Caught exception: $e');
      debugPrint('Stack trace: $st');
    }
  });
}

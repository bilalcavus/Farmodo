import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('zh-TW translation asset is available', () async {
    final data = await rootBundle.loadString('assets/translations/zh-TW.json');
    expect(data.isNotEmpty, true, reason: 'Translation file should not be empty');
  });
}

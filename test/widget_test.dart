import 'package:flutter_test/flutter_test.dart';

import 'package:namma_ooru/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NammaOoruApp());
    expect(find.text('My Reports'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:muslim_ku/app/prototype_app.dart';

void main() {
  testWidgets('shows Muslimku splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PrototypeApp());

    expect(find.text('Muslimku'), findsOneWidget);
    expect(find.text('THE DIGITAL SANCTUARY'), findsOneWidget);
  });
}

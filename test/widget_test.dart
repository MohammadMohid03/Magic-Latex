import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:magic_latex_frontend/app.dart';
import 'package:magic_latex_frontend/providers/scan_provider.dart';

void main() {
  testWidgets('App smoke test — splash screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ScanProvider(),
        child: const DocScanApp(),
      ),
    );

    // Verify splash screen renders with app name
    expect(find.text('DocScan AI'), findsOneWidget);
    expect(find.text('Capture.  Extract.  Export.'), findsOneWidget);
  });
}

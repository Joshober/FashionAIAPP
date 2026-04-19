import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_ai/main.dart';
import 'package:fashion_ai/providers/auth_token.dart';

void main() {
  testWidgets('Fashion AI app smoke test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: 'assets/env/dev.env');

    final container = ProviderContainer();
    await container.read(authTokenProvider.notifier).restore();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const FashionAIApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('DASHBOARD'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lost_found_app/data/mock_lost_found_repository.dart';
import 'package:lost_found_app/main.dart';
import 'package:lost_found_app/models/claims_model.dart';
import 'package:lost_found_app/models/items_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final repository = MockLostFoundRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<MockLostFoundRepository>.value(value: repository),
          ChangeNotifierProvider(create: (_) => ItemsModel(repository)..load()),
          ChangeNotifierProvider(create: (_) => ClaimsModel(repository)..load()),
        ],
        child: const LostFoundApp(),
      ),
    );

    expect(find.text('LostFound UTM'), findsOneWidget);
  });
}

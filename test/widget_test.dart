import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solospark_pro/app/solo_spark_app.dart';
import 'package:solospark_pro/data/repositories/local_business_repository.dart';
import 'package:solospark_pro/data/services/local_storage_service.dart';

void main() {
  testWidgets('app opens the SoloSpark dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.initialize();
    final repository = LocalBusinessRepository(storage);
    await repository.initializeData();

    await tester.pumpWidget(SoloSparkApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('SoloSpark Pro'), findsOneWidget);
    expect(find.text('Business snapshot'), findsOneWidget);
  });
}

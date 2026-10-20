import 'package:flutter/material.dart';

import 'app/solo_spark_app.dart';
import 'data/repositories/local_business_repository.dart';
import 'data/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = LocalStorageService();
  await storage.initialize();

  final repository = LocalBusinessRepository(storage);
  await repository.initializeDemoData();

  runApp(SoloSparkApp(repository: repository));
}

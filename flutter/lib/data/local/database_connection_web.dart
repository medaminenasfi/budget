import 'package:drift/drift.dart';
// Drift's legacy WebDatabase is retained here for Flutter 3.24 web support.
// ignore: deprecated_member_use
import 'package:drift/web.dart';

QueryExecutor openDatabaseConnection() {
  return WebDatabase('smart_budget_manager');
}

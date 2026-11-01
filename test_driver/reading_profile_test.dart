import 'package:integration_test/integration_test_driver.dart';

Future<void> main() async =>
    integrationDriver(timeout: const Duration(minutes: 30));

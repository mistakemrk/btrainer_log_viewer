import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';  // debugPrint のために追加

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
}
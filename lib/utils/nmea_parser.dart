import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../models/workout_data.dart';

class NmeaParser {
  static final _logger = Logger('NmeaParser');

  static WorkoutData? parsePSSCR(String line) {
    try {
      final parts = line.split(',');
      if (parts.length < 9) return null;

      return WorkoutData(
        timestamp: DateTime.now(), // タイムスタンプは別途取得する必要あり
        steps: int.tryParse(parts[2]) ?? 0,
        distance: double.tryParse(parts[3]) ?? 0.0,
        speed: double.tryParse(parts[4]) ?? 0.0,
        pitch: double.tryParse(parts[5]) ?? 0.0,
        stride: double.tryParse(parts[6]) ?? 0.0,
        calories: double.tryParse(parts[7]) ?? 0.0,
        lapNumber: int.tryParse(parts[8]),
      );
    } catch (e) {
      _logger.warning('Error parsing PSSCR: $e');
      return null;
    }
  }

  static HeartRateData? parsePSNYEHR(String line) {
    // 暗号化されているため、実際のデコード処理は別途実装が必要
    try {
      final parts = line.split(',');
      if (parts.length < 4) return null;

      return HeartRateData(
        timestamp: DateTime.now(),
        heartRate: 0, // デコード後に設定
        signalQuality: 0, // デコード後に設定
        steps: 0, // デコード後に設定
      );
    } catch (e) {
      debugPrint('Error parsing PSNYEHR: $e');
      return null;
    }
  }

  static WorkoutEvent? parsePSNYWOL(String line) {
    try {
      final parts = line.split(',');
      if (parts.length < 2) return null;

      return WorkoutEvent(
        timestamp: DateTime.now(),
        eventName: parts[1],
        workoutId: parts.length > 2 ? parts[2] : null,
        workoutType: parts.length > 3 ? parts[3] : null,
        status: parts.length > 4 ? parts[4] : null,
      );
    } catch (e) {
      debugPrint('Error parsing PSNYWOL: $e');
      return null;
    }
  }

  static MusicInfo? parsePSNYMMP(String line) {
    try {
      final parts = line.split(',');
      if (parts.length < 2) return null;

      String? title;
      String? artist;
      String? album;

      for (var part in parts.skip(1)) {
        if (part.startsWith('play-t:')) {
          title = part.substring(7);
        } else if (part.startsWith('play-c:')) {
          artist = part.substring(7);
        } else if (part.startsWith('play-a:')) {
          album = part.substring(7);
        }
      }

      return MusicInfo(
        timestamp: DateTime.now(),
        title: title,
        artist: artist,
        album: album,
      );
    } catch (e) {
      debugPrint('Error parsing PSNYMMP: $e');
      return null;
    }
  }
}

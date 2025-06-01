import 'package:logging/logging.dart';
import '../models/workout_data.dart';

class NmeaParser {
  static final _logger = Logger('NmeaParser');

  static WorkoutData? parsePSSCR(String line) {
    try {
      final parts = line.split(',');
      if (parts.length < 9) return null;

      final workoutData = WorkoutData(
        timestamp: DateTime.now(),
        steps: int.tryParse(parts[2]) ?? 0,
        distance: double.tryParse(parts[3]) ?? 0.0,
        speed: double.tryParse(parts[4]) ?? 0.0,
        pitch: double.tryParse(parts[5]) ?? 0.0,
        stride: double.tryParse(parts[6]) ?? 0.0,
        calories: double.tryParse(parts[7]) ?? 0.0,
        lapNumber: int.tryParse(parts[8]),
      );

      _logger.info(
        'Workout Data - Steps: ${workoutData.steps}, '
        'Distance: ${workoutData.distance}m, '
        'Speed: ${workoutData.speed}km/h, '
        'Pitch: ${workoutData.pitch}, '
        'Stride: ${workoutData.stride}m, '
        'Calories: ${workoutData.calories}kcal, '
        'Lap: ${workoutData.lapNumber ?? 'N/A'}',
      );

      return workoutData;
    } catch (e) {
      _logger.warning('Error parsing PSSCR: $e');
      return null;
    }
  }

  static HeartRateData? parsePSNYEHR(String line) {
    try {
      final parts = line.split(',');
      if (parts.length < 4) return null;

      final heartRateData = HeartRateData(
        timestamp: DateTime.now(),
        heartRate: 0,
        signalQuality: 0,
        steps: 0,
      );

      _logger.info(
        'Heart Rate Data received (encrypted) - Length: ${parts.length}',
      );
      return heartRateData;
    } catch (e) {
      _logger.warning('Error parsing PSNYEHR: $e');
      return null;
    }
  }

  static WorkoutEvent? parsePSNYWOL(String line) {
    try {
      final parts = line.split(',');
      if (parts.length < 2) return null;

      final workoutEvent = WorkoutEvent(
        timestamp: DateTime.now(),
        eventName: parts[1],
        workoutId: parts.length > 2 ? parts[2] : null,
        workoutType: parts.length > 3 ? parts[3] : null,
        status: parts.length > 4 ? parts[4] : null,
      );

      _logger.info(
        'Workout Event - Name: ${workoutEvent.eventName}, '
        'ID: ${workoutEvent.workoutId ?? 'N/A'}, '
        'Type: ${workoutEvent.workoutType ?? 'N/A'}, '
        'Status: ${workoutEvent.status ?? 'N/A'}',
      );

      return workoutEvent;
    } catch (e) {
      _logger.warning('Error parsing PSNYWOL: $e');
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

      final musicInfo = MusicInfo(
        timestamp: DateTime.now(),
        title: title,
        artist: artist,
        album: album,
      );

      _logger.info(
        'Music Info - Title: ${title ?? 'N/A'}, '
        'Artist: ${artist ?? 'N/A'}, '
        'Album: ${album ?? 'N/A'}',
      );

      return musicInfo;
    } catch (e) {
      _logger.warning('Error parsing PSNYMMP: $e');
      return null;
    }
  }
}

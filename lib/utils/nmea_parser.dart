import 'package:logging/logging.dart';
import '../models/workout_data.dart';

class NmeaParser {
  static final _logger = Logger('NmeaParser');

  // $PSSCR,2,67,53,2.141,0.65,1.39,2.0,2,3*55
  // 0      1 2  3  4     5    6    7   8 9 checksum
  // 1列目：モード（例：2=通常、3=ラップ）
  // 2列目：累計歩数
  // 3列目：累積距離(m)
  // 4列目：平均ピッチ（歩/秒）
  // 5列目：平均ストライド（m）
  // 6列目：平均速度（km/h）
  // 7列目：消費カロリー（kcal）
  // 8列目：ラップ番号
  static WorkoutData? parsePSSCR(String line) {
    try {
      // チェックサム部分(*XX)を事前に削除してからカンマで分割する
      final checksumIndex = line.indexOf('*');
      final sentence = checksumIndex != -1
          ? line.substring(0, checksumIndex)
          : line;
      final parts = sentence.split(',');

      if (parts.length < 9) return null;

      final workoutData = WorkoutData(
        timestamp: DateTime.now(),
        mode: int.tryParse(parts[1]) ?? 0,
        steps: int.tryParse(parts[2]) ?? 0,
        distance: int.tryParse(parts[3]) ?? 0,
        pitch: double.tryParse(parts[4]) ?? 0.0,
        stride: double.tryParse(parts[5]) ?? 0.0,
        speed: double.tryParse(parts[6]) ?? 0.0,
        calories: double.tryParse(parts[7]) ?? 0.0,
        lapNumber: int.tryParse(parts[8]),
      );

      _logger.info(
        'Workout Data - mode: ${workoutData.mode}, '
        'Steps: ${workoutData.steps}, '
        'Distance: ${workoutData.distance}m, '
        'Pitch: ${workoutData.pitch}, '
        'Stride: ${workoutData.stride}m, '
        'Speed: ${workoutData.speed}km/h, '
        'Calories: ${workoutData.calories}kcal, '
        'Lap: ${workoutData.lapNumber}',
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

  /// NMEAセンテンスのチェックサムを計算します。
  ///
  /// '$'と最後の'*'の間のすべての文字のXORチェックサムを計算し、
  /// 16進数2桁の文字列として返します。
  /// フォーマットが不正な場合はnullを返します。
  static String? calculateNMEAChecksum(String sentence) {
    final int startIndex = sentence.indexOf('\$');
    final int endIndex = sentence.lastIndexOf('*');

    if (startIndex == -1 || endIndex == -1 || (startIndex + 1) >= endIndex) {
      return null;
    }

    int checksum = 0;
    for (int i = startIndex + 1; i < endIndex; i++) {
      checksum ^= sentence.codeUnitAt(i);
    }

    return checksum.toRadixString(16).toUpperCase().padLeft(2, '0');
  }
}

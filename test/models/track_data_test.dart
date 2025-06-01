import 'package:flutter_test/flutter_test.dart';
import 'package:btrainer_log_viewer/models/track_data.dart';

void main() {
  group('TrackData duration tests', () {
    test('通常のケース（同日内）', () {
      final track = TrackData(
        points: [],
        startTime: '100000', // 10:00:00
        endTime: '110000', // 11:00:00
      );
      expect(track.durationText, equals('1:00:00'));
    });

    test('日付をまたぐケース', () {
      final track = TrackData(
        points: [],
        startTime: '235000', // 23:50:00
        endTime: '001000', // 00:10:00
      );
      expect(track.durationText, equals('0:20:00'));
    });
  });
}

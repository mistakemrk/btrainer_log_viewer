import 'package:flutter_test/flutter_test.dart';
import 'package:btrainer_log_viewer/models/track_data.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('TrackData', () {
    group('durationText', () {
      test('should return correct duration for same-day times', () {
        final track = TrackData(
          points: [],
          startTime: '100000', // 10:00:00
          endTime: '110000', // 11:00:00
        );
        expect(track.durationText, equals('1:00:00'));
      });

      test('should return correct duration for overnight times', () {
        final track = TrackData(
          points: [],
          startTime: '235000', // 23:50:00
          endTime: '001000', // 00:10:00
        );
        expect(track.durationText, equals('0:20:00'));
      });

      test('should return empty string if startTime is null', () {
        final track = TrackData(endTime: '110000');
        expect(track.durationText, isEmpty);
      });

      test('should return empty string if endTime is null', () {
        final track = TrackData(startTime: '100000');
        expect(track.durationText, isEmpty);
      });
    });

    group('hasData', () {
      test('should be false when points list is empty', () {
        final track = TrackData(points: []);
        expect(track.hasData, isFalse);
      });

      test('should be true when points list is not empty', () {
        final track = TrackData(points: [LatLng(0, 0)]);
        expect(track.hasData, isTrue);
      });
    });

    group('Constructor defaults', () {
      test('should have empty lists by default', () {
        final track = TrackData();
        expect(track.points, isEmpty);
        expect(track.workoutData, isEmpty);
        expect(track.heartRateData, isEmpty);
        expect(track.workoutEvents, isEmpty);
        expect(track.musicInfo, isEmpty);
        expect(track.totalDistance, 0.0);
        expect(track.startTime, isNull);
        expect(track.endTime, isNull);
      });
    });
  });
}

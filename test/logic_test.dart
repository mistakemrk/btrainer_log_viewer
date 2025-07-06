import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:btrainer_log_viewer/main.dart'; // main.dartをインポート

void main() {
  group('Top-level functions from main.dart', () {
    group('convertNmeaToDecimal', () {
      test('should correctly convert NMEA latitude to decimal', () {
        // 4807.038,N -> 48.1173
        expect(
          convertNmeaToDecimal('4807.038', 'N'),
          closeTo(48.1173, 0.0001),
        );
      });

      test('should correctly convert NMEA longitude to decimal', () {
        // 01131.000,E -> 11.5166
        expect(
          convertNmeaToDecimal('01131.000', 'E'),
          closeTo(11.5166, 0.0001),
        );
      });

      test('should handle South direction correctly', () {
        // 4807.038,S -> -48.1173
        expect(
          convertNmeaToDecimal('4807.038', 'S'),
          closeTo(-48.1173, 0.0001),
        );
      });

      test('should handle West direction correctly', () {
        // 01131.000,W -> -11.5166
        expect(
          convertNmeaToDecimal('01131.000', 'W'),
          closeTo(-11.5166, 0.0001),
        );
      });
    });

    group('calculateDistance', () {
      test('should return 0 for the same point', () {
        final point = LatLng(35.6812, 139.7671);
        expect(calculateDistance(point, point), 0);
      });

      test('should calculate the correct distance between two points', () {
        // 東京駅 (35.6812, 139.7671) と 新宿駅 (35.6896, 139.7005) のおおよその距離
        final tokyoStation = LatLng(35.6812, 139.7671);
        final shinjukuStation = LatLng(35.6896, 139.7005);
        // 期待値は約6.1km
        expect(calculateDistance(tokyoStation, shinjukuStation), closeTo(6.1, 0.1));
      });
    });

    group('calculateZoomLevel', () {
      test('should return a reasonable zoom level', () {
        // 適当な緯度経度の範囲
        final latSpan = 0.1;
        final lngSpan = 0.1;
        // この範囲ならある程度ズームされているはず
        expect(calculateZoomLevel(latSpan, lngSpan), greaterThan(10));
      });

      test('should return a lower zoom level for a wider area', () {
        final wideLatSpan = 1.0;
        final wideLngSpan = 1.0;
        final narrowLatSpan = 0.1;
        final narrowLngSpan = 0.1;

        final wideZoom = calculateZoomLevel(wideLatSpan, wideLngSpan);
        final narrowZoom = calculateZoomLevel(narrowLatSpan, narrowLngSpan);

        expect(wideZoom, lessThan(narrowZoom));
      });
    });
  });
}

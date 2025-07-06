
import 'package:flutter_test/flutter_test.dart';
import 'package:btrainer_log_viewer/utils/nmea_parser.dart';

void main() {
  group('NmeaParser', () {
    group('calculateNMEAChecksum', () {
      test('should return correct checksum for a valid GPGGA sentence', () {
        const sentence =
            '\$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47';
        expect(NmeaParser.calculateNMEAChecksum(sentence), equals('47'));
      });

      test('should return correct checksum for a valid PSSCR sentence', () {
        const sentence = '\$PSSCR,2,67,53,2.141,0.65,1.39,2.0,2,3*55';
        expect(NmeaParser.calculateNMEAChecksum(sentence), equals('55'));
      });

      test('should return null if the sentence does not start with \$', () {
        const sentence = 'GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,*47';
        expect(NmeaParser.calculateNMEAChecksum(sentence), isNull);
      });

      test('should return null if the sentence does not contain *', () {
        const sentence = '\$GPGGA,123519,4807.038,N,01131.000,E,1,08,0.9,545.4,M,46.9,M,,';
        expect(NmeaParser.calculateNMEAChecksum(sentence), isNull);
      });

      test('should return null if the sentence is empty', () {
        const sentence = '';
        expect(NmeaParser.calculateNMEAChecksum(sentence), isNull);
      });

       test('should handle sentence with no data between \$ and *', () {
        const sentence = '\$*54';
        expect(NmeaParser.calculateNMEAChecksum(sentence), '00');
      });
    });

    group('parsePSSCR', () {
      test('should correctly parse a valid PSSCR sentence', () {
        const sentence = '\$PSSCR,2,67,53,2.141,0.65,1.39,2.0,2,3*55';
        final result = NmeaParser.parsePSSCR(sentence);

        expect(result, isNotNull);
        expect(result!.mode, 2);
        expect(result.steps, 67);
        expect(result.distance, 53);
        expect(result.pitch, 2.141);
        expect(result.stride, 0.65);
        expect(result.speed, 1.39);
        expect(result.calories, 2.0);
        expect(result.lapNumber, 2);
      });

      test('should return null if the PSSCR sentence is too short', () {
        const sentence = '\$PSSCR,2,67,53*1A';
        final result = NmeaParser.parsePSSCR(sentence);
        expect(result, isNull);
      });

      test('should handle non-numeric values gracefully', () {
        const sentence = '\$PSSCR,A,B,C,D,E,F,G,H,I*XX'; // checksum doesn't matter here
        final result = NmeaParser.parsePSSCR(sentence);

        expect(result, isNotNull);
        expect(result!.mode, 0);
        expect(result.steps, 0);
        expect(result.distance, 0);
        expect(result.pitch, 0.0);
        expect(result.stride, 0.0);
        expect(result.speed, 0.0);
        expect(result.calories, 0.0);
        expect(result.lapNumber, isNull); // tryParse returns null for non-numeric
      });
    });

    group('parsePSNYEHR', () {
      test('should parse a PSNYEHR sentence', () {
        // This sentence is encrypted, so we just check if it's not null
        const sentence = '\$PSNYEHR,1,2,3,4*XX';
        final result = NmeaParser.parsePSNYEHR(sentence);
        expect(result, isNotNull);
      });

      test('should return null if sentence is too short', () {
        const sentence = '\$PSNYEHR,1*XX';
        final result = NmeaParser.parsePSNYEHR(sentence);
        expect(result, isNull);
      });
    });

    group('parsePSNYWOL', () {
      test('should correctly parse a valid PSNYWOL sentence', () {
        const sentence = '\$PSNYWOL,START,123,RUN,GO*XX';
        final result = NmeaParser.parsePSNYWOL(sentence);

        expect(result, isNotNull);
        expect(result!.eventName, 'START');
        expect(result.workoutId, '123');
        expect(result.workoutType, 'RUN');
        expect(result.status, 'GO');
      });

      test('should return null if sentence is too short', () {
        const sentence = '\$PSNYWOL*XX';
        final result = NmeaParser.parsePSNYWOL(sentence);
        expect(result, isNull);
      });
    });

    group('parsePSNYMMP', () {
      test('should correctly parse a valid PSNYMMP sentence', () {
        const sentence = '\$PSNYMMP,play-t:Song Title,play-c:Artist Name,play-a:Album Name*XX';
        final result = NmeaParser.parsePSNYMMP(sentence);

        expect(result, isNotNull);
        expect(result!.title, 'Song Title');
        expect(result.artist, 'Artist Name');
        expect(result.album, 'Album Name');
      });

      test('should handle missing parts', () {
        const sentence = '\$PSNYMMP,play-t:Song Title,play-a:Album Name*XX';
        final result = NmeaParser.parsePSNYMMP(sentence);

        expect(result, isNotNull);
        expect(result!.title, 'Song Title');
        expect(result.artist, isNull);
        expect(result.album, 'Album Name');
      });

      test('should return null if sentence is too short', () {
        const sentence = '\$PSNYMMP*XX';
        final result = NmeaParser.parsePSNYMMP(sentence);
        expect(result, isNull);
      });
    });
  });
}

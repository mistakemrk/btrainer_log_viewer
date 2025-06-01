import 'package:latlong2/latlong.dart';
import 'workout_data.dart';

class TrackData {
  final List<LatLng> points;
  final String? startTime;
  final String? endTime;
  final double totalDistance;
  final List<WorkoutData> workoutData;
  final List<HeartRateData> heartRateData;
  final List<WorkoutEvent> workoutEvents;
  final List<MusicInfo> musicInfo;

  const TrackData({
    this.points = const [],
    this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
    this.workoutData = const [],
    this.heartRateData = const [],
    this.workoutEvents = const [],
    this.musicInfo = const [],
  });

  bool get hasData => points.isNotEmpty;

  String get durationText {
    if (startTime == null || endTime == null) return '';
    final start = _parseTime(startTime!);
    var end = _parseTime(endTime!);
    // 終了時刻が開始時刻より前の場合は、終了時刻に1日を加算
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    final duration = end.difference(start);
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  DateTime _parseTime(String time) {
    final hour = int.parse(time.substring(0, 2));
    final minute = int.parse(time.substring(2, 4));
    final second = int.parse(time.substring(4, 6));
    return DateTime(2024, 1, 1, hour, minute, second);
  }
}

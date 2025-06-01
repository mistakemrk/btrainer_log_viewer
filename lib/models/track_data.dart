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

  TrackData({
    required this.points,
    this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
    List<WorkoutData>? workoutData,
    List<HeartRateData>? heartRateData,
    List<WorkoutEvent>? workoutEvents,
    List<MusicInfo>? musicInfo,
  }) : workoutData = workoutData ?? [],
       heartRateData = heartRateData ?? [],
       workoutEvents = workoutEvents ?? [],
       musicInfo = musicInfo ?? [];

  bool get hasData => points.isNotEmpty;

  String get durationText {
    if (startTime == null || endTime == null) return '';
    final start = _parseTime(startTime!);
    final end = _parseTime(endTime!);
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

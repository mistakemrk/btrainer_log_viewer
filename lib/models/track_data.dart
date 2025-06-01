import 'package:latlong2/latlong.dart';

class TrackData {
  final List<LatLng> points;
  final String? startTime;
  final String? endTime;
  final double totalDistance;

  TrackData({
    required this.points,
    this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
  });

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

class WorkoutData {
  final DateTime timestamp;
  final int steps;
  final double distance;
  final double speed;
  final double pitch;
  final double stride;
  final double calories;
  final int? lapNumber;

  WorkoutData({
    required this.timestamp,
    required this.steps,
    required this.distance,
    required this.speed,
    required this.pitch,
    required this.stride,
    required this.calories,
    this.lapNumber,
  });
}

class HeartRateData {
  final DateTime timestamp;
  final int heartRate;
  final int signalQuality;
  final int steps;

  HeartRateData({
    required this.timestamp,
    required this.heartRate,
    required this.signalQuality,
    required this.steps,
  });
}

class WorkoutEvent {
  final DateTime timestamp;
  final String eventName;
  final String? workoutId;
  final String? workoutType;
  final String? status;

  WorkoutEvent({
    required this.timestamp,
    required this.eventName,
    this.workoutId,
    this.workoutType,
    this.status,
  });
}

class MusicInfo {
  final DateTime timestamp;
  final String? title;
  final String? artist;
  final String? album;

  MusicInfo({required this.timestamp, this.title, this.artist, this.album});
}

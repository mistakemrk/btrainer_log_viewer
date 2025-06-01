import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:logging/logging.dart';

import 'models/workout_data.dart';
import 'utils/nmea_parser.dart';

void main() {
  // ロガーの初期化
  Logger.root.level = kDebugMode
      ? Level.INFO
      : Level.WARNING; // 開発時はINFO、本番はWARNING
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-Trainer Log Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const MyHomePage(title: 'B-Trainer Log Viewer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class TrackData {
  final List<LatLng> points;
  final List<WorkoutData> workoutData;
  final List<HeartRateData> heartRateData;
  final List<WorkoutEvent> workoutEvents;
  final List<MusicInfo> musicInfo;
  final String? startTime;
  final String? endTime;
  final double totalDistance;

  TrackData({
    required this.points,
    this.workoutData = const [],
    this.heartRateData = const [],
    this.workoutEvents = const [],
    this.musicInfo = const [],
    this.startTime,
    this.endTime,
    this.totalDistance = 0.0,
  });
}

class _MyHomePageState extends State<MyHomePage> {
  late final MapController mapController;
  late TrackData trackData;
  bool isMapVisible = true;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    trackData = TrackData(points: []);
  }

  Future<void> _openFile() async {
    // データをクリア
    setState(() {
      trackData = TrackData(points: []);
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        if (kIsWeb) {
          // Web環境での処理
          final bytes = result.files.first.bytes;
          if (bytes != null) {
            final content = String.fromCharCodes(bytes);
            final lines = content.split('\n');
            await _processLines(lines);
          }
        } else {
          // デスクトップ環境での処理
          final file = File(result.files.single.path!);
          final lines = await file.readAsLines();
          await _processLines(lines);
        }
      }
    } catch (e) {
      debugPrint('Error reading file: $e');
    }
  }

  // ファイル内容の処理を別メソッドに分離
  Future<void> _processLines(List<String> lines) async {
    final List<LatLng> points = [];
    final List<WorkoutData> workoutData = [];
    final List<HeartRateData> heartRateData = [];
    final List<WorkoutEvent> workoutEvents = [];
    final List<MusicInfo> musicInfo = [];

    LatLng? prevPoint;
    String? startTime;
    String? endTime;
    double totalDistance = 0.0;

    for (var line in lines) {
      try {
        if (line.startsWith('\$GPGGA')) {
          final parts = line.split(',');
          if (parts.length >= 6 && parts[6] != '0') {
            // 時刻の取得
            final time = parts[1];
            startTime ??= time;
            endTime = time;

            final lat = _convertNmeaToDecimal(parts[2], parts[3]);
            final lng = _convertNmeaToDecimal(parts[4], parts[5]);
            final currentPoint = LatLng(lat, lng);

            // 距離の計算
            if (prevPoint != null) {
              totalDistance += _calculateDistance(prevPoint, currentPoint);
            }

            points.add(currentPoint);
            prevPoint = currentPoint;
          }
        } else if (line.startsWith('\$PSSCR')) {
          final data = NmeaParser.parsePSSCR(line);
          if (data != null) workoutData.add(data);
        } else if (line.startsWith('\$PSNYEHR')) {
          final data = NmeaParser.parsePSNYEHR(line);
          if (data != null) heartRateData.add(data);
        } else if (line.startsWith('\$PSNYWOL')) {
          final data = NmeaParser.parsePSNYWOL(line);
          if (data != null) workoutEvents.add(data);
        } else if (line.startsWith('\$PSNYMMP')) {
          final data = NmeaParser.parsePSNYMMP(line);
          if (data != null) musicInfo.add(data);
        }
      } catch (e) {
        debugPrint('Error parsing line: $e');
      }
    }

    setState(() {
      trackData = TrackData(
        points: points,
        startTime: startTime,
        endTime: endTime,
        totalDistance: totalDistance,
        workoutData: workoutData,
        heartRateData: heartRateData,
        workoutEvents: workoutEvents,
        musicInfo: musicInfo,
      );
    });

    // 経路全体が表示されるように地図を調整
    if (points.isNotEmpty) {
      // 経路の境界ボックスを計算
      double minLat = points.map((p) => p.latitude).reduce(min);
      double maxLat = points.map((p) => p.latitude).reduce(max);
      double minLng = points.map((p) => p.longitude).reduce(min);
      double maxLng = points.map((p) => p.longitude).reduce(max);

      // 境界ボックスの中心を計算
      double centerLat = (minLat + maxLat) / 2;
      double centerLng = (minLng + maxLng) / 2;

      // マージンを追加して境界ボックスを少し大きくする
      double latSpan = (maxLat - minLat) * 1.1;
      double lngSpan = (maxLng - minLng) * 1.1;

      // 地図を移動
      mapController.move(
        LatLng(centerLat, centerLng),
        _calculateZoomLevel(latSpan, lngSpan),
      );
    }
  }

  // ズームレベルを計算する関数を追加
  double _calculateZoomLevel(double latSpan, double lngSpan) {
    // 画面のサイズを考慮してズームレベルを計算
    double zoomLat = log(360 / latSpan) / log(2);
    double zoomLng = log(360 / lngSpan) / log(2);
    return min(zoomLat, zoomLng) - 0.5; // 少し余裕を持たせる
  }

  double _convertNmeaToDecimal(String coord, String dir) {
    final isLongitude = dir == 'E' || dir == 'W';
    final degreeDigits = isLongitude ? 3 : 2;

    final double degrees = double.parse(coord.substring(0, degreeDigits));
    final double minutes = double.parse(coord.substring(degreeDigits)) / 60.0;
    double decimal = degrees + minutes;
    if (dir == 'S' || dir == 'W') {
      decimal = -decimal;
    }
    return decimal;
  }

  // 2点間の距離を計算するメソッド（単位: km）
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // 地球の半径（km）

    final lat1 = point1.latitude * pi / 180;
    final lat2 = point2.latitude * pi / 180;
    final dLat = (point2.latitude - point1.latitude) * pi / 180;
    final dLon = (point2.longitude - point1.longitude) * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // NMEAの時刻文字列をDateTimeに変換
  DateTime _parseTime(String time) {
    final hour = int.parse(time.substring(0, 2));
    final minute = int.parse(time.substring(2, 4));
    final second = int.parse(time.substring(4, 6));
    return DateTime(2024, 1, 1, hour, minute, second);
  }

  @override
  Widget build(BuildContext context) {
    // 経過時間の計算
    String durationText = '';
    if (trackData.startTime != null && trackData.endTime != null) {
      final start = _parseTime(trackData.startTime!);
      final end = _parseTime(trackData.endTime!);
      final duration = end.difference(start);
      durationText =
          '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            if (trackData.points.isNotEmpty)
              Text(
                '距離: ${trackData.totalDistance.toStringAsFixed(2)}km  時間: $durationText',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isMapVisible ? Icons.visibility_off : Icons.visibility),
            tooltip: isMapVisible ? '地図を隠す' : '地図を表示',
            onPressed: () {
              setState(() {
                isMapVisible = !isMapVisible;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: isMapVisible ? Colors.transparent : Colors.white,
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter:
                trackData
                    .points
                    .isNotEmpty // centerをinitialCenterに変更
                ? trackData.points[0]
                : LatLng(35.6812, 139.7671),
            initialZoom: 13.0, // zoomをinitialZoomに変更
          ),
          children: [
            if (isMapVisible)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                tileProvider: CancellableNetworkTileProvider(), // 追加
              ),
            if (trackData.points.isNotEmpty) ...[
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: trackData.points,
                    strokeWidth: 3.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // スタート地点のマーカー
                  Marker(
                    point: trackData.points.first,
                    alignment: Alignment.centerRight,
                    child: Stack(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          color: Colors.green,
                          size: 40,
                        ),
                        Icon(
                          Icons.play_circle_filled,
                          color: Colors.white.withAlpha(
                            127,
                          ), // withValuesをwithAlphaに変更
                          size: 36,
                        ),
                      ],
                    ),
                  ),
                  // ゴール地点のマーカー
                  Marker(
                    point: trackData.points.last,
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      children: [
                        Icon(Icons.flag_circle, color: Colors.red, size: 40),
                        Icon(
                          Icons.flag_circle,
                          color: Colors.white.withAlpha(
                            127,
                          ), // withValuesをwithAlphaに変更
                          size: 36,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openFile,
        tooltip: 'Open NMEA File',
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}

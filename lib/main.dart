import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NMEA Viewer',
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

class _MyHomePageState extends State<MyHomePage> {
  List<LatLng> trackPoints = [];
  final MapController mapController = MapController();
  bool isMapVisible = true; // 追加: 地図表示モードの状態

  Future<void> _openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = File(result.files.single.path!);
      final lines = await file.readAsLines();

      final List<LatLng> points = [];

      for (var line in lines) {
        try {
          if (line.startsWith('\$GPGGA')) {
            final parts = line.split(',');
            if (parts.length >= 6 && parts[6] != '0') {
              final lat = _convertNmeaToDecimal(parts[2], parts[3]);
              final lng = _convertNmeaToDecimal(parts[4], parts[5]);
              points.add(LatLng(lat, lng));
            }
          } else if (line.startsWith('\$GNRMC')) {
            final parts = line.split(',');
            if (parts.length >= 7 && parts[2] == 'A') {
              final lat = _convertNmeaToDecimal(parts[3], parts[4]);
              final lng = _convertNmeaToDecimal(parts[5], parts[6]);
              points.add(LatLng(lat, lng));
            }
          }
        } catch (e) {
          debugPrint('Error parsing NMEA data: $e');
        }
      }

      setState(() {
        trackPoints = points;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
                trackPoints
                    .isNotEmpty // centerをinitialCenterに変更
                ? trackPoints[0]
                : LatLng(35.6812, 139.7671),
            initialZoom: 13.0, // zoomをinitialZoomに変更
          ),
          children: [
            if (isMapVisible)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            if (trackPoints.isNotEmpty) ...[
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: trackPoints,
                    strokeWidth: 3.0,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // スタート地点のマーカー
                  Marker(
                    point: trackPoints.first,
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
                    point: trackPoints.last,
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

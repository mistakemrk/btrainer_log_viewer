import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/track_data.dart';
import '../constants.dart';

class TrackMap extends StatelessWidget {
  final TrackData trackData;
  final MapController mapController;
  final bool isMapVisible;

  const TrackMap({
    super.key,
    required this.trackData,
    required this.mapController,
    required this.isMapVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isMapVisible ? Colors.transparent : Colors.white,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: trackData.hasData
              ? trackData.points.first
              : AppConstants.defaultCenter,
          initialZoom: AppConstants.defaultZoom,
        ),
        children: [
          if (isMapVisible)
            TileLayer(
              urlTemplate: AppConstants.mapUrl,
              userAgentPackageName: AppConstants.userAgent,
              tileProvider: NetworkTileProvider(),
            ),
          if (trackData.hasData) ...[_buildTrackLine(), _buildMarkers()],
        ],
      ),
    );
  }

  Widget _buildTrackLine() {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: trackData.points,
          color: Colors.blue,
          strokeWidth: 3.0,
        ),
      ],
    );
  }

  Widget _buildMarkers() {
    return MarkerLayer(
      markers: [
        // スタート地点のマーカー
        Marker(
          point: trackData.points.first,
          width: 80,
          height: 80,
          child: Icon(Icons.start, color: Colors.green, size: 30),
        ),
        // ゴール地点のマーカー
        Marker(
          point: trackData.points.last,
          width: 80,
          height: 80,
          child: Icon(Icons.flag, color: Colors.red, size: 30),
        ),
      ],
    );
  }
}

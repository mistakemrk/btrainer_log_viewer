import 'package:latlong2/latlong.dart';

class AppConstants {
  static final defaultCenter = LatLng(35.6812, 139.7671);
  static const defaultZoom = 13.0;
  static const earthRadius = 6371.0; // 地球の半径（km）
  static const mapUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgent = 'com.example.app';
}

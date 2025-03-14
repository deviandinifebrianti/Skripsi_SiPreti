import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_feature_geolocator/flutter_feature_geolocator.dart';
import 'package:absensi/pages/kamera2.dart';

class LokasiPage extends StatefulWidget {
  @override
  _LokasiPageState createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Meminta izin lokasi
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Mendapatkan lokasi saat ini
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } else {
      // Tangani jika izin ditolak
      print('Akses lokasi ditolak');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location',
          style: TextStyle(
              color: Colors.white), // Mengubah warna teks menjadi putih
        ),
        backgroundColor: const Color.fromARGB(255, 33, 137, 235),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white, // Mengubah warna ikon menjadi putih
          ),
          onPressed: () {
            Navigator.pop(context); // Aksi untuk kembali ke halaman sebelumnya
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Image.asset(
              'assets/pemkot_mlg.png', // Ganti dengan path logo Anda
              height: 40,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/profil.png', // Ganti dengan path logo kedua
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentPosition!,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        maxZoom: 19,
                      ),
                      CurrentLocationLayer(), // Layer untuk lokasi saat ini

                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: _currentPosition!,
                            color: Colors.blue.withOpacity(0.3),
                            borderStrokeWidth: 2,
                            borderColor: Colors.blue,
                            radius: 45,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPosition != null) {
                        // Navigasi ke halaman kamera
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                KameraPage(), // Ganti dengan halaman kamera Anda
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Pilih Lokasi',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
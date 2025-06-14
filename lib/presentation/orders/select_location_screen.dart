import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? _selected;
  late GoogleMapController _controller;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    await Geolocator.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona tu ubicación')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-12.0464, -77.0428),
          zoom: 14,
        ),
        onMapCreated: (c) => _controller = c,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: (p) => setState(() => _selected = p),
        markers: _selected == null
            ? {}
            : {
          Marker(
            markerId: const MarkerId('selected'),
            position: _selected!,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selected == null
            ? null
            : () => Navigator.pop(context, _selected),
        child: const Icon(Icons.check),
      ),
    );
  }
}

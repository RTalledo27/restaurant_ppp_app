import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackOrderMapWidget extends StatelessWidget {
  final String orderId;
  const TrackOrderMapWidget({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final deliveryLocation = data['deliveryLocation'];

        if (deliveryLocation == null) {
          return const Center(child: Text("El repartidor aún no inicia el envío"));
        }

        final LatLng pos = LatLng(
          deliveryLocation['lat'],
          deliveryLocation['lng'],
        );

        return GoogleMap(
          initialCameraPosition: CameraPosition(target: pos, zoom: 16),
          markers: {
            Marker(
              markerId: const MarkerId('delivery'),
              position: pos,
              infoWindow: const InfoWindow(title: 'Repartidor'),
            ),
          },
        );
      },
    );
  }
}

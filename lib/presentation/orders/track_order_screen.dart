import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/order_providers.dart';
import '../routes/app_routes.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  final String orderId;
  const TrackOrderScreen({super.key, required this.orderId});

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  GoogleMapController? _controller;
  final List<LatLng> _path = [];

  @override
  void initState() {
    super.initState();
    ref.listen(orderStreamProvider(widget.orderId), (prev, next) {
      next.whenOrNull(data: (order) {
        final loc = order.deliveryLocation;
        if (loc == null) return; // Aún no hay ubicación

        final pos = LatLng(
          (loc['lat'] as num).toDouble(),
          (loc['lng'] as num).toDouble(),
        );

        if (_path.isEmpty ||
            _path.last.latitude != pos.latitude ||
            _path.last.longitude != pos.longitude) {
          setState(() {
            _path.add(pos);
          });
        }
        _controller?.animateCamera(CameraUpdate.newLatLng(pos));
      });
    });
  }

  @override
  void didUpdateWidget(covariant TrackOrderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _controller = null;
      _path.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderStreamProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de pedido'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: orderAsync.when(
        data: (order) {
          // -------- 1. Ubicación del repartidor --------
          final deliveryLoc = order.deliveryLocation;
          if (deliveryLoc == null) {
            return const Center(child: Text('Aún no hay ubicación del repartidor'));
          }

          final deliveryPos = LatLng(
            (deliveryLoc['lat'] as num).toDouble(),
            (deliveryLoc['lng'] as num).toDouble(),
          );

          // -------- 2. Destino (puede ser null) --------
          final destLoc = order.location;
          final LatLng? destPos = destLoc == null
              ? null
              : LatLng(
            (destLoc['lat'] as num).toDouble(),
            (destLoc['lng'] as num).toDouble(),
          );

          final initialPos = _path.isNotEmpty ? _path.last : deliveryPos;

          return GoogleMap(
            key: const ValueKey('track_map'),
            initialCameraPosition: CameraPosition(target: initialPos, zoom: 14),
            onMapCreated: (c) => _controller = c,
            markers: {
              Marker(markerId: const MarkerId('delivery'), position: deliveryPos),
              if (destPos != null)
                Marker(markerId: const MarkerId('dest'), position: destPos),
            },
            polylines: {
              if (_path.length > 1)
                Polyline(
                  polylineId: const PolylineId('path'),
                  color: Colors.blue,
                  width: 4,
                  points: _path,
                ),
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

extension TrackOrderArgs on TrackOrderScreen {
  static Route route(String orderId) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: Routes.trackOrder),
      builder: (_) => TrackOrderScreen(orderId: orderId),
    );
  }
}

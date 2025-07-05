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
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(orderStreamProvider(widget.orderId), (prev, next) {
      next.whenOrNull(data: (order) {
        final loc = order.deliveryLocation;
        if (loc == null) return;

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

        if (_isMapReady) {
          _controller?.animateCamera(
            CameraUpdate.newLatLngZoom(pos, 16),
          );
        }
      });
    });

    final orderAsync = ref.watch(orderStreamProvider(widget.orderId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context),
      body: orderAsync.when(
        data: (order) => _buildTrackingContent(order),
        loading: () => _buildLoadingState(),
        error: (e, _) => _buildErrorState(e.toString()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'Seguimiento de Pedido',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando información del pedido...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el seguimiento',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent(order) {
    final deliveryLoc = order.deliveryLocation;

    if (deliveryLoc == null) {
      return _buildWaitingForDelivery();
    }

    final deliveryPos = LatLng(
      (deliveryLoc['lat'] as num).toDouble(),
      (deliveryLoc['lng'] as num).toDouble(),
    );

    final destLoc = order.location;
    final LatLng? destPos = destLoc == null
        ? null
        : LatLng(
      (destLoc['lat'] as num).toDouble(),
      (destLoc['lng'] as num).toDouble(),
    );

    final initialPos = _path.isNotEmpty ? _path.last : deliveryPos;

    return Column(
      children: [
        // Order Status Header
        _buildOrderStatusHeader(order),

        // Map
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GoogleMap(
                key: const ValueKey('track_map'),
                initialCameraPosition: CameraPosition(
                  target: initialPos,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _controller = controller;
                  setState(() {
                    _isMapReady = true;
                  });
                },
                markers: _buildMarkers(deliveryPos, destPos),
                polylines: _buildPolylines(),
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ),

        // Delivery Info
        _buildDeliveryInfo(order),
      ],
    );
  }

  Widget _buildWaitingForDelivery() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[300]!, Colors.orange[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.schedule,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Esperando al repartidor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'El repartidor aún no ha iniciado el envío.\nTe notificaremos cuando comience el seguimiento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'El seguimiento en tiempo real estará disponible una vez que el repartidor inicie la entrega.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusHeader(order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido #${order.id}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusMessage(order.status),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusLabel(order.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(order) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text(
                'Información de Entrega',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Artículos',
                  value: '${order.items.length}',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.attach_money,
                  label: 'Total',
                  value: '\$${order.total.toStringAsFixed(2)}',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.store, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sucursal: ${order.branchId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(LatLng deliveryPos, LatLng? destPos) {
    return {
      Marker(
        markerId: const MarkerId('delivery'),
        position: deliveryPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: '🚚 Repartidor',
          snippet: 'Ubicación actual',
        ),
      ),
      if (destPos != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: destPos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: '🏠 Destino',
            snippet: 'Tu ubicación',
          ),
        ),
    };
  }

  Set<Polyline> _buildPolylines() {
    return {
      if (_path.length > 1)
        Polyline(
          polylineId: const PolylineId('delivery_path'),
          color: Colors.blue,
          width: 4,
          points: _path,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
    };
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Tu pedido está siendo preparado';
      case 'in_progress':
        return 'El repartidor está en camino';
      case 'completed':
        return 'Tu pedido ha sido entregado';
      default:
        return 'Estado del pedido: $status';
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Preparando';
      case 'in_progress':
        return 'En Camino';
      case 'completed':
        return 'Entregado';
      default:
        return status;
    }
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/order_providers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../routes/app_routes.dart';
import '../../services/notification_service.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  final Map<String, String> _statuses = {};
  bool _isListenerAdded = false;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Solo agregamos el listener una vez
    if (!_isListenerAdded) {
      ref.listen(userOrderListStreamProvider(uid), (previous, next) {
        next.whenData((orders) {
          for (final o in orders) {
            final prev = _statuses[o.id];
            if (prev != null && prev != o.status) {
              NotificationService.showOrderStatus(o.id, o.status);
            }
            _statuses[o.id] = o.status;
          }
        });
      });
      _isListenerAdded = true;
    }

    final ordersAsync = ref.watch(userOrderListStreamProvider(uid));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ),
      body: ordersAsync.when(
        data: (orders) => orders.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userOrderListStreamProvider(uid));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i];
              return _buildOrderCard(context, order, i);
            },
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        error: (e, _) => _buildErrorState(e.toString()),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus pedidos aparecerán aquí',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
            'Error al cargar pedidos',
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

  Widget _buildOrderCard(BuildContext context, dynamic order, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showDetail(context, order),
            child: Padding(
              padding: const EdgeInsets.all(16), // ✅ REDUCIDO de 20 a 16
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ PRIMERA FILA: Status y flecha - MÁS COMPACTA
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // ✅ REDUCIDO de 12 a 10
                          vertical: 4,   // ✅ REDUCIDO de 6 a 4
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16), // ✅ REDUCIDO de 20 a 16
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(order.status),
                              size: 12, // ✅ REDUCIDO de 14 a 12
                              color: _getStatusColor(order.status),
                            ),
                            const SizedBox(width: 3), // ✅ REDUCIDO de 4 a 3
                            Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                fontSize: 11, // ✅ REDUCIDO de 12 a 11
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(order.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14, // ✅ REDUCIDO de 16 a 14
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // ✅ REDUCIDO de 16 a 12

                  // ✅ SEGUNDA FILA: ID del pedido y precio - OPTIMIZADA
                  Row(
                    children: [
                      Expanded( // ✅ AGREGADO Expanded para evitar overflow
                        child: Text(
                          'Pedido #${order.id}',
                          style: const TextStyle(
                            fontSize: 16, // ✅ REDUCIDO de 18 a 16
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis, // ✅ AGREGADO para truncar texto largo
                        ),
                      ),
                      const SizedBox(width: 8), // ✅ AGREGADO espacio entre elementos
                      Text(
                        'S/. ${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16, // ✅ REDUCIDO de 18 a 16
                          fontWeight: FontWeight.w700,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8), // ✅ REDUCIDO de 12 a 8

                  // ✅ TERCERA FILA: Detalles del pedido - MÁS COMPACTA
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 14, // ✅ REDUCIDO de 16 a 14
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6), // ✅ REDUCIDO de 8 a 6
                      Flexible( // ✅ CAMBIADO de Text a Flexible para evitar overflow
                        child: Text(
                          '${order.items.length} ${order.items.length == 1 ? 'artículo' : 'artículos'}',
                          style: TextStyle(
                            fontSize: 12, // ✅ REDUCIDO de 14 a 12
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12), // ✅ REDUCIDO de 16 a 12
                      Icon(
                        Icons.access_time,
                        size: 14, // ✅ REDUCIDO de 16 a 14
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6), // ✅ REDUCIDO de 8 a 6
                      Flexible( // ✅ CAMBIADO de Text a Flexible para evitar overflow
                        child: Text(
                          _formatDate(order.createdAt),
                          style: TextStyle(
                            fontSize: 12, // ✅ REDUCIDO de 14 a 12
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'in_progress':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _formatDate(dynamic date) {
    // Implementa tu lógica de formateo de fecha aquí
    return 'Hace 2 horas'; // Placeholder
  }

  void _showDetail(BuildContext context, dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Consumer(
          builder: (context, ref, _) {
            final orderAsync = ref.watch(orderStreamProvider(order.id));
            return orderAsync.when(
              data: (liveOrder) => _OrderDetailContent(order: liveOrder),
              loading: () => Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Container(
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Text('Error: $e'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OrderDetailContent extends ConsumerStatefulWidget {
  final dynamic order;
  const _OrderDetailContent({required this.order});

  @override
  ConsumerState<_OrderDetailContent> createState() =>
      _OrderDetailContentState();
}

class _OrderDetailContentState extends ConsumerState<_OrderDetailContent> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    // Escucha cambios de la orden en tiempo real
    ref.listen(orderStreamProvider(order.id), (previous, next) {
      next.whenData((updatedOrder) {
        final loc = updatedOrder.deliveryLocation;
        if (loc != null && _controller != null) {
          final newPos = LatLng(
            (loc['lat'] as num).toDouble(),
            (loc['lng'] as num).toDouble(),
          );
          _controller!.animateCamera(CameraUpdate.newLatLng(newPos));
        }
      });
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pedido #${order.id}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatusIcon(order.status),
                                        size: 16,
                                        color: _getStatusColor(order.status),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _getStatusText(order.status),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(order.status),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Items section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 20,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Artículos del pedido',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...order.items.map<Widget>((item) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Cantidad: ${item.quantity}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'S/. ${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Total section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[50]!, Colors.green[100]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total del pedido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'S/. ${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Map section
                      if (order.deliveryLocation != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 200,
                              child: GoogleMap(
                                key: ValueKey(order.deliveryLocation),
                                onMapCreated: (c) => _controller = c,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    (order.deliveryLocation['lat'] as num).toDouble(),
                                    (order.deliveryLocation['lng'] as num).toDouble(),
                                  ),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('delivery'),
                                    position: LatLng(
                                      (order.deliveryLocation['lat'] as num).toDouble(),
                                      (order.deliveryLocation['lng'] as num).toDouble(),
                                    ),
                                  ),
                                  if (order.location != null)
                                    Marker(
                                      markerId: const MarkerId('dest'),
                                      position: LatLng(
                                        (order.location['lat'] as num).toDouble(),
                                        (order.location['lng'] as num).toDouble(),
                                      ),
                                    ),
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Action buttons
                      if (order.status == 'in_progress' && order.deliveryId != null)
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                  context,
                                  Routes.trackOrder,
                                  arguments: order.id,
                                );
                              },
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Ver seguimiento en tiempo real',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'El seguimiento estará disponible cuando el pedido esté en camino',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'in_progress':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'in_progress':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado <3';
      default:
        return status;
    }
  }
}

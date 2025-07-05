import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  LatLng? _selected;
  String? _selectedAddress;
  GoogleMapController? _controller;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final latLng = LatLng(pos.latitude, pos.longitude);

        setState(() {
          _selected = latLng;
        });

        await _moveToLocation(latLng);
        await _updateAddressFromCoords(latLng);
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      _showErrorSnackBar('Error al obtener ubicación: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Permisos de Ubicación'),
          ],
        ),
        content: const Text(
          'Para una mejor experiencia, permite el acceso a tu ubicación. Puedes seleccionar manualmente en el mapa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _moveToLocation(LatLng latLng) async {
    if (_controller != null) {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 16),
      );
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);

        setState(() {
          _selected = latLng;
        });

        await _moveToLocation(latLng);
        await _updateAddressFromCoords(latLng);

        // Hide keyboard
        FocusScope.of(context).unfocus();
      } else {
        _showErrorSnackBar('No se encontró la dirección');
      }
    } catch (e) {
      _showErrorSnackBar('Error en la búsqueda: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _updateAddressFromCoords(LatLng latLng) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          p.street,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        setState(() {
          _selectedAddress = address.isNotEmpty ? address : 'Dirección no disponible';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Error al obtener dirección';
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildMapContent(),
      floatingActionButton: _buildConfirmButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        'Selecciona tu Ubicación',
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
            'Obteniendo tu ubicación...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapContent() {
    return Stack(
      children: [
        // Map
        Container(
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
              initialCameraPosition: const CameraPosition(
                target: LatLng(-12.0464, -77.0428), // Lima, Peru
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _controller = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onTap: (position) {
                setState(() {
                  _selected = position;
                });
                _updateAddressFromCoords(position);
              },
              markers: _selected == null
                  ? {}
                  : {
                Marker(
                  markerId: const MarkerId('selected'),
                  position: _selected!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: const InfoWindow(
                    title: '📍 Tu ubicación',
                    snippet: 'Ubicación seleccionada',
                  ),
                ),
              },
            ),
          ),
        ),

        // Search Bar
        Positioned(
          top: 32,
          left: 32,
          right: 32,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar dirección...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: _isSearching
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(Icons.search, color: Colors.blue[600]),
                    onPressed: _isSearching ? null : _searchLocation,
                  ),
                ),
              ],
            ),
          ),
        ),

        // My Location Button
        Positioned(
          top: 120,
          right: 32,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _checkPermission,
            child: Icon(
              Icons.my_location,
              color: Colors.blue[600],
            ),
          ),
        ),

        // Address Display
        if (_selectedAddress != null)
          Positioned(
            bottom: 100,
            left: 32,
            right: 32,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Ubicación seleccionada',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        gradient: _selected != null
            ? LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: _selected == null ? Colors.grey[300] : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _selected != null
            ? [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _selected == null
              ? null
              : () => Navigator.pop(context, _selected),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: _selected != null ? Colors.white : Colors.grey[500],
                ),
                const SizedBox(width: 8),
                Text(
                  'Confirmar Ubicación',
                  style: TextStyle(
                    color: _selected != null ? Colors.white : Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
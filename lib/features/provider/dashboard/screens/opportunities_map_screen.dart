import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';
import 'package:app_incide/features/provider/dashboard/models/map_opportunities_provider.dart';
import 'package:app_incide/features/provider/dashboard/widgets/opportunity_summary_sheet.dart';

class OpportunitiesMapScreen extends ConsumerStatefulWidget {
  const OpportunitiesMapScreen({super.key});

  @override
  ConsumerState<OpportunitiesMapScreen> createState() =>
      _OpportunitiesMapScreenState();
}

class _OpportunitiesMapScreenState
    extends ConsumerState<OpportunitiesMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String _locationError = '';

  // Coordenadas centrales de Hermosillo por defecto por si falla el GPS
  static const LatLng _hermosilloCenter = LatLng(29.08919, -110.96133);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Función estándar de Geolocator para pedir permisos y obtener ubicación
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception(AppStrings.mapLocationDisabled);
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(AppStrings.mapLocationDenied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(AppStrings.mapLocationDeniedForever);
      }

      // Si todo está bien, obtenemos la posición actual
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Si el mapa ya cargó, animamos la cámara hacia el usuario
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            14.0, // Zoom a nivel de colonia
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationError = e.toString();
      });
    }
  }

  /// Convierte nuestra lista de Oportunidades en Marcadores de Google Maps
  Set<Marker> _buildMarkers(List<OpportunityModel> opportunities) {
    return opportunities.map((opp) {
      // Definimos el color del pin según el tipo de oportunidad
      double hueColor;
      switch (opp.type) {
        case OpportunityType.urgent:
          hueColor = BitmapDescriptor.hueRed;
          break;
        case OpportunityType.special:
          hueColor = BitmapDescriptor.hueYellow;
          break;
        case OpportunityType.normal:
          hueColor = BitmapDescriptor.hueAzure;
          break;
      }

      return Marker(
        markerId: MarkerId(opp.id),
        position: LatLng(opp.latitude, opp.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hueColor),
        infoWindow: InfoWindow(
          title: opp.title,
          snippet: opp.formattedPriceRange,
        ),
        onTap: () {
          // 1. Calculamos la distancia real si tenemos la ubicación del GPS
          double realDistanceKm =
              opp.distance; // Usamos la del mock por defecto

          // Si tenemos la ubicación del usuario, calculamos la distancia real
          if (_currentPosition != null) {
            // Retorna la distancia en metros
            double distanceInMeters = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              opp.latitude,
              opp.longitude,
            );
            // Convertimos a Kilómetros
            realDistanceKm = distanceInMeters / 1000;
          }

          final updatedOpp = opp.copyWith(distance: realDistanceKm);

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return OpportunitySummarySheet(
                opportunity: updatedOpp,
                onSeeDetailsPressed: () {
                  Navigator.pop(context);

                  context.pushNamed('opportunity_detail', extra: updatedOpp);
                },
              );
            },
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    // Leemos las oportunidades del estado global
    final opportunities = ref.watch(mapOpportunitiesProvider);
    final markers = _buildMarkers(opportunities);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.mapOpportunitiesTitle),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // 1. El Widget del Mapa
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    )
                  : _hermosilloCenter,
              zoom: 13.0,
            ),
            markers: markers,
            myLocationEnabled: true, // Muestra el puntito azul del usuario
            myLocationButtonEnabled:
                false, // Ocultamos el botón por defecto para hacer el nuestro
            zoomControlsEnabled:
                false, // Ocultamos los botones de +/- para un look más limpio
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // 2. Estado de Carga Inicial
          if (_isLoadingLocation)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // 3. Alerta si no hay permisos de GPS
          if (_locationError.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  AppStrings.mapUnableToGetLocation + _locationError,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),

      // 4. Botón flotante para re-centrar el mapa en el usuario
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        onPressed: () {
          if (_currentPosition != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                15.0,
              ),
            );
          } else {
            _determinePosition(); // Reintenta obtener la ubicación
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mlodin90/common_widgets/custom_appbar.dart';
import 'package:mlodin90/constants/app_constants.dart';
import 'package:mlodin90/helpers/di.dart';
import 'package:mlodin90/routes/app_routes.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  LatLng initialLatLang = const LatLng(40.7128, -74.0060);
  String locationName = "Fetching location...";
  final TextEditingController searchController = TextEditingController();
  MapType currentMapType = MapType.satellite;

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      userCurrentLocation();
    }
  }

  Future<void> userCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      initialLatLang = LatLng(position.latitude, position.longitude);
    });
    await getAddressFromLatLng(initialLatLang);

    animateToLocation(initialLatLang);
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks.first;
      setState(() {
        locationName =
            "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        locationName = "Location not found";
      });
    }
  }

  void selectLocationOntap(LatLng position) {
    setState(() {
      selectedLocation = position;
    });
    getAddressFromLatLng(position);
    animateToLocation(position);
  }

  Future<void> searchLocation(String query) async {
    if (query.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(query);
        LatLng searchedLocation = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        setState(() {
          selectedLocation = searchedLocation;
          locationName = query;
        });
        animateToLocation(searchedLocation);
      } catch (e) {
        setState(() {
          locationName = "Location not found";
        });
      }
    }
  }

  void animateToLocation(LatLng position, {double zoom = 16.0}) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(position, zoom));
  }

  void centerToUserLocation() async {
    final position = await Geolocator.getCurrentPosition();
    final currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      selectedLocation = currentLatLng;
    });

    await getAddressFromLatLng(currentLatLng);
    animateToLocation(currentLatLng);
  }

  void onMapTyped(MapType? value) {
    if (value != null) {
      setState(() {
        currentMapType = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      extendBodyBehindAppBar: true,
      appBar: CustomAppbar(title: 'Location Set'),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: false,
            compassEnabled: false,
            indoorViewEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: initialLatLang,
              zoom: 15,
            ),
            onTap: selectLocationOntap,
            markers:
                selectedLocation != null
                    ? {
                      Marker(
                        markerId: const MarkerId("selected"),
                        position: selectedLocation!,
                      ),

                      Marker(
                        markerId: const MarkerId("current"),
                        position: initialLatLang,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                      ),
                    }
                    : {
                      Marker(
                        markerId: const MarkerId("current"),
                        position: initialLatLang,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                      ),
                    },
            mapType: currentMapType,
          ),

          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: Material(
              elevation: 6,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(6),
              child: TextField(
                controller: searchController,
                onSubmitted: searchLocation,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () => searchLocation(searchController.text),
                    icon: Icon(Icons.arrow_downward_sharp),
                  ),

                  hintText: 'Search for a location',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ),

          // Location Info Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        locationName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          
          Positioned(
            bottom: 100,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildControlButton(
                  icon: Icons.my_location,
                  label: "My Location",
                  onTap: centerToUserLocation,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 12),
                _buildControlButton(
                  icon: Icons.navigation,
                  label: "Go To",
                  onTap: () {
                    if (locationName.isNotEmpty &&
                        locationName != "Fetching location..." &&
                        locationName != "Location not found") {
                      log(locationName);
                      appData.write(kKeyLocation, locationName);

                      Get.toNamed(AppRoutes.navigationScreen);
                    } else {
                      log("No location selected yet");
                    }
                  },
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Custom Button Widget
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

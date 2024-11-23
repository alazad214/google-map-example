import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationExample extends StatefulWidget {
  const LocationExample({super.key});

  @override
  State<LocationExample> createState() => _LocationExampleState();
}

class _LocationExampleState extends State<LocationExample> {

  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();

  LatLng? location;
  String address = "Loading...";
  String searchQuery = "";
  final Set<Marker> markers = {};


  final CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(
      23.76538939221395,
      90.42238113516323,
    ),
    zoom: 14,
  );


  Future<void> getCurrentLocation() async {
    Position position = await _determinePosition();
    CameraPosition newCameraPosition = CameraPosition(
      target: LatLng(
        position.latitude,
        position.longitude,
      ),
      zoom: 14,
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        newCameraPosition,
      ),
    );

    setState(() {
      location = LatLng(
        position.latitude,
        position.longitude,
      );
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
            title: "Current Location",
            snippet: address,
          ),
        ),
      );
    });

    getAddressFromLatLng(location!);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks.first;
      setState(() {
        address =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        address = "Something went wrong";
      });
    }
  }

  //SEARCH LOCAITON...

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        CameraPosition newCameraPosition = CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 14,
        );
        final GoogleMapController controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));

        setState(() {
          this.location = LatLng(location.latitude, location.longitude);
          address = query;
        });

        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('1'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: "Searched Location",
              snippet: address,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        address = "Unable to find location";
      });
    }
  }

//INITSATATE...
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

//DISPOSE..
  @override
  void dispose() {
    _searchController.dispose();
    markers;
    location;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(location?.latitude);
    print(location?.longitude);
    print('build');
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: cameraPosition,
              mapType: MapType.terrain,
              myLocationEnabled: true,
              markers: markers,
              onTap: (LatLng position) {
                setState(() {
                  location = position;
                  getAddressFromLatLng(position);
                  markers.clear();
                  markers.add(
                    Marker(
                      markerId: const MarkerId('1'),
                      position: position,
                      infoWindow: InfoWindow(
                        title: "Selected Location",
                        snippet: address,
                      ),
                    ),
                  );
                });
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),

            //LOCATION SEARCH WIDGET...
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.black),
                            onPressed: () {
                              searchLocation(_searchController.text);
                            },
                          ),
                        ),
                        onSubmitted: (query) {
                          searchLocation(query);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        height: 180,
        padding: EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 15,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {},
              child: Container(
                height: 5,
                width: 100,
                color: Colors.red,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Icon(Icons.location_pin),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                  child: Text(address),
                ),
                SizedBox(
                  width: 5,
                ),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      'Change',
                    ))
              ],
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

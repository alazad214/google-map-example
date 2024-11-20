/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moises/constants/text_font_style.dart';
import 'package:moises/features/location/widgets/live_location_bottomSheet.dart';
import 'package:moises/gen/assets.gen.dart';
import 'package:moises/gen/colors.gen.dart';
import 'package:moises/helpers/navigation_service.dart';
import 'package:moises/helpers/ui_helpers.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _GPSSearchScreenState();
}

class _GPSSearchScreenState extends State<CurrentLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  // Default location...
  final CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(23.76538939221395, 90.42238113516323),
    zoom: 14,
  );

  LatLng? location;
  String address = "Select a location";

  final Set<Marker> _markers = {};

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
        address = "Something Wrong";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: cameraPosition,
            mapType: MapType.terrain,
            myLocationEnabled: true,
            markers: _markers,
            onTap: (LatLng position) {
              setState(() {
                location = position;
                showLocationSheet(context, address);

                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: const MarkerId("selected location"),
                    position: position,
                    infoWindow: InfoWindow(
                      title: "Selected Location",
                      snippet: address,
                    ),
                  ),
                );
              });
              getAddressFromLatLng(position);
            },
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          //BACK BUTTON...
          Positioned(
              top: 30.h,
              left: 20.w,
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        NavigationService.goBack;
                      },
                      child: SvgPicture.asset(Assets.icons.arrowLeft)),
                  UIHelper.horizontalSpace(10),
                  Text(
                    'Enter Your locantion',
                    style: TextFontStyle.textStyle16c171717Popinsw500
                        .copyWith(color: AppColors.c000000),
                  )
                ],
              ))
        ],
      ),
    );
  }
}*/

//Current Location Pick

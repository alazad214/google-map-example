import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mlodin90/common_widgets/custom_textfield.dart';
import 'package:mlodin90/constants/app_colors.dart';
import 'package:mlodin90/constants/text_font_style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:styled_button/styled_button.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final LatLng latLng = LatLng(23.807520498964614, 90.41453522091558);
  bool isPermission = false;

  @override
  void initState() {
    super.initState();
    locationPermission();
  }

  Future<void> locationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      setState(() {
        isPermission = true;
      });
    } else if (status.isDenied) {
      EasyLoading.showToast('Permission denied by user');
    } else if (status.isPermanentlyDenied) {
      EasyLoading.showToast('Permission permanently denied');
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isPermission
              ? GoogleMap(
                mapType: MapType.normal,

                initialCameraPosition: CameraPosition(target: latLng, zoom: 14),
              )
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: StyledButton(
                    submit: () => locationPermission(),
                    provider: AuthButtonProvider.discord,
                    disableIcon: true,
                    buttonColor: AppColors.primaryColor,
                    textColor: AppColors.white,
                    text: 'Allow Location Permission',
                  ),
                ),
              ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 32),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon((Icons.arrow_back_ios), size: 18),
                    ),
                    Text(
                      'Your Location',
                      style: TextFontStyle.headline16w400c798090.copyWith(
                        color: AppColors.c000000,
                      ),
                    ),
                  ],
                ),

                CustomTextfield(
                  prefixIcon: Icon(Icons.search, color: AppColors.c767676),
                  hintText: 'Type location you want',
                  fillColor: AppColors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

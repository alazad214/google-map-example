import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  late GoogleMapController mapController;

  final LatLng initialPosition =
      const LatLng(26.08269302562089, 88.27248890910445);

  final RxSet<Marker> markers = <Marker>{}.obs;

  final String mapStyle = '''[
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#1E3E62"}]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#1E3E62"}]
    }
  ]''';

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(mapStyle);

    markers.add(
      Marker(
        markerId: const MarkerId('myLocation'),
        position: initialPosition,
        infoWindow: const InfoWindow(
          title: 'My Location',
          snippet: 'Baliadangi Upazila, Thakurgaon Distict',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    );
  }
}

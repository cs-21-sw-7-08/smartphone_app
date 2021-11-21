import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class Place extends ClusterItem {
  late LatLng latLng;
  final Issue issue;

  Place({required this.issue}) {
    latLng = LatLng(issue.location!.latitude, issue.location!.longitude);
  }

  @override
  LatLng get location => latLng;
}

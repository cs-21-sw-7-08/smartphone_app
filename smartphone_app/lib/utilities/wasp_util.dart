import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class WASPUtil {
  static BitmapDescriptor getIssueStateMarkerIcon(IssueState issueState) {
    switch (issueState.getEnum()) {
      case IssueStates.created:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case IssueStates.approved:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      case IssueStates.resolved:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case IssueStates.notResolved:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }
}

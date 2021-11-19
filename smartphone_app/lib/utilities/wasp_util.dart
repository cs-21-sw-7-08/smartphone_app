import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;

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

  static Color getIssueStateColor(IssueState issueState) {
    switch (issueState.getEnum()) {
      case IssueStates.created:
        return custom_colors.issueStateCreated;
      case IssueStates.approved:
        return custom_colors.issueStateApproved;
      case IssueStates.resolved:
        return custom_colors.issueStateResolved;
      case IssueStates.notResolved:
        return custom_colors.issueStateNotResolved;
    }
  }
}

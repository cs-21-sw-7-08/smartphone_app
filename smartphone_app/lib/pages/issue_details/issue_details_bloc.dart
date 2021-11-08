import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/issue_details/issue_details_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'dart:convert';

class IssueDetailsBloc extends Bloc<IssueDetailsEvent, IssueDetailsState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  // ignore: unused_field
  late BuildContext _buildContext;
  late Issue issue;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  IssueDetailsBloc(
      {required BuildContext buildContext,
      required this.issue,
      MapType? mapType})
      : super(IssueDetailsState(mapType: mapType ?? MapType.normal)) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<IssueDetailsState> mapEventToState(IssueDetailsEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.issueDetailsButtonEvent) {
        case IssueDetailsButtonEvent.verifyIssue:
          // TODO: Handle this case.
          break;
        case IssueDetailsButtonEvent.editIssue:
          // TODO: Handle this case.
          break;
      }
    } else if (event is PageContentLoaded) {
      yield state.copyWith(
          isCreator: event.isCreator,
          marker: event.marker,
          description: event.description,
          category: event.category,
          subCategory: event.subCategory,
          pictures: event.pictures);
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<bool> getValues() async {
    return await Future.delayed(const Duration(milliseconds: 500), () {
      bool isCreator;
      Marker? marker;
      var pictures = List<Image>.empty(growable: true);
      String? category;
      String? subCategory;
      String description;

      // IsCreator flag
      isCreator =
          AppValuesHelper.getInstance().getInteger(AppValuesKey.citizenId) ==
              issue.citizenId;
      // From location create Marker
      if (issue.location != null) {
        marker = Marker(
            markerId: MarkerId(issue.id.toString()),
            position:
                LatLng(issue.location!.latitude, issue.location!.longitude),
            consumeTapEvents: true,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      }
      // Pictures
      if (issue.picture1 != null) {
        pictures.add(Image.memory(base64Decode(issue.picture1!)));
      }
      if (issue.picture2 != null) {
        pictures.add(Image.memory(base64Decode(issue.picture2!)));
      }
      if (issue.picture3 != null) {
        pictures.add(Image.memory(base64Decode(issue.picture3!)));
      }
      // Category
      if (issue.category != null) {
        category = issue.category!.name!;
      }
      // SubCategory
      if (issue.subCategory != null) {
        subCategory = issue.subCategory!.name!;
      }
      // Category
      description = issue.description ?? "";
      // Fire event
      add(PageContentLoaded(
          isCreator: isCreator,
          marker: marker,
          description: description,
          pictures: pictures,
          category: category ?? "",
          subCategory: subCategory ?? ""));

      return true;
    });
  }

//endregion

}

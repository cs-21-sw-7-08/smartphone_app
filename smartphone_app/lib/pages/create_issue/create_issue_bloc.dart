import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/create_issue/create_issue_events_states.dart';
import 'package:smartphone_app/pages/select_location/select_location_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/location/locator_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:smartphone_app/values/values.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/models/google_classes.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/service/google_service.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import 'package:smartphone_app/widgets/custom_header.dart';
import 'package:smartphone_app/widgets/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';

class CreateIssueBloc extends Bloc<CreateIssueEvent, CreateIssueState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;
  late Issue? issue;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  CreateIssueBloc(
      {required BuildContext buildContext,
      required MapType mapType,
      this.issue})
      : super(CreateIssueState(
            mapType: mapType,
            createIssuePageView: issue == null
                ? CreateIssuePageView.create
                : CreateIssuePageView.edit)) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<CreateIssueState> mapEventToState(CreateIssueEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.createIssueButtonEvent) {
        case CreateIssueButtonEvent.selectLocation:
          LatLng? position = await GeneralUtil.showPageAsDialog<LatLng?>(
              _buildContext, SelectLocationPage(mapType: state.mapType!));
          if (position == null) return;
          var newState = await getLocationInformation(position);
          if (newState == null) return;
          yield newState;
          break;
        case CreateIssueButtonEvent.selectCategory:
          Category? selectedCategory;
          SubCategory? selectedSubCategory;
          List<Category> categories =
              AppValuesHelper.getInstance().getCategories();
          var flag = await CustomListDialog.show(_buildContext,
              items: categories, itemBuilder: (item, itemSelected) {
            if (item is Category) {
              return CustomListTile(
                  widget: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        CustomHeader(
                          title: item.name!,
                          margin: const EdgeInsets.only(
                              left: 10, top: 20, right: 10, bottom: 20),
                        )
                      ],
                    ),
                  ),
                  onPressed: () {
                    selectedCategory = item;
                    itemSelected(item.subCategories);
                  });
            } else if (item is SubCategory) {
              return CustomListTile(
                  widget: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        CustomHeader(
                          title: item.name!,
                          margin: const EdgeInsets.only(
                              left: 10, top: 20, right: 10, bottom: 20),
                        )
                      ],
                    ),
                  ),
                  onPressed: () {
                    selectedSubCategory = item;
                    itemSelected(null);
                  });
            }
            return Container(
              height: 50,
            );
          }, searchPredicate: (item, searchString) {
            return true;
          });
          if (!flag) return;
          yield state.copyWith(
              category: selectedCategory, subCategory: selectedSubCategory);
          break;
        case CreateIssueButtonEvent.selectPicture:
          // TODO: Handle this case.
          break;
        case CreateIssueButtonEvent.saveChanges:
          // TODO: Handle this case.
          break;
      }
    } else if (event is TextChanged) {
      switch (event.createIssueTextChangedEvent) {
        case CreateIssueTextChangedEvent.description:
          yield state.copyWith(description: event.value);
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<CreateIssueState?> getLocationInformation(LatLng position) async {
    // Create marker
    var marker = Marker(
        markerId: MarkerId(position.toString()),
        position: LatLng(position.latitude, position.longitude),
        consumeTapEvents: true,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
    // Get address coordinate information
    GoogleServiceResponse<AddressFromCoordinateResponse> response =
        await GoogleService.getInstance().getAddressFromCoordinate(position);
    // Check for errors
    if (!response.isSuccess) {
      GeneralUtil.showToast(response.errorMessage!);
      return null;
    }
    // Address coordinate result
    AddressFromCoordinateResult addressFromCoordinateResult =
        response.googleResponse!.results![0];
    // Get municipality
    var addressComponents = addressFromCoordinateResult.addressComponents!
        .where((element) => element.types.contains("locality"));
    AddressComponent? addressComponent =
        addressComponents.isNotEmpty ? addressComponents.first : null;
    if (addressComponent == null) return null;
    // Get address
    String address = addressFromCoordinateResult.formattedAddress!;
    // Get municipality name
    String municipalityName = addressComponent.shortName;
    // Return new state
    return state.copyWith(
        marker: marker, municipalityName: municipalityName, address: address);
  }

  Future<bool> getValues() async {
    if (issue != null) {
      return await Future.delayed(
          const Duration(milliseconds: pageTransitionTime), () async {
        Marker? marker;
        String? address;
        var pictures = List<Image>.empty(growable: true);
        Category? category;
        SubCategory? subCategory;
        String description;

        // From location create Marker
        if (issue!.location != null) {
          marker = Marker(
              markerId: MarkerId(issue!.id.toString()),
              position:
                  LatLng(issue!.location!.latitude, issue!.location!.longitude),
              consumeTapEvents: true,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed));
        }
        // Pictures
        if (issue!.picture1 != null) {
          pictures.add(Image.memory(base64Decode(issue!.picture1!)));
        }
        if (issue!.picture2 != null) {
          pictures.add(Image.memory(base64Decode(issue!.picture2!)));
        }
        if (issue!.picture3 != null) {
          pictures.add(Image.memory(base64Decode(issue!.picture3!)));
        }
        // Category
        if (issue!.category != null) {
          category = issue!.category;
        }
        // SubCategory
        if (issue!.subCategory != null) {
          subCategory = issue!.subCategory;
        }
        // Category
        description = issue!.description ?? "";
        // Fire event
        add(PageContentLoaded(
            marker: marker,
            description: description,
            pictures: pictures,
            category: category,
            subCategory: subCategory,
            address: address));

        return true;
      });
    } else {
      return true;
    }
  }

//endregion

}

/*

var municipalities = AppValuesHelper.getInstance()
        .getMunicipalities()
        .where((element) =>
    element.name!.toLowerCase() == municipalityName.toLowerCase());
    if (municipalities.isEmpty) return null;
    var municipality = municipalities.first;
    var municipalityId = municipality.id;

LatLng? position = await GeneralUtil.showPageAsDialog<LatLng?>(
          _buildContext, SelectLocationPage());
      if (position == null) return;
      GoogleServiceResponse<GoogleResponse> response =
          await GoogleService.getInstance().getAddressFromCoordinate(position);
      if (!response.isSuccess) {
        GeneralUtil.showToast(response.errorMessage!);
        return;
      }
 */

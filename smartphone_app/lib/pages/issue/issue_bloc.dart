import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/select_location/select_location_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:smartphone_app/utilities/wasp_util.dart';
import 'package:smartphone_app/values/values.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/models/google_classes.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/service/google_service.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';

import 'package:smartphone_app/widgets/custom_header.dart';
import 'package:smartphone_app/widgets/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';
import 'package:smartphone_app/widgets/image_picker_dialog.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

import 'issue_events_states.dart';

class IssuePageBloc extends Bloc<IssuePageEvent, IssuePageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;
  late Issue? issue;
  late HashMap<String, int>? hashCodeMap;
  final ImagePicker _imagePicker = ImagePicker();

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  IssuePageBloc({required BuildContext buildContext,
    required MapType mapType,
    this.issue})
      : super(IssuePageState(
      mapType: mapType,
      hasChanges: false,
      pictures: List.empty(growable: true),
      issuePageView: issue == null ? IssuePageView.create : IssuePageView
          .see)) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<IssuePageState> mapEventToState(IssuePageEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.issueButtonEvent) {
        case IssueButtonEvent.selectLocation:
          LatLng? position = await GeneralUtil.showPageAsDialog<LatLng?>(
              _buildContext, SelectLocationPage(mapType: state.mapType!));
          if (position == null) return;
          var newState = await _getLocationInformation(position);
          if (newState == null) return;
          yield newState;
          break;
        case IssueButtonEvent.selectCategory:
          IssuePageState? newState = await _selectCategory();
          if (newState == null) return;
          yield newState;
          break;
        case IssueButtonEvent.selectPicture:
        // Hide keyboard
          GeneralUtil.hideKeyboard();
          // You can only add up to 3 pictures
          if (state.pictures!.length == 3) {
            GeneralUtil.showToast(AppLocalizations.of(_buildContext)!
                .you_cannot_add_more_than_three_pictures);
            return;
          }
          // Get image
          Image? image = await ImagePickerDialog.show(context: _buildContext);
          // Image is null if the user did not take or pick an image
          // e.g. pressed "Cancel"
          if (image == null) return;
          List<Image> pictures = state.pictures!;
          pictures.add(image);
          yield state.copyWith(pictures: pictures);
          break;
        case IssueButtonEvent.saveChanges:
        // ignore: missing_enum_constant_in_switch
          switch (state.issuePageView!) {
            case IssuePageView.create:
              await _createIssue();
              break;
            case IssuePageView.edit:
              List<String> names = state.getNamesOfChangedProperties(
                  hashCodeMap!);
              IssuePageState? newState = await _updateIssue(names);
              if (newState == null) return;
              yield newState;
              break;
          }
          break;
        case IssueButtonEvent.backPressed:
          switch (state.issuePageView!) {
            case IssuePageView.see:
            case IssuePageView.create:
              Navigator.of(_buildContext).pop(state.hasChanges);
              break;
            case IssuePageView.edit:
              List<String> names = state.getNamesOfChangedProperties(
                  hashCodeMap!);
              if (names.isNotEmpty) {
                DialogQuestionResponse questionResponse = await QuestionDialog
                    .show(context: _buildContext,
                    question: AppLocalizations.of(_buildContext)!
                        .do_you_want_to_save_the_changes);
                if (questionResponse == DialogQuestionResponse.yes) {
                  IssuePageState? newState = await _updateIssue(names);
                  if (newState != null) {
                    yield newState;
                  }
                } else {
                  await getValues();
                  return;
                }
              }
              yield state.copyWith(issuePageView: IssuePageView.see);
              break;
          }
          break;
        case IssueButtonEvent.editIssue:
          yield state.copyWith(issuePageView: IssuePageView.edit);
          break;
        case IssueButtonEvent.verifyIssue:
          DialogQuestionResponse questionResponse = await QuestionDialog
              .show(context: _buildContext,
              question: AppLocalizations.of(_buildContext)!
                  .by_verifying);
          if (questionResponse == DialogQuestionResponse.yes) {
            IssuePageState? newState = await _verifyIssue();
            if (newState == null) return;
            yield newState;
          }
          break;
        case IssueButtonEvent.reportIssue:
        // TODO: Handle this case.
          break;
      }
    } else if (event is TextChanged) {
      switch (event.createIssueTextChangedEvent) {
        case IssueTextChangedEvent.description:
          yield state.copyWith(description: event.value);
          break;
      }
    } else if (event is DeletePicture) {
      DialogQuestionResponse response = await QuestionDialog.show(
          context: _buildContext,
          question: AppLocalizations.of(_buildContext)!
              .do_you_want_to_remove_this_picture);
      if (response != DialogQuestionResponse.yes) return;
      List<Image> pictures = state.pictures!;
      pictures.remove(event.picture);
      yield state.copyWith(pictures: pictures);
    } else if (event is PageContentLoaded) {
      IssuePageState newState = state.copyWith(
        marker: event.marker,
        pictures: event.pictures,
        hasVerified: event.hasVerified,
        subCategory: event.subCategory,
        category: event.category,
        description: event.description,
        issueState: event.issueState,
        isCreator: event.isCreator,
        issuePageView: IssuePageView.see,
        address: event.address,);
      hashCodeMap = state.getCurrentHashCodes(state: newState);
      yield newState;
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<String?> _getPictureAsBase64FromNumber(int number) async {
    switch (number) {
      case 1:
        return state.pictures!.isNotEmpty
            ? await _getPictureAsBase64(state.pictures!.first)
            : null;
      case 2:
        return state.pictures!.length > 1
            ? await _getPictureAsBase64(state.pictures![1])
            : null;
      case 3:
        return state.pictures!.length > 2
            ? await _getPictureAsBase64(state.pictures![2])
            : null;
    }
    return null;
  }

  Future<String?> _getPictureAsBase64(Image? image) async {
    if (image == null) return Future.value(null);
    var imageProvider = image.image;
    if (imageProvider is MemoryImage) {
      return base64Encode(imageProvider.bytes);
    } else if (imageProvider is FileImage) {
      var bytes = await imageProvider.file.readAsBytes();
      return base64Encode(bytes);
    }
    return null;
  }

  Future<IssuePageState?> _updateIssue(
      List<String> namesOfChangedProperties) async {
    if (namesOfChangedProperties.isEmpty) return null;

    // Verify issue
    IssuePageState? newState = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.updating_issue,
        doInBackground: (runTask) async {
          List<WASPUpdate> updates = List.empty(growable: true);

          Location? location;
          int? municipalityId;
          String? address;
          String? description;
          String? picture1;
          String? picture2;
          String? picture3;

          if (namesOfChangedProperties.contains("Marker")) {
            // Get municipality ID
            var municipalities = AppValuesHelper.getInstance()
                .getMunicipalities()
                .where((element) =>
            element.name!.toLowerCase() ==
                state.municipalityName!.toLowerCase());
            if (municipalities.isEmpty) return null;
            var municipality = municipalities.first;
            municipalityId = municipality.id;

            location = Location.fromLatLng(state.marker!.position);
            address = state.address!;
            updates.add(WASPUpdate(
                name: "MunicipalityId", value: municipalityId.toString()))
            updates.add(WASPUpdate(
                name: "Location",
                value: jsonEncode(location.toJson())
            ))
            updates.add(WASPUpdate(
                name: "Address",
                value: address
            ))
          }
          if (namesOfChangedProperties.contains("Description")) {
            description = state.description ?? "";
            updates.add(WASPUpdate(
                name: "Description",
                value: description
            ))
          }
          if (namesOfChangedProperties.contains("Picture1")) {
            picture1 = await _getPictureAsBase64FromNumber(1);

            updates.add(WASPUpdate(
                name: "Picture1",
                value: picture1
            ))
          }
          if (namesOfChangedProperties.contains("Picture2")) {
            picture2 = await _getPictureAsBase64FromNumber(2);

            updates.add(WASPUpdate(
                name: "Picture2",
                value: picture2
            ))
          }
          if (namesOfChangedProperties.contains("Picture3")) {
            picture3 = await _getPictureAsBase64FromNumber(3);

            updates.add(WASPUpdate(
                name: "Picture3",
                value: picture3
            ))
          }
          if (namesOfChangedProperties.contains("SubCategory")) {
            updates.add(WASPUpdate(
                name: "SubCategoryId",
                value: state.subCategory!.id.toString()
            ))
          }

          // Send request
          var response = await WASPService.getInstance().updateIssue(
              issueId: issue!.id!,
              updates: updates
          )
          // Check response
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.exception!);
            return null;
          }

          // Update values in the issue
          for (var name in namesOfChangedProperties) {
            switch (name) {
              case "Marker":
                issue!.location = location;
                issue!.address = address;
                issue!.municipality = Municipality(
                    id: municipalityId!, name: state.municipalityName)
                break;
              case "Description":
                issue!.description = description;
                break;
              case "Picture1":
                issue!.picture1 = picture1;
                break;
              case "Picture2":
                issue!.picture2 = picture2;
                break;
              case "Picture3":
                issue!.picture3 = picture3;
                break;
              case "SubCategory":
                issue!.category = state.category;
                issue!.subCategory = state.subCategory;
                break;
            }
          }

          // Return new state
          return state.copyWith(
              hasChanges: true, issuePageView: IssuePageView.see);
        },
        taskCancelled: () {});
    return newState;
  }

  Future<IssuePageState?> _verifyIssue() async {
    int citizenId = AppValuesHelper.getInstance().getInteger(
        AppValuesKey.citizenId)!;

    // Verify issue
    IssuePageState? newState = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.verifying_issue,
        doInBackground: (runTask) async {
          var response = await WASPService.getInstance().verifyIssue(
              issueId: issue!.id!,
              citizenId: citizenId
          )
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.exception!);
            return null;
          }
          issue!.issueVerificationCitizenIds!.add(citizenId);
          return state.copyWith(hasVerified: true);
        },
        taskCancelled: () {});
    return newState;
  }

  Future<void> _createIssue() async {
    // Check for missing inputs
    if (state.marker == null) {
      GeneralUtil.showToast(
          AppLocalizations.of(_buildContext)!.please_select_a_location);
      return;
    }
    if (state.category == null || state.subCategory == null) {
      GeneralUtil.showToast(
          AppLocalizations.of(_buildContext)!.please_select_a_category);
      return;
    }
    if (state.description == null || state.description!.isEmpty) {
      GeneralUtil.showToast(
          AppLocalizations.of(_buildContext)!
              .please_enter_a_description_of_your_problem);
      return;
    }
    // Create issue
    bool? flag = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.creating_issue,
        doInBackground: (runTask) async {
          // Get municipality ID
          var municipalities = AppValuesHelper.getInstance()
              .getMunicipalities()
              .where((element) =>
          element.name!.toLowerCase() == state.municipalityName!.toLowerCase());
          if (municipalities.isEmpty) return false;
          var municipality = municipalities.first;
          var municipalityId = municipality.id;

          String? picture1 = await _getPictureAsBase64FromNumber(1);
          String? picture2 = await _getPictureAsBase64FromNumber(2);
          String? picture3 = await _getPictureAsBase64FromNumber(3);

          var response = await WASPService.getInstance().createIssue(
              citizenId: AppValuesHelper.getInstance().getInteger(
                  AppValuesKey.citizenId)!,
              municipalityId: municipalityId,
              subCategoryId: state.subCategory!.id,
              description: state.description ?? "",
              picture1: picture1,
              picture2: picture2,
              picture3: picture3,
              location: Location.fromLatLng(state.marker!.position))
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.exception!);
            return false;
          }
          return true;
        },
        taskCancelled: () {});
    flag ??= false;
    // If issue was created return true to parent page and pop this page
    if (flag) {
      Navigator.of(_buildContext).pop(true);
    }
  }

  Future<IssuePageState?> _selectCategory() async {
    List<Category> categories = AppValuesHelper.getInstance().getCategories();
    List<dynamic>? selectedItems = await CustomListDialog.show(_buildContext,
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
                  itemSelected(null);
                });
          }
          return Container(
            height: 50,
          );
        }, searchPredicate: (item, searchString) {
          if (item is Category) {
            return item.name!.toLowerCase().contains(searchString);
          } else if (item is SubCategory) {
            return item.name!.toLowerCase().contains(searchString);
          }
          return false;
        }, titleBuilder: (item) {
          if (item == null) {
            return AppLocalizations.of(_buildContext)!.category;
          } else if (item is Category) {
            return AppLocalizations.of(_buildContext)!.subcategory;
          }
          return "";
        });
    if (selectedItems == null) return null;
    Category? selectedCategory = selectedItems
        .firstWhere((element) => element is Category, orElse: () => null);
    SubCategory? selectedSubCategory = selectedItems
        .firstWhere((element) => element is SubCategory, orElse: () => null);

    return state.copyWith(
        category: selectedCategory, subCategory: selectedSubCategory);
  }

  Future<IssuePageState?> _getLocationInformation(LatLng position) async {
    IssuePageState? createIssueState = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.getting_location_information,
        doInBackground: (runTask) async {
          // Create marker
          var marker = Marker(
              markerId: MarkerId(position.toString()),
              position: LatLng(position.latitude, position.longitude),
              consumeTapEvents: true,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed));
          // Get address coordinate information
          GoogleServiceResponse<AddressFromCoordinateResponse> response =
          await GoogleService.getInstance()
              .getAddressFromCoordinate(position);
          // Check for errors
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.errorMessage!);
            return null;
          }
          // Get address
          String? address = response.googleResponse!.getAddress();
          // Get municipality name
          String? municipalityName =
          response.googleResponse!.getMunicipalityName();
          if (address == null || municipalityName == null) return null;
          // Return new state
          return state.copyWith(
              marker: marker,
              municipalityName: municipalityName,
              address: address);
        },
        taskCancelled: () {});
    // Check for errors
    if (createIssueState == null) {
      GeneralUtil.showToast(AppLocalizations.of(_buildContext)!
          .could_not_get_location_information);
      return null;
    }
    // Return new state
    return createIssueState;
  }

  Future<bool> getValues() async {
    if (issue == null) {
      return true;
    }
    // Issue is not null
    return await Future.delayed(
        const Duration(milliseconds: pageTransitionTime), () async {
      Marker? marker;
      bool? isCreator;
      bool hasVerified;
      var pictures = List<Image>.empty(growable: true);

      int? citizenId = AppValuesHelper.getInstance().getInteger(
          AppValuesKey.citizenId);
      // IsCreator flag
      isCreator = citizenId == issue!.citizenId;
      // HasVerified flag
      hasVerified = issue!.issueVerificationCitizenIds!.contains(citizenId);
      // From location create Marker
      if (issue!.location != null) {
        marker = Marker(
            markerId: MarkerId(issue!.id.toString()),
            position:
            LatLng(issue!.location!.latitude, issue!.location!.longitude),
            consumeTapEvents: true,
            icon: WASPUtil.getIssueStateMarkerIcon(issue!.issueState!));
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

      // Fire event
      add(PageContentLoaded(
          marker: marker,
          isCreator: isCreator,
          hasVerified: hasVerified,
          description: issue!.description ?? "",
          pictures: pictures,
          issueState: issue!.issueState,
          category: issue!.category,
          subCategory: issue!.subCategory,
          address: issue!.address ?? ""));

      return true;
    });
  }

//endregion

}

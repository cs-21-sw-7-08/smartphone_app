import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/pages/report/report_page.dart';
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
import 'package:smartphone_app/values/values.dart' as values;

import 'package:smartphone_app/widgets/custom_label.dart';
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
      /// Select location
        case IssueButtonEvent.selectLocation:
          LatLng? position = await GeneralUtil.showPageAsDialog<LatLng?>(
              _buildContext, SelectLocationPage(mapType: state.mapType!));
          if (position == null) return;
          var newState = await _getLocationInformation(position);
          if (newState == null) return;
          yield newState;
          break;

      /// Select category
        case IssueButtonEvent.selectCategory:
          IssuePageState? newState = await _selectCategory();
          if (newState == null) return;
          yield newState;
          break;

      /// Select picture
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

      /// Save changes
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
              if (newState != null) {
                yield newState;
              }
              break;
          }
          break;

      /// Back
        case IssueButtonEvent.back:
          switch (state.issuePageView!) {
          /// See, Create
            case IssuePageView.see:
            case IssuePageView.create:
              Navigator.of(_buildContext).pop(state.hasChanges);
              break;

          /// Edit
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

      /// Edit issue
        case IssueButtonEvent.editIssue:
        // You cannot edit the issue, if the municipality has changed the status
          if (issue!.issueState!.id != 1) {
            GeneralUtil.showToast(AppLocalizations.of(_buildContext)!
                .you_cannot_edit_the_issue);
            return;
          }
          // Go into edit mode
          yield state.copyWith(issuePageView: IssuePageView.edit);
          break;

      /// Verify issue
        case IssueButtonEvent.verifyIssue:
        // Ask user if they want to verify issue
          DialogQuestionResponse questionResponse = await QuestionDialog
              .show(context: _buildContext,
              question: AppLocalizations.of(_buildContext)!
                  .by_verifying);
          // Yes was selected by the user
          if (questionResponse == DialogQuestionResponse.yes) {
            // Verify issue
            IssuePageState? newState = await _verifyIssue();
            if (newState == null) return;
            yield newState;
          }
          break;

      /// Report issue
        case IssueButtonEvent.reportIssue:
          ReportCategory? reportCategory = await GeneralUtil.showPageAsDialog<
              ReportCategory>(_buildContext, ReportPage());
          if (reportCategory == null) return;
          _reportIssue(reportCategory);
          break;

      /// Delete
        case IssueButtonEvent.deleteIssue:
        // You cannot delete the issue, if the municipality has changed the status
          if (issue!.issueState!.id != 1) {
            GeneralUtil.showToast(AppLocalizations.of(_buildContext)!
                .you_cannot_delete_the_issue);
            return;
          }
          // Ask user if they are sure about deleting the issue
          DialogQuestionResponse questionResponse = await QuestionDialog
              .show(context: _buildContext,
              question: AppLocalizations.of(_buildContext)!
                  .are_you_sure_you_want_to_delete_this_issue);
          if (questionResponse != DialogQuestionResponse.yes) return;
          await _deleteIssue();
          break;
      }
    } else if (event is TextChanged) {
      switch (event.createIssueTextChangedEvent) {
      /// Description
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
        dateEdited: event.dateEdited,
        dateCreated: event.dateCreated,
        municipalityResponses: event.municipalityResponses,
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

  DateFormat getDateFormat() {
    return DateFormat("dd-MM-yyyy HH:mm");
  }

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

  Future<void> _reportIssue(ReportCategory reportCategory) async {
    // Report issue
    bool? flag = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.reporting_issue,
        doInBackground: (runTask) async {
          var response = await WASPService.getInstance().reportIssue(
              issueId: issue!.id!,
              reportCategoryId: reportCategory.id
          )
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
            return false;
          }
          return true;
        },
        taskCancelled: () {});
    flag ??= false;
    if (!flag) return;
    // Close dialog
    Navigator.pop(_buildContext);
  }

  Future<IssuePageState?> _updateIssue(
      List<String> namesOfChangedProperties) async {
    if (namesOfChangedProperties.isEmpty) {
      return state.copyWith(issuePageView: IssuePageView.see);
    }

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
            GeneralUtil.showToast((await response.errorMessage)!);
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
          // New date edited
          issue!.dateEdited = DateTime.now();
          var dateFormat = getDateFormat();
          String? dateEdited = dateFormat.format(issue!.dateEdited!);
          // Return new state
          return state.copyWith(
              hasChanges: true,
              issuePageView: IssuePageView.see,
              dateEdited: dateEdited);
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
            GeneralUtil.showToast((await response.errorMessage)!);
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
              issueCreateDTO:
              IssueCreateDTO(
                  citizenId: AppValuesHelper.getInstance().getInteger(
                      AppValuesKey.citizenId)!,
                  municipalityId: municipalityId,
                  subCategoryId: state.subCategory!.id,
                  description: state.description ?? "",
                  picture1: picture1,
                  picture2: picture2,
                  picture3: picture3,
                  location: Location.fromLatLng(state.marker!.position)
              ));
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
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

  Future<void> _deleteIssue() async {
    // Create issue
    bool? flag = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.deleting_issue,
        doInBackground: (runTask) async {
          var response = await WASPService.getInstance().deleteIssue(
              issue!.id!);
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
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
        items: categories,
        itemBuilder: (index, item, list, showSearchBar, itemSelected,
            itemUpdated) {
          if (item is Category) {
            return Container(
                margin: EdgeInsets.only(
                    top: index == 0 && showSearchBar ? 0 : values.padding,
                    left: values.padding,
                    right: values.padding,
                    bottom: index == list.length - 1 ? values.padding : 0),
                child: CustomListTile(
                    widget: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          CustomLabel(
                            title: item.name!,
                            margin: const EdgeInsets.only(
                                left: values.padding,
                                top: values.padding * 2,
                                right: values.padding,
                                bottom: values.padding * 2),
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      itemSelected(item.subCategories);
                    }));
          } else if (item is SubCategory) {
            return Container(
                margin: EdgeInsets.only(
                    top: index == 0 && showSearchBar ? 0 : values.padding,
                    left: values.padding,
                    right: values.padding,
                    bottom: index == list.length - 1 ? values.padding : 0),
                child: CustomListTile(
                    widget: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          CustomLabel(
                            title: item.name!,
                            margin: const EdgeInsets.only(
                                left: values.padding,
                                top: values.padding * 2,
                                right: values.padding,
                                bottom: values.padding * 2),
                          )
                        ],
                      ),
                    ),
                    onPressed: () {
                      itemSelected(null);
                    }));
          }
        },
        searchPredicate: (item, searchString) {
          if (item is Category) {
            return item.name!.toLowerCase().contains(searchString);
          } else if (item is SubCategory) {
            return item.name!.toLowerCase().contains(searchString);
          }
          return false;
        },
        titleBuilder: (item) {
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

      // DateCreated, DateEdited
      var dateFormat = getDateFormat();
      String? dateCreated = dateFormat.format(issue!.dateCreated!);
      String? dateEdited = issue!.dateEdited == null ? null : dateFormat.format(
          issue!.dateEdited!);

      if (issue!.municipalityResponses != null) {
        issue!.municipalityResponses!.sort((a, b) =>
            b.dateCreated!.compareTo(a.dateCreated!));
      }

      // Fire event
      add(PageContentLoaded(
          marker: marker,
          isCreator: isCreator,
          municipalityResponses: issue!.municipalityResponses,
          dateCreated: dateCreated,
          dateEdited: dateEdited,
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

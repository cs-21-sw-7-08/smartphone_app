import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
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

typedef ChangesCallback = Function();

class IssuePageBloc extends Bloc<IssuePageEvent, IssuePageState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  late Issue? issue;
  late HashMap<String, int>? hashCodeMap;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  IssuePageBloc({required this.context,
    required MapType mapType,
    this.issue})
      : super(IssuePageState(
      mapType: mapType,
      hasChanges: false,
      pictures: List.empty(growable: true),
      pageView: issue == null ? IssuePageView.create : IssuePageView
          .see));

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<IssuePageState> mapEventToState(IssuePageEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.buttonEvent) {
      /// Select location
        case IssueButtonEvent.selectLocation:
          await _selectLocation();
          break;

      /// Select category
        case IssueButtonEvent.selectCategory:
          await _selectCategory();
          break;

      /// Select picture
        case IssueButtonEvent.selectPicture:
          await _selectPicture();
          break;

      /// Create issue
        case IssueButtonEvent.createIssue:
          await _createIssue();
          break;

      /// Save changes
        case IssueButtonEvent.saveChanges:
          await _updateIssue();
          break;

      /// Back
        case IssueButtonEvent.back:
          switch (state.pageView!) {
          /// See, Create
            case IssuePageView.see:
            case IssuePageView.create:
              Navigator.of(context).pop(state.hasChanges);
              break;

          /// Edit
            case IssuePageView.edit:
              List<String> names = state.getNamesOfChangedProperties(
                  hashCodeMap!);
              if (names.isNotEmpty) {
                DialogQuestionResponse questionResponse = await QuestionDialog
                    .show(context: context,
                    question: AppLocalizations.of(context)!
                        .do_you_want_to_save_the_changes);
                if (questionResponse == DialogQuestionResponse.yes) {
                  await _updateIssue(names: names);
                } else {
                  await getValues();
                  return;
                }
              } else {
                yield state.copyWith(pageView: IssuePageView.see);
              }
              break;
          }
          break;

      /// Edit issue
        case IssueButtonEvent.editIssue:
        // You cannot edit the issue, if the municipality has changed the status
          if (issue!.issueState!.id != 1) {
            GeneralUtil.showToast(AppLocalizations.of(context)!
                .you_cannot_edit_the_issue);
            return;
          }
          // Go into edit mode
          yield state.copyWith(pageView: IssuePageView.edit);
          break;

      /// Verify issue
        case IssueButtonEvent.verifyIssue:
        // You cannot verify the issue, if the municipality has changed the
        // status to "Resolved" or "Not resolved"
          if (issue!.issueState!.id != 1 && issue!.issueState!.id != 2) {
            GeneralUtil.showToast(AppLocalizations.of(context)!
                .you_cannot_verify_the_issue);
            return;
          }
          // Ask user if they want to verify issue
          DialogQuestionResponse questionResponse = await QuestionDialog
              .show(context: context,
              question: AppLocalizations.of(context)!
                  .by_verifying);
          // Yes was selected by the user
          if (questionResponse == DialogQuestionResponse.yes) {
            // Verify issue
            await _verifyIssue();
          }
          break;

      /// Report issue
        case IssueButtonEvent.reportIssue:
          await _reportIssue();
          break;

      /// Delete issue
        case IssueButtonEvent.deleteIssue:
        // You cannot delete the issue, if the municipality has changed the status
          if (issue!.issueState!.id != 1) {
            GeneralUtil.showToast(AppLocalizations.of(context)!
                .you_cannot_delete_the_issue);
            return;
          }
          // Ask user if they are sure about deleting the issue
          DialogQuestionResponse questionResponse = await QuestionDialog
              .show(context: context,
              question: AppLocalizations.of(context)!
                  .are_you_sure_you_want_to_delete_this_issue);
          if (questionResponse != DialogQuestionResponse.yes) return;
          await _deleteIssue();
          break;
      }
    } else if (event is TextChanged) {
      switch (event.textChangedEvent) {
      /// Description
        case IssueTextChangedEvent.description:
          yield state.copyWith(description: event.text);
          break;
      }
    } else if (event is DeletePicture) {
      DialogQuestionResponse response = await QuestionDialog.show(
          context: context,
          question: AppLocalizations.of(context)!
              .do_you_want_to_remove_this_picture);
      if (response != DialogQuestionResponse.yes) return;
      List<Image> pictures = state.pictures!;
      pictures.remove(event.picture);
      yield state.update(updatedItemHashCode: hashList(pictures));
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
        pageView: IssuePageView.see,
        address: event.address,);
      hashCodeMap = state.getCurrentHashCodes(state: newState);
      yield newState;
    } else if (event is LocationInformationRetrieved) {
      yield state.copyWith(marker: event.marker,
          address: event.address,
          municipalityName: event.municipalityName);
    } else if (event is CategorySelected) {
      yield state.copyWith(
          category: event.category, subCategory: event.subCategory);
    } else if (event is PictureSelected) {
      List<Image> pictures = state.pictures!;
      pictures.add(event.image);
      yield state.update(updatedItemHashCode: hashList(pictures));
    } else if (event is IssueUpdated) {
      yield state.copyWith(pageView: IssuePageView.see,
          hasChanges: event.hasChanges,
          dateEdited: event.dateEdited);
    } else if (event is IssueVerified) {
      yield state.copyWith(hasVerified: true);
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

  Future<void> _reportIssue() async {
    ReportCategory? reportCategory = await GeneralUtil.showPageAsDialog<
        ReportCategory>(context, ReportPage());
    if (reportCategory == null) return;

    // Report issue
    bool? flag = await TaskUtil.runTask(
        buildContext: context,
        progressMessage:
        AppLocalizations.of(context)!.reporting_issue,
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
    Navigator.pop(context);
  }

  Future<void> _updateIssue({List<String>? names}) async {
    names ??= state.getNamesOfChangedProperties(
        hashCodeMap!);
    if (names.isEmpty) {
      add(const IssueUpdated(dateEdited: null, hasChanges: null));
      return;
    }

    // Verify issue
    await TaskUtil.runTask(
        buildContext: context,
        progressMessage:
        AppLocalizations.of(context)!.updating_issue,
        doInBackground: (runTask) async {
          List<WASPUpdate> updates = List.empty(growable: true);

          Location? location;
          int? municipalityId;
          String? address;
          String? description;
          String? picture1;
          String? picture2;
          String? picture3;

          if (names!.contains("Marker")) {
            // Get municipality ID
            var municipalities = AppValuesHelper.getInstance()
                .getMunicipalities()
                .where((element) =>
            element.name!.toLowerCase() ==
                state.municipalityName!.toLowerCase());
            if (municipalities.isEmpty) return;
            var municipality = municipalities.first;
            municipalityId = municipality.id;

            location = Location.fromLatLng(state.marker!.position);
            address = state.address!;
            updates.add(WASPUpdate(
                name: "MunicipalityId", value: municipalityId.toString()));
            updates.add(WASPUpdate(
                name: "Location",
                value: jsonEncode(location.toJson())
            ));
            updates.add(WASPUpdate(
                name: "Address",
                value: address
            ));
          }
          if (names.contains("Description")) {
            description = state.description ?? "";
            updates.add(WASPUpdate(
                name: "Description",
                value: description
            ));
          }
          if (names.contains("Picture1")) {
            picture1 = await _getPictureAsBase64FromNumber(1);

            updates.add(WASPUpdate(
                name: "Picture1",
                value: picture1
            ));
          }
          if (names.contains("Picture2")) {
            picture2 = await _getPictureAsBase64FromNumber(2);

            updates.add(WASPUpdate(
                name: "Picture2",
                value: picture2
            ));
          }
          if (names.contains("Picture3")) {
            picture3 = await _getPictureAsBase64FromNumber(3);

            updates.add(WASPUpdate(
                name: "Picture3",
                value: picture3
            ));
          }
          if (names.contains("SubCategory")) {
            updates.add(WASPUpdate(
                name: "SubCategoryId",
                value: state.subCategory!.id.toString()
            ));
          }

          // Send request
          var response = await WASPService.getInstance().updateIssue(
              issueId: issue!.id!,
              updates: updates
          );
          // Check response
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
            return;
          }

          // Update values in the issue
          for (var name in names) {
            switch (name) {
              case "Marker":
                issue!.location = location;
                issue!.address = address;
                issue!.municipality = Municipality(
                    id: municipalityId!, name: state.municipalityName);
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
          // Fire event
          add(IssueUpdated(hasChanges: true, dateEdited: dateEdited));
        },
        taskCancelled: () {});
  }

  Future<void> _verifyIssue() async {
    int citizenId = AppValuesHelper.getInstance().getInteger(
        AppValuesKey.citizenId)!;

    // Verify issue
    await TaskUtil.runTask(
        buildContext: context,
        progressMessage:
        AppLocalizations.of(context)!.verifying_issue,
        doInBackground: (runTask) async {
          var response = await WASPService.getInstance().verifyIssue(
              issueId: issue!.id!,
              citizenId: citizenId
          );
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
            return;
          }
          issue!.issueVerificationCitizenIds!.add(citizenId);
          // Fire event
          add(const IssueVerified());
        },
        taskCancelled: () {});
  }

  Future<void> _createIssue() async {
    // Check for missing inputs
    if (state.marker == null) {
      GeneralUtil.showToast(
          AppLocalizations.of(context)!.please_select_a_location);
      return;
    }
    if (state.category == null || state.subCategory == null) {
      GeneralUtil.showToast(
          AppLocalizations.of(context)!.please_select_a_category);
      return;
    }
    if (state.description == null || state.description!.isEmpty) {
      GeneralUtil.showToast(
          AppLocalizations.of(context)!
              .please_enter_a_description_of_your_problem);
      return;
    }
    // Create issue
    bool? flag = await TaskUtil.runTask(
        buildContext: context,
        progressMessage:
        AppLocalizations.of(context)!.creating_issue,
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
                  address: state.address,
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
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteIssue() async {
    // Create issue
    bool? flag = await TaskUtil.runTask(
        buildContext: context,
        progressMessage:
        AppLocalizations.of(context)!.deleting_issue,
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
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _selectCategory() async {
    List<Category> categories = AppValuesHelper.getInstance().getCategories();
    List<dynamic>? selectedItems = await CustomListDialog.show(context,
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
                            title: LocalizationHelper.getInstance()
                                .getLocalizedCategory(context, item),
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
                            title: LocalizationHelper.getInstance()
                                .getLocalizedSubCategory(context, item),
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
            return AppLocalizations.of(context)!.category;
          } else if (item is Category) {
            return AppLocalizations.of(context)!.subcategory;
          }
          return "";
        });
    if (selectedItems == null) return;
    // Get selected category
    Category? selectedCategory = selectedItems
        .firstWhere((element) => element is Category, orElse: () => null);
    // Get selected subcategory
    SubCategory? selectedSubCategory = selectedItems
        .firstWhere((element) => element is SubCategory, orElse: () => null);

    // Fire event
    add(CategorySelected(
        category: selectedCategory!, subCategory: selectedSubCategory!));
  }

  Future<void> _selectLocation() async {
    LatLng? position = await GeneralUtil.showPageAsDialog<LatLng?>(
        context, SelectLocationPage(mapType: state.mapType!));
    if (position == null) return;
    await _getLocationInformation(position);
  }

  Future<void> _getLocationInformation(LatLng position) async {
    LocationInformationRetrieved? locationInformationRetrieved = await TaskUtil
        .runTask(
        buildContext: context,
        progressMessage:
        AppLocalizations.of(context)!.getting_location_information,
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
          // Return event
          return LocationInformationRetrieved(
              marker: marker,
              municipalityName: municipalityName,
              address: address);
        },
        taskCancelled: () {});
    // Check for errors
    if (locationInformationRetrieved == null) {
      GeneralUtil.showToast(AppLocalizations.of(context)!
          .could_not_get_location_information);
      return;
    }
    // Fire event
    add(locationInformationRetrieved);
  }

  Future<void> _selectPicture() async {
    // Hide keyboard
    GeneralUtil.hideKeyboard();
    // You can only add up to 3 pictures
    if (state.pictures!.length == 3) {
      GeneralUtil.showToast(AppLocalizations.of(context)!
          .you_cannot_add_more_than_three_pictures);
      return;
    }
    // Get image
    Image? image = await ImagePickerDialog.show(context: context);
    // Image is null if the user did not take or pick an image
    // e.g. pressed "Cancel"
    if (image == null) return;
    // Fire event
    add(PictureSelected(image: image));
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

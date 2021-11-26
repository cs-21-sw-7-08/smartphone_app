import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/pages/settings/settings_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';
import 'package:darq/darq.dart';
import 'package:smartphone_app/widgets/question_dialog.dart';

enum SettingsCallBackType { deleteAccount, settingsChanged }

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;
  late HashMap<String, int>? hashCodeMap;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  SettingsBloc({required BuildContext buildContext})
      : super(SettingsState()) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.settingsButtonEvent) {
        case SettingsButtonEvent.back:
          List<String> names = state.getNamesOfChangedProperties(
              hashCodeMap!);
          if (names.isNotEmpty) {
            DialogQuestionResponse questionResponse = await QuestionDialog
                .show(context: _buildContext,
                question: AppLocalizations.of(_buildContext)!
                    .do_you_want_to_save_the_changes);
            if (questionResponse == DialogQuestionResponse.yes) {
              await _saveChanges();
            } else {
              Navigator.of(_buildContext).pop(null);
            }
          } else {
            Navigator.of(_buildContext).pop(null);
          }
          break;
        case SettingsButtonEvent.save:
          await _saveChanges();
          break;
        case SettingsButtonEvent.deleteAccount:
          await _deleteAccount();
          break;
        case SettingsButtonEvent.selectMunicipality:
          SettingsState? newState = await _selectMunicipality();
          if (newState == null) return;
          yield newState;
          break;
      }
    } else if (event is ValuesRetrieved) {
      SettingsState newState = state.copyWith(
          name: event.name, municipality: event.municipality);
      hashCodeMap = state.getCurrentHashCodes(state: newState);
      yield newState;
    } else if (event is TextChanged) {
      switch (event.settingsTextChangedEvent) {
        case SettingsTextChangedEvent.name:
          yield state.copyWith(name: event.text);
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<void> _saveChanges() async {
    List<String> namesOfChangedProperties = state.getNamesOfChangedProperties(
        hashCodeMap!);
    if (namesOfChangedProperties.isEmpty) {
      Navigator.of(_buildContext).pop(null);
    }

    // Check for valid name
    if (state.name == null || state.name!.isEmpty) {
      GeneralUtil.showToast(AppLocalizations.of(_buildContext)!
          .please_enter_your_full_name_toast);
      return;
    }

    // Save changes
    bool? flag = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.saving_changes,
        doInBackground: (runTask) async {
          List<WASPUpdate> waspUpdates = List.empty(growable: true);

          if (namesOfChangedProperties.contains("Name")) {
            waspUpdates.add(WASPUpdate(name: "Name", value: state.name));
          }
          if (namesOfChangedProperties.contains("Municipality")) {
            waspUpdates.add(WASPUpdate(name: "MunicipalityId",
                value: state.municipality!.id.toString()));
          }

          var response = await WASPService.getInstance().updateCitizen(
              citizenId: AppValuesHelper.getInstance().getInteger(
                  AppValuesKey.citizenId)!,
              updates: waspUpdates
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
    // Save default municipality ID
    await AppValuesHelper.getInstance().saveInteger(
        AppValuesKey.defaultMunicipalityId, state.municipality!.id);
    // Close dialog
    Navigator.of(_buildContext).pop(SettingsCallBackType.settingsChanged);
  }

  Future<void> _deleteAccount() async {
    DialogQuestionResponse questionResponse = await QuestionDialog.show(
        context: _buildContext,
        question: AppLocalizations.of(_buildContext)!
            .are_you_sure_you_want_to_delete_your_account);
    if (questionResponse != DialogQuestionResponse.yes) return;

    // Delete account
    bool? flag = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
        AppLocalizations.of(_buildContext)!.deleting_account,
        doInBackground: (runTask) async {
          var response = await WASPService.getInstance().deleteCitizen(
              citizenId: AppValuesHelper.getInstance().getInteger(
                  AppValuesKey.citizenId)!
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
    Navigator.of(_buildContext).pop(SettingsCallBackType.deleteAccount);
  }

  Future<SettingsState?> _selectMunicipality() async {
    List<Municipality> municipalities =
    AppValuesHelper.getInstance().getMunicipalities();
    List<dynamic>? selectedItems = await CustomListDialog.show(_buildContext,
        items: municipalities, itemBuilder:
            (index, item, list, showSearchBar, itemSelected, itemUpdated) {
          if (item is Municipality) {
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
        }, searchPredicate: (item, searchString) {
          if (item is Municipality) {
            return item.name!.toLowerCase().contains(searchString);
          }
          return false;
        }, titleBuilder: (item) {
          if (item == null) {
            return AppLocalizations.of(_buildContext)!.municipality;
          }
          return "";
        });
    if (selectedItems == null) return null;
    Municipality? selectedMunicipality = selectedItems
        .firstWhere((element) => element is Municipality, orElse: () => null);
    if (selectedMunicipality == null) return null;
    return state.copyWith(
        municipality: selectedMunicipality);
  }

  Future<bool> getValues() async {
    return await Future.delayed(
        const Duration(milliseconds: values.pageTransitionTime), () async {
      var flag = await TaskUtil.runTask(
          buildContext: _buildContext,
          progressMessage:
          AppLocalizations.of(_buildContext)!.getting_information,
          doInBackground: (runTask) async {
            // Get citizen
            WASPServiceResponse<Citizen_WASPResponse>
            getListOfMunicipalitiesResponse =
            await WASPService.getInstance().getCitizen(
                citizenId: AppValuesHelper.getInstance()
                    .getInteger(AppValuesKey.citizenId)!);
            if (!getListOfMunicipalitiesResponse.isSuccess) {
              GeneralUtil.showToast(
                  (await getListOfMunicipalitiesResponse.errorMessage)!);
              return false;
            }

            // Get citizen
            Citizen citizen =
            getListOfMunicipalitiesResponse.waspResponse!.result!;
            // Get list of municipalities with ID that matches the one selected
            // by the citizen
            List<Municipality?> municipalities = AppValuesHelper.getInstance()
                .getMunicipalities()
                .where((element) => element.id == citizen.municipality!.id)
                .toList();
            // Get the first municipality in the list
            Municipality? municipality =
            municipalities.firstOrDefault(defaultValue: null);
            // Fire event
            add(ValuesRetrieved(
                name: citizen.name, municipality: municipality));

            // Return true
            return true;
          },
          taskCancelled: () {});
      flag ??= false;
      return flag;
    });
  }

//endregion

}

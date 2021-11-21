import 'dart:collection';

import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum SettingsButtonEvent { back, save, deleteAccount, selectMunicipality }
enum SettingsTextChangedEvent { name }

//endregion

///
/// EVENT
///
//region Event

class SettingsEvent {}

class ButtonPressed extends SettingsEvent {
  final SettingsButtonEvent settingsButtonEvent;

  ButtonPressed({required this.settingsButtonEvent});
}

class TextChanged extends SettingsEvent {
  final SettingsTextChangedEvent settingsTextChangedEvent;
  final String? text;

  TextChanged({required this.settingsTextChangedEvent, required this.text});
}

class ValuesRetrieved extends SettingsEvent {
  final String? name;
  final Municipality? municipality;

  ValuesRetrieved({required this.name, required this.municipality});
}

//endregion

///
/// STATE
///
//region State

class SettingsState {
  String? name;
  Municipality? municipality;

  SettingsState({this.name, this.municipality});

  SettingsState copyWith({String? name, Municipality? municipality}) {
    return SettingsState(
        name: name ?? this.name,
        municipality: municipality ?? this.municipality);
  }

  List<String> getNamesOfChangedProperties(
      HashMap<String, int> savedHashCodes) {
    List<String> names = List.empty(growable: true);
    HashMap<String, int> currentHashCodeMap = getCurrentHashCodes();
    for (var pair in currentHashCodeMap.entries) {
      int? savedHashCode = savedHashCodes[pair.key];
      if (savedHashCode == null) continue;
      if (pair.value != savedHashCode) names.add(pair.key);
    }
    return names;
  }

  HashMap<String, int> getCurrentHashCodes({SettingsState? state}) {
    state ??= this;
    HashMap<String, int> hashMap = HashMap();
    hashMap["Name"] = state.name == null ? 0 : state.name.hashCode;
    hashMap["Municipality"] =
        state.municipality == null ? 0 : state.municipality.hashCode;
    return hashMap;
  }
}

//endregion

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum IssueButtonEvent {
  selectLocation,
  selectCategory,
  selectPicture,
  saveChanges,
  backPressed,
  editIssue,
  verifyIssue,
  reportIssue
}
enum IssueTextChangedEvent { description }
enum IssuePageView { create, edit, see }

//endregion

///
/// EVENT
///
//region Event

class IssuePageEvent {}

class ButtonPressed extends IssuePageEvent {
  final IssueButtonEvent issueButtonEvent;

  ButtonPressed({required this.issueButtonEvent});
}

class DeletePicture extends IssuePageEvent {
  final Image picture;

  DeletePicture({required this.picture});
}

class TextChanged extends IssuePageEvent {
  final IssueTextChangedEvent createIssueTextChangedEvent;
  final String? value;

  TextChanged({required this.createIssueTextChangedEvent, required this.value});
}

class LocationSelected extends IssuePageEvent {
  final LatLng position;

  LocationSelected({required this.position});
}

class CategorySelected extends IssuePageEvent {
  final Category category;
  final SubCategory subCategory;

  CategorySelected({required this.category, required this.subCategory});
}

class PageContentLoaded extends IssuePageEvent {
  final Marker? marker;
  final String? address;
  final String? description;
  final List<Image> pictures;
  final Category? category;
  final SubCategory? subCategory;
  final bool? isCreator;
  final bool? hasVerified;
  final IssueState? issueState;

  PageContentLoaded(
      {required this.marker,
      required this.issueState,
      required this.address,
      required this.hasVerified,
      required this.isCreator,
      required this.description,
      required this.pictures,
      required this.category,
      required this.subCategory});
}

//endregion

///
/// STATE
///
//region State

class IssuePageState {
  bool? isCreator;
  bool? hasVerified;
  MapType? mapType;
  Marker? marker;
  String? address;
  String? municipalityName;
  String? description;
  List<Image>? pictures;
  Category? category;
  SubCategory? subCategory;
  IssuePageView? issuePageView;
  IssueState? issueState;
  bool? hasChanges;

  IssuePageState(
      {this.marker,
      this.isCreator,
      this.mapType,
      this.address,
      this.issueState,
      this.hasVerified,
      this.description,
      this.pictures,
      this.issuePageView,
      this.category,
      this.hasChanges,
      this.municipalityName,
      this.subCategory});

  IssuePageState copyWith(
      {Marker? marker,
      MapType? mapType,
      bool? isCreator,
      String? address,
      bool? hasVerified,
      IssueState? issueState,
      String? description,
      String? municipalityName,
      IssuePageView? issuePageView,
      List<Image>? pictures,
      Category? category,
      bool? hasChanges,
      SubCategory? subCategory}) {
    return IssuePageState(
        marker: marker ?? this.marker,
        isCreator: isCreator ?? this.isCreator,
        mapType: mapType ?? this.mapType,
        address: address ?? this.address,
        hasVerified: hasVerified ?? this.hasVerified,
        hasChanges: hasChanges ?? this.hasChanges,
        issueState: issueState ?? this.issueState,
        municipalityName: municipalityName ?? this.municipalityName,
        issuePageView: issuePageView ?? this.issuePageView,
        description: description ?? this.description,
        pictures: pictures ?? this.pictures,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory);
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

  HashMap<String, int> getCurrentHashCodes({IssuePageState? state}) {
    state ??= this;
    HashMap<String, int> hashMap = HashMap();
    hashMap["Marker"] = state.marker == null ? 0 : state.marker.hashCode;
    hashMap["Description"] =
        state.description == null ? 0 : state.description.hashCode;
    hashMap["Picture1"] = (pictures == null || state.pictures!.isEmpty)
        ? 0
        : state.pictures![0].hashCode;
    hashMap["Picture2"] = (pictures == null || state.pictures!.length < 2)
        ? 0
        : state.pictures![1].hashCode;
    hashMap["Picture3"] = (pictures == null || state.pictures!.length < 3)
        ? 0
        : state.pictures![2].hashCode;
    hashMap["SubCategory"] =
        state.subCategory == null ? 0 : state.subCategory.hashCode;
    return hashMap;
  }
}

//endregion

import 'dart:collection';

import 'package:equatable/equatable.dart';
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
  createIssue,
  back,
  editIssue,
  verifyIssue,
  reportIssue,
  deleteIssue
}
enum IssueTextChangedEvent { description }
enum IssuePageView { create, edit, see }
enum IssuePageValueSelectedEvent { picture }

//endregion

///
/// EVENT
///
//region Event

abstract class IssuePageEvent extends Equatable {
  const IssuePageEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends IssuePageEvent {
  final IssueButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class DeletePicture extends IssuePageEvent {
  final Image picture;

  const DeletePicture({required this.picture});

  @override
  List<Object?> get props => [picture];
}

class TextChanged extends IssuePageEvent {
  final IssueTextChangedEvent textChangedEvent;
  final String? text;

  const TextChanged({required this.textChangedEvent, required this.text});

  @override
  List<Object?> get props => [textChangedEvent, text];
}

class CategorySelected extends IssuePageEvent {
  final Category category;
  final SubCategory subCategory;

  const CategorySelected({required this.category, required this.subCategory});

  @override
  List<Object?> get props => [category, subCategory];
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
  final String? dateCreated;
  final String? dateEdited;
  final List<MunicipalityResponse>? municipalityResponses;

  const PageContentLoaded({required this.marker,
    required this.issueState,
    required this.municipalityResponses,
    required this.address,
    required this.dateCreated,
    required this.dateEdited,
    required this.hasVerified,
    required this.isCreator,
    required this.description,
    required this.pictures,
    required this.category,
    required this.subCategory});

  @override
  List<Object?> get props =>
      [
        marker,
        address,
        description,
        pictures,
        category,
        subCategory,
        isCreator,
        hasVerified,
        issueState,
        dateCreated,
        dateEdited,
        municipalityResponses
      ];
}

class LocationInformationRetrieved extends IssuePageEvent {
  final Marker marker;
  final String address;
  final String municipalityName;

  const LocationInformationRetrieved(
      {required this.marker, required this.address, required this.municipalityName});

  @override
  List<Object?> get props => [marker, address, municipalityName];
}

class PictureSelected extends IssuePageEvent {
  final Image image;

  const PictureSelected({required this.image});

  @override
  List<Object?> get props => [image];
}

class IssueUpdated extends IssuePageEvent {
  final bool? hasChanges;
  final String? dateEdited;

  const IssueUpdated(
      {required this.hasChanges, required this.dateEdited});

  @override
  List<Object?> get props => [hasChanges, dateEdited];
}

class IssueVerified extends IssuePageEvent {
  const IssueVerified();
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class IssuePageState extends Equatable {
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
  IssuePageView? pageView;
  IssueState? issueState;
  bool? hasChanges;
  String? dateCreated;
  String? dateEdited;
  List<MunicipalityResponse>? municipalityResponses;

  int? updatedItemHashCode;

  IssuePageState({this.marker,
    this.isCreator,
    this.mapType,
    this.address,
    this.issueState,
    this.hasVerified,
    this.description,
    this.dateCreated,
    this.dateEdited,
    this.pictures,
    this.updatedItemHashCode,
    this.municipalityResponses,
    this.pageView,
    this.category,
    this.hasChanges,
    this.municipalityName,
    this.subCategory});

  IssuePageState copyWith({Marker? marker,
    MapType? mapType,
    bool? isCreator,
    String? address,
    bool? hasVerified,
    IssueState? issueState,
    List<MunicipalityResponse>? municipalityResponses,
    String? dateCreated,
    String? dateEdited,
    String? description,
    String? municipalityName,
    IssuePageView? pageView,
    int? updatedItemHashCode,
    List<Image>? pictures,
    Category? category,
    bool? hasChanges,
    SubCategory? subCategory}) {
    return IssuePageState(
        marker: marker ?? this.marker,
        isCreator: isCreator ?? this.isCreator,
        mapType: mapType ?? this.mapType,
        municipalityResponses:
        municipalityResponses ?? this.municipalityResponses,
        address: address ?? this.address,
        dateCreated: dateCreated ?? this.dateCreated,
        dateEdited: dateEdited ?? this.dateEdited,
        hasVerified: hasVerified ?? this.hasVerified,
        hasChanges: hasChanges ?? this.hasChanges,
        issueState: issueState ?? this.issueState,
        municipalityName: municipalityName ?? this.municipalityName,
        pageView: pageView ?? this.pageView,
        description: description ?? this.description,
        pictures: pictures ?? this.pictures,
        updatedItemHashCode: updatedItemHashCode ?? this.updatedItemHashCode,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory);
  }

  IssuePageState update({required int updatedItemHashCode}) {
    return copyWith(updatedItemHashCode: updatedItemHashCode);
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
    hashMap["Marker"] = state.marker.hashCode;
    hashMap["Description"] = state.description.hashCode;
    hashMap["Picture1"] = (pictures == null || state.pictures!.isEmpty)
        ? 0
        : state.pictures![0].hashCode;
    hashMap["Picture2"] = (pictures == null || state.pictures!.length < 2)
        ? 0
        : state.pictures![1].hashCode;
    hashMap["Picture3"] = (pictures == null || state.pictures!.length < 3)
        ? 0
        : state.pictures![2].hashCode;
    hashMap["SubCategory"] = state.subCategory.hashCode;
    return hashMap;
  }

  @override
  List<Object?> get props =>
      [
        marker,
        isCreator,
        mapType,
        municipalityResponses,
        address,
        dateCreated,
        dateEdited,
        hasVerified,
        hasChanges,
        issueState,
        municipalityName,
        pageView,
        description,
        pictures,
        category,
        subCategory,
        updatedItemHashCode
      ];
}

//endregion

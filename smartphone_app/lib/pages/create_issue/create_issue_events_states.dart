import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum CreateIssueButtonEvent {
  selectLocation,
  selectCategory,
  selectPicture,
  saveChanges
}
enum CreateIssueTextChangedEvent { description }
enum CreateIssuePageView { create, edit }

//endregion

///
/// EVENT
///
//region Event

class CreateIssueEvent {}

class ButtonPressed extends CreateIssueEvent {
  final CreateIssueButtonEvent createIssueButtonEvent;

  ButtonPressed({required this.createIssueButtonEvent});
}

class TextChanged extends CreateIssueEvent {
  final CreateIssueTextChangedEvent createIssueTextChangedEvent;
  final String? value;

  TextChanged({required this.createIssueTextChangedEvent, required this.value});
}

class LocationSelected extends CreateIssueEvent {
  final LatLng position;

  LocationSelected({required this.position});
}

class CategorySelected extends CreateIssueEvent {
  final Category category;
  final SubCategory subCategory;

  CategorySelected({required this.category, required this.subCategory});
}

class PageContentLoaded extends CreateIssueEvent {
  final Marker? marker;
  final String? address;
  final String? description;
  final List<Image> pictures;
  final Category? category;
  final SubCategory? subCategory;

  PageContentLoaded(
      {required this.marker,
      required this.address,
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

class CreateIssueState {
  MapType? mapType;
  Marker? marker;
  String? address;
  String? municipalityName;
  String? description;
  List<Image>? pictures;
  Category? category;
  SubCategory? subCategory;
  CreateIssuePageView? createIssuePageView;

  CreateIssueState(
      {this.marker,
      this.mapType,
      this.address,
      this.description,
      this.pictures,
      this.createIssuePageView,
      this.category,
      this.municipalityName,
      this.subCategory});

  CreateIssueState copyWith(
      {Marker? marker,
      MapType? mapType,
      String? address,
      String? description,
      String? municipalityName,
      CreateIssuePageView? createIssuePageView,
      List<Image>? pictures,
      Category? category,
      SubCategory? subCategory}) {
    return CreateIssueState(
        marker: marker ?? this.marker,
        mapType: mapType ?? this.mapType,
        address: address ?? this.address,
        municipalityName: municipalityName ?? this.municipalityName,
        createIssuePageView: createIssuePageView ?? this.createIssuePageView,
        description: description ?? this.description,
        pictures: pictures ?? this.pictures,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory);
  }
}

//endregion

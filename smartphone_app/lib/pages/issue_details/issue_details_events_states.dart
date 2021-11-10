import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum IssueDetailsButtonEvent { verifyIssue, editIssue }

//endregion

///
/// EVENT
///
//region Event

class IssueDetailsEvent {}

class ButtonPressed extends IssueDetailsEvent {
  final IssueDetailsButtonEvent issueDetailsButtonEvent;

  ButtonPressed({required this.issueDetailsButtonEvent});
}

class PageContentLoaded extends IssueDetailsEvent {
  final bool isCreator;
  final Marker? marker;
  final String? description;
  final List<Image> pictures;
  final String category;
  final String subCategory;

  PageContentLoaded(
      {required this.isCreator,
      required this.marker,
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

class IssueDetailsState {
  MapType? mapType;
  bool? isCreator;
  Marker? marker;
  String? description;
  List<Image>? pictures;
  String? category;
  String? subCategory;

  IssueDetailsState(
      {this.isCreator,
      this.marker,
      this.mapType,
      this.description,
      this.pictures,
      this.category,
      this.subCategory});

  IssueDetailsState copyWith(
      {bool? isCreator,
      Marker? marker,
      MapType? mapType,
      String? description,
      List<Image>? pictures,
      String? category,
      String? subCategory}) {
    return IssueDetailsState(
        isCreator: isCreator ?? this.isCreator,
        marker: marker ?? this.marker,
        mapType: mapType ?? this.mapType,
        description: description ?? this.description,
        pictures: pictures ?? this.pictures,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory);
  }
}

//endregion
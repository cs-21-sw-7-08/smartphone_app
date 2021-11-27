import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:smartphone_app/utilities/general_util.dart';

///
/// ENUMS
///
//region Enums

enum LoginButtonEvent {
  usePhoneNo,
  useGoogleLogin,
  useAppleLogin,
  goToSettings
}

//endregion

///
/// EVENT
///
//region Event

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class ButtonPressed extends LoginEvent {
  final LoginButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object> get props => [buttonEvent];
}

class Resumed extends LoginEvent {}

class PermissionStateChanged extends LoginEvent {
  final PermissionState permissionState;

  const PermissionStateChanged({required this.permissionState});

  @override
  List<Object> get props => [permissionState];
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class LoginState extends Equatable {
  PermissionState? permissionState;

  LoginState({this.permissionState});

  LoginState copyWith({PermissionState? permissionState}) {
    return LoginState(permissionState: permissionState ?? this.permissionState);
  }

  @override
  List<Object?> get props => [permissionState];
}

//endregion

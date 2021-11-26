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

abstract class LoginEvent {}

class ButtonPressed extends LoginEvent {
  final LoginButtonEvent loginButtonEvent;

  ButtonPressed({required this.loginButtonEvent});
}

class Resumed extends LoginEvent {}

class PermissionStateChanged extends LoginEvent {
  final PermissionState permissionState;

  PermissionStateChanged({required this.permissionState});
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

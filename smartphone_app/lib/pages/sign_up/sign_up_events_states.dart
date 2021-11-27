import 'package:equatable/equatable.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum SignUpPageView { phoneNo, name, smsCode }
enum SignUpButtonEvent {
  verifyPhoneNo,
  verifySmsCode,
  confirmName,
  back,
  selectMunicipality
}
enum SignUpTextChangedEvent { name, phoneNo, smsCode }
enum SignUpViewChangeEvent { name, phoneNo, smsCode }

//endregion

///
/// EVENT
///
//region Event

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends SignUpEvent {
  final SignUpButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class TextChanged extends SignUpEvent {
  final SignUpTextChangedEvent textChangedEvent;
  final String? text;

  const TextChanged({required this.textChangedEvent, required this.text});

  @override
  List<Object?> get props => [textChangedEvent, text];
}

class MakeViewChange extends SignUpEvent {
  final SignUpPageView pageView;

  const MakeViewChange({required this.pageView});

  @override
  List<Object?> get props => [pageView];
}

class VerificationIdRetrieved extends SignUpEvent {
  final String verificationId;

  const VerificationIdRetrieved({required this.verificationId});

  @override
  List<Object?> get props => [verificationId];
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class SignUpState extends Equatable {
  SignUpPageView? signUpPageView;
  String? name;
  String? phoneNo;
  String? smsCode;
  String? verificationId;
  Municipality? municipality;

  SignUpState(
      {this.name,
      this.smsCode,
      this.municipality,
      this.verificationId,
      this.phoneNo,
      this.signUpPageView});

  SignUpState copyWith(
      {String? name,
      String? phoneNo,
      String? smsCode,
      Municipality? municipality,
      String? verificationId,
      SignUpPageView? signUpPageView}) {
    return SignUpState(
        name: name ?? this.name,
        phoneNo: phoneNo ?? this.phoneNo,
        smsCode: smsCode ?? this.smsCode,
        municipality: municipality ?? this.municipality,
        verificationId: verificationId ?? this.verificationId,
        signUpPageView: signUpPageView ?? this.signUpPageView);
  }

  @override
  List<Object?> get props =>
      [signUpPageView, name, phoneNo, smsCode, verificationId, municipality];
}

//endregion

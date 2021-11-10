
///
/// ENUMS
///
//region Enums

enum SignUpPageView { phoneNo, name, smsCode }
enum SignUpButtonEvent { verifyPhoneNo, verifySmsCode, confirmName }
enum SignUpTextChangedEvent { name, phoneNo, smsCode }
enum SignUpViewChangeEvent { name, phoneNo, smsCode }

//endregion

///
/// EVENT
///
//region Event

class SignUpEvent {}

class ButtonPressed extends SignUpEvent {
  final SignUpButtonEvent signUpButtonEvent;

  ButtonPressed({required this.signUpButtonEvent});
}

class TextChanged extends SignUpEvent {
  final SignUpTextChangedEvent signUpTextChangedEvent;
  final String? text;

  TextChanged({required this.signUpTextChangedEvent, required this.text});
}

class MakeViewChange extends SignUpEvent {
  final SignUpPageView signUpPageView;

  MakeViewChange({required this.signUpPageView});
}

class VerificationIdRetrieved extends SignUpEvent {
  final String verificationId;

  VerificationIdRetrieved({required this.verificationId});
}

//endregion

///
/// STATE
///
//region State

class SignUpState {
  SignUpPageView? signUpPageView;
  String? name;
  String? phoneNo;
  String? smsCode;
  String? verificationId;

  SignUpState(
      {this.name,
      this.smsCode,
      this.verificationId,
      this.phoneNo,
      this.signUpPageView});

  SignUpState copyWith(
      {String? name,
      String? phoneNo,
      String? smsCode,
      String? verificationId,
      SignUpPageView? signUpPageView}) {
    return SignUpState(
        name: name ?? this.name,
        phoneNo: phoneNo ?? this.phoneNo,
        smsCode: smsCode ?? this.smsCode,
        verificationId: verificationId ?? this.verificationId,
        signUpPageView: signUpPageView ?? this.signUpPageView);
  }
}

//endregion

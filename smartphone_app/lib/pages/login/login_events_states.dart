///
/// ENUMS
///
//region Enums

enum LoginButtonEvent { usePhoneNo, useGoogleLogin, useAppleLogin }

//endregion

///
/// EVENT
///
//region Event

class LoginEvent {}

class ButtonPressed extends LoginEvent {
  final LoginButtonEvent loginButtonEvent;

  ButtonPressed({required this.loginButtonEvent});
}

//endregion

///
/// STATE
///
//region State

class LoginState {

  LoginState();

  LoginState copyWith() {
    return LoginState();
  }

}

//endregion
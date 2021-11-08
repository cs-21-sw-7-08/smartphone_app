
class LoginEvent {}

enum LoginButtonEvent { usePhoneNo, useGoogleLogin, useAppleLogin }

class ButtonPressed extends LoginEvent {
  final LoginButtonEvent loginButtonEvent;

  ButtonPressed({required this.loginButtonEvent});
}

class LoginState {

  LoginState();

  LoginState copyWith() {
    return LoginState();
  }

}
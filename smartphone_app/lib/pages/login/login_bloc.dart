import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_page.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import '../../utilities/sign_in/third_party_sign_in_util.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  LoginBloc({required BuildContext buildContext}) : super(LoginState()) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.loginButtonEvent) {
        case LoginButtonEvent.usePhoneNo:
          GeneralUtil.goToPage(_buildContext, SignUpPage());
          break;
        case LoginButtonEvent.useGoogleLogin:
          try {
            SignInResponse? signInResponse = await ThirdPartySignInUtil.signInWithGoogle();

            if (signInResponse != null) {
              String? name = signInResponse.googleSignInAccount.displayName;
              name ??= "";
              GeneralUtil.goToPage(_buildContext, SignUpPage(name: name));
            }
          } on Exception catch (exc) {
            GeneralUtil.showToast(exc.toString());
          }
          break;
        case LoginButtonEvent.useAppleLogin:
          GeneralUtil.goToPage(_buildContext, IssuesOverviewPage());
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<PermissionState> getPermissions() async {
    List<PermissionWithService> permissions = [Permission.locationWhenInUse];
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    PermissionState permissionState =
        statuses.values.any((element) => !element.isGranted)
            ? PermissionState.denied
            : PermissionState.granted;
    return permissionState;
  }

//endregion

}

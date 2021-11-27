import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/helpers/permission_helper.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_page.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import '../../utilities/sign_in/third_party_sign_in_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  late PermissionHelper permissionHelper;
  static const List<PermissionWithService> permissions = [
    Permission.locationWhenInUse
  ];

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  LoginBloc({required this.context, required this.permissionHelper})
      : super(LoginState(permissionState: PermissionState.denied));

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.buttonEvent) {

        /// Use phone no.
        case LoginButtonEvent.usePhoneNo:
          GeneralUtil.goToPage(context, SignUpPage());
          break;

        /// Use Google login
        case LoginButtonEvent.useGoogleLogin:
          await _useGoogleLogin();
          break;

        /// Use Apple login
        case LoginButtonEvent.useAppleLogin:
          await _useAppleLogin();
          break;

        /// Go to settings
        case LoginButtonEvent.goToSettings:
          await permissionHelper.openAppSettings();
          break;
      }
    } else if (event is Resumed) {
      for (var permission in permissions) {
        var status = await permissionHelper.getStatus(permission);
        if (!status.isGranted) {
          add(const PermissionStateChanged(
              permissionState: PermissionState.denied));
          return;
        }
      }
      add(const PermissionStateChanged(
          permissionState: PermissionState.granted));
    } else if (event is PermissionStateChanged) {
      yield state.copyWith(permissionState: event.permissionState);
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<void> _useGoogleLogin() async {
    String? name;
    SignInResponse? signInResponse;
    bool errorOccurred = false;
    // Try log in
    Citizen? citizen = await TaskUtil.runTask<Citizen>(
        buildContext: context,
        progressMessage: AppLocalizations.of(context)!.logging_in,
        doInBackground: (runTask) async {
          try {
            signInResponse = await ThirdPartySignInUtil.signInWithGoogle();
          } on Exception catch (exc) {
            GeneralUtil.showToast(exc.toString());
            return null;
          }
          if (signInResponse == null) return null;
          name = signInResponse!.googleSignInAccount.displayName;
          name ??= "";

          var response = await WASPService.getInstance().logInCitizen(
              citizen: Citizen(email: signInResponse!.user.email));
          if (!response.isSuccess) {
            if (response.waspResponse!.errorNo == 202) {
              return null;
            }
            errorOccurred = true;
            GeneralUtil.showToast((await response.errorMessage)!);
            return null;
          }
          return response.waspResponse!.result;
        },
        taskCancelled: () {});

    if (signInResponse == null) return;
    if (errorOccurred) return;

    // If citizen is null it means that the user is not signed up yet
    if (citizen == null) {
      name ??= "";
      GeneralUtil.goToPage(
          context, SignUpPage(email: signInResponse!.user.email, name: name));
    } else {
      if (citizen.isBlocked!) {
        await ThirdPartySignInUtil.signOut();
        GeneralUtil.showToast(
            AppLocalizations.of(context)!.this_user_is_blocked);
        return;
      }

      // Save citizen ID
      await AppValuesHelper.getInstance()
          .saveInteger(AppValuesKey.citizenId, citizen.id!);
      // Save default municipality ID
      await AppValuesHelper.getInstance().saveInteger(
          AppValuesKey.defaultMunicipalityId, citizen.municipality!.id);
      // Go to issues overview
      GeneralUtil.goToPage(context, const IssuesOverviewPage());
    }
  }

  Future<void> _useAppleLogin() async {
    GeneralUtil.showToast(
        AppLocalizations.of(context)!.this_is_not_supported_yet);
  }

  Future<PermissionState> getPermissions() async {
    if (Platform.isIOS) {
      return PermissionState.granted;
    }

    Map<Permission, PermissionStatus> statuses =
        await permissionHelper.requestPermissions(permissions);

    PermissionState permissionState =
        statuses.values.any((element) => !element.isGranted)
            ? PermissionState.denied
            : PermissionState.granted;

    add(PermissionStateChanged(permissionState: permissionState));
    return permissionState;
  }

//endregion

}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_page.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/sign_in/third_party_sign_in_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  // ignore: unused_field
  late BuildContext _buildContext;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  SignUpBloc(
      {required BuildContext buildContext,
      required SignUpPageView signUpPageView,
      String? name})
      : super(SignUpState(signUpPageView: signUpPageView, name: name)) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is TextChanged) {
      print(event.text);
      switch (event.signUpTextChangedEvent) {
        case SignUpTextChangedEvent.name:
          yield state.copyWith(name: event.text);
          break;
        case SignUpTextChangedEvent.phoneNo:
          yield state.copyWith(phoneNo: event.text);
          break;
        case SignUpTextChangedEvent.smsCode:
          yield state.copyWith(smsCode: event.text);
          break;
      }
    } else if (event is MakeViewChange) {
      yield state.copyWith(signUpPageView: event.signUpPageView);
    } else if (event is VerificationIdRetrieved) {
      yield state.copyWith(verificationId: event.verificationId);
    } else if (event is ButtonPressed) {
      switch (event.signUpButtonEvent) {
        case SignUpButtonEvent.verifyPhoneNo:
          await verifyPhoneNo();
          break;
        case SignUpButtonEvent.verifySmsCode:
          await verifySmsCode();
          break;
        case SignUpButtonEvent.confirmName:
          await confirmName();
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  verifyPhoneNo() async {
    await TaskUtil.runTask<bool>(
        buildContext: _buildContext,
        progressMessage: "Sending verification code...",
        doInBackground: (runTask) async {
          await ThirdPartySignInUtil.verifyPhoneNo(
              phoneNumber: "+45" + state.phoneNo!,
              verificationCompleted: (credentials) async {
                verifySmsCode(credentials: credentials);
              },
              verificationFailed: (error) {
                GeneralUtil.showToast(error.message!);
              },
              codeSent: (verificationId, token) {
                add(VerificationIdRetrieved(verificationId: verificationId));
                add(MakeViewChange(signUpPageView: SignUpPageView.smsCode));
              },
              codeAutoRetrievalTimeout: (verificationId) {
                add(VerificationIdRetrieved(verificationId: verificationId));
              });
          return null;
        },
        taskCancelled: () {});
  }

  verifySmsCode({PhoneAuthCredential? credentials}) async {
    UserCredential? userCredential = await TaskUtil.runTask<UserCredential>(
        buildContext: _buildContext,
        progressMessage: "Verifying SMS code...",
        doInBackground: (runTask) async {
          if (credentials != null) {
            return await ThirdPartySignInUtil.signInWithCredentials(
                credentials);
          } else {
            return await ThirdPartySignInUtil.signInWithSmsCode(
                state.verificationId!, state.smsCode!);
          }
        },
        taskCancelled: () {});
    if (userCredential == null) return;
    add(MakeViewChange(signUpPageView: SignUpPageView.name));
  }

  confirmName() async {
    // Sign up user via webservice
    AppValuesHelper.getInstance().saveInteger(AppValuesKey.citizenId, 1);
    GeneralUtil.goToPage(_buildContext, IssuesOverviewPage());
  }

//endregion

}

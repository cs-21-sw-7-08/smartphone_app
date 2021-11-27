import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_page.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/sign_in/third_party_sign_in_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  late String? email;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  SignUpBloc(
      {required this.context,
      required SignUpPageView signUpPageView,
      required this.email,
      String? name})
      : super(SignUpState(signUpPageView: signUpPageView, name: name));

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<SignUpState> mapEventToState(SignUpEvent event) async* {
    if (event is TextChanged) {
      switch (event.textChangedEvent) {

        /// Name
        case SignUpTextChangedEvent.name:
          yield state.copyWith(name: event.text);
          break;

        /// Phone no.
        case SignUpTextChangedEvent.phoneNo:
          yield state.copyWith(phoneNo: event.text);
          break;

        /// SMS code
        case SignUpTextChangedEvent.smsCode:
          yield state.copyWith(smsCode: event.text);
          break;
      }
    } else if (event is MakeViewChange) {
      yield state.copyWith(signUpPageView: event.pageView);
    } else if (event is VerificationIdRetrieved) {
      yield state.copyWith(verificationId: event.verificationId);
    } else if (event is ButtonPressed) {
      switch (event.buttonEvent) {

        /// Verify phone no.
        case SignUpButtonEvent.verifyPhoneNo:
          await _verifyPhoneNo();
          break;

        /// Verify SMS code
        case SignUpButtonEvent.verifySmsCode:
          await _verifySmsCode();
          break;

        /// Confirm name
        case SignUpButtonEvent.confirmName:
          await _confirmName();
          break;

        /// Back
        case SignUpButtonEvent.back:
          await _cancelSignUp();
          break;

        /// Select municipality
        case SignUpButtonEvent.selectMunicipality:
          SignUpState? newState = await _selectMunicipality();
          if (newState == null) return;
          yield newState;
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<SignUpState?> _selectMunicipality() async {
    List<Municipality> municipalities =
        AppValuesHelper.getInstance().getMunicipalities();
    List<dynamic>? selectedItems =
        await CustomListDialog.show(context, items: municipalities, itemBuilder:
            (index, item, list, showSearchBar, itemSelected, itemUpdated) {
      if (item is Municipality) {
        return Container(
            margin: EdgeInsets.only(
                top: index == 0 && showSearchBar ? 0 : values.padding,
                left: values.padding,
                right: values.padding,
                bottom: index == list.length - 1 ? values.padding : 0),
            child: CustomListTile(
                widget: Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      CustomLabel(
                        title: item.name!,
                        margin: const EdgeInsets.only(
                            left: values.padding,
                            top: values.padding * 2,
                            right: values.padding,
                            bottom: values.padding * 2),
                      )
                    ],
                  ),
                ),
                onPressed: () {
                  itemSelected(null);
                }));
      }
    }, searchPredicate: (item, searchString) {
      if (item is Municipality) {
        return item.name!.toLowerCase().contains(searchString);
      }
      return false;
    }, titleBuilder: (item) {
      if (item == null) {
        return AppLocalizations.of(context)!.municipality;
      }
      return "";
    });
    if (selectedItems == null) return null;
    Municipality? selectedMunicipality = selectedItems
        .firstWhere((element) => element is Municipality, orElse: () => null);
    if (selectedMunicipality == null) return null;
    return state.copyWith(
        municipality: selectedMunicipality,
        signUpPageView: SignUpPageView.name);
  }

  Future<void> _cancelSignUp() async {
    await TaskUtil.runTask<bool>(
        buildContext: context,
        progressMessage: AppLocalizations.of(context)!.cancelling_sign_up,
        doInBackground: (runTask) async {
          // Sign out
          await ThirdPartySignInUtil.signOut();
          return null;
        },
        taskCancelled: () {});

    GeneralUtil.goToPage(context, const LoginPage());
  }

  Future<void> _verifyPhoneNo() async {
    // Check for valid phone number
    if (state.phoneNo == null || state.phoneNo!.length != 8) {
      GeneralUtil.showToast(
          AppLocalizations.of(context)!.please_enter_a_valid_phone_number);
      return;
    }

    await TaskUtil.runTask<bool>(
        buildContext: context,
        progressMessage:
            AppLocalizations.of(context)!.sending_verification_code,
        doInBackground: (runTask) async {
          await ThirdPartySignInUtil.verifyPhoneNo(
              phoneNumber: "+45" + state.phoneNo!,
              verificationCompleted: (credentials) async {
                _verifySmsCode(credentials: credentials);
              },
              verificationFailed: (error) {
                GeneralUtil.showToast(error.message!);
              },
              codeSent: (verificationId, token) {
                add(VerificationIdRetrieved(verificationId: verificationId));
                add(const MakeViewChange(pageView: SignUpPageView.smsCode));
              },
              codeAutoRetrievalTimeout: (verificationId) {
                add(VerificationIdRetrieved(verificationId: verificationId));
              });
          return null;
        },
        taskCancelled: () {});
  }

  Future<void> _verifySmsCode({PhoneAuthCredential? credentials}) async {
    // Check for valid SMS code
    if (state.smsCode == null || state.smsCode!.length != 6) {
      GeneralUtil.showToast(
          AppLocalizations.of(context)!.please_enter_the_sms_code_toast);
      return;
    }

    // Verify SMS code
    UserCredential? userCredential = await TaskUtil.runTask<UserCredential>(
        buildContext: context,
        progressMessage: AppLocalizations.of(context)!.verifying_sms_code,
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

    // Try log into Bee A Helper
    Citizen? citizen = await TaskUtil.runTask<Citizen>(
        buildContext: context,
        progressMessage: AppLocalizations.of(context)!.checking_credentials,
        doInBackground: (runTask) async {
          var response = await WASPService.getInstance()
              .logInCitizen(citizen: Citizen(phoneNo: state.phoneNo));
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
            return null;
          }
          return response.waspResponse!.result;
        },
        taskCancelled: () {});

    if (citizen == null) {
      // Fire event
      add(const MakeViewChange(pageView: SignUpPageView.name));
    } else {
      // Save citizen ID
      await AppValuesHelper.getInstance()
          .saveInteger(AppValuesKey.citizenId, citizen.id!);
      // Save default municipality
      await AppValuesHelper.getInstance().saveInteger(
          AppValuesKey.defaultMunicipalityId, citizen.municipality!.id);
      // Go to issues overview
      GeneralUtil.goToPage(context, const IssuesOverviewPage());
    }
  }

  Future<void> _confirmName() async {
    // Check for valid name
    if (state.name == null || state.name!.isEmpty) {
      GeneralUtil.showToast(
          AppLocalizations.of(context)!.please_enter_your_full_name_toast);
      return;
    }
    // Check for municipality selection
    if (state.municipality == null) {
      GeneralUtil.showToast(
          AppLocalizations.of(context)!.please_select_a_municipality);
      return;
    }

    // Sign up
    Citizen? citizen = await TaskUtil.runTask<Citizen>(
        buildContext: context,
        progressMessage: AppLocalizations.of(context)!.signing_up,
        doInBackground: (runTask) async {
          var response = await WASPService.getInstance().signUpCitizen(
              citizen: Citizen(
                  email: email,
                  phoneNo: state.phoneNo,
                  name: state.name,
                  municipalityId: state.municipality!.id));
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
            return null;
          }
          return response.waspResponse!.result;
        },
        taskCancelled: () {});

    if (citizen == null) return;
    // Save citizen ID
    await AppValuesHelper.getInstance()
        .saveInteger(AppValuesKey.citizenId, citizen.id!);
    // Save default municipality
    await AppValuesHelper.getInstance().saveInteger(
        AppValuesKey.defaultMunicipalityId, state.municipality!.id);
    // Go to issues overview
    GeneralUtil.goToPage(context, const IssuesOverviewPage());
  }

  Future<bool> getValues() async {
    return await Future.delayed(
        const Duration(milliseconds: values.pageTransitionTime), () async {
      var flag = await TaskUtil.runTask(
          buildContext: context,
          progressMessage: AppLocalizations.of(context)!.getting_information,
          doInBackground: (runTask) async {
            // Get list of municipalities
            WASPServiceResponse<GetListOfMunicipalities_WASPResponse>
                getListOfMunicipalitiesResponse =
                await WASPService.getInstance().getListOfMunicipalities();
            if (!getListOfMunicipalitiesResponse.isSuccess) {
              GeneralUtil.showToast(
                  (await getListOfMunicipalitiesResponse.errorMessage)!);
              return false;
            }
            AppValuesHelper.getInstance().saveMunicipalities(
                getListOfMunicipalitiesResponse.waspResponse!.result!);
            // Return true
            return true;
          },
          taskCancelled: () {});
      flag ??= false;
      return flag;
    });
  }

//endregion

}
